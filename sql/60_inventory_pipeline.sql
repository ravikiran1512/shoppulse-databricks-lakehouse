-- Optional synthetic operational feed. Upload generated JSONL to source_files volume.
-- COPY INTO is idempotent by file. Row corrections handled separately in Silver.
CREATE TABLE IF NOT EXISTS {{catalog}}.shoppulse_bronze.inventory_events_raw (
 event_id STRING, warehouse_id STRING, sku_id STRING, event_ts STRING,
 movement_type STRING, qty_delta STRING, source_version STRING,
 source_file STRING, ingested_at TIMESTAMP
) USING DELTA;

COPY INTO {{catalog}}.shoppulse_bronze.inventory_events_raw
FROM (
 SELECT CAST(event_id AS STRING), CAST(warehouse_id AS STRING),
        CAST(sku_id AS STRING), CAST(event_ts AS STRING),
        CAST(movement_type AS STRING), CAST(qty_delta AS STRING),
        CAST(source_version AS STRING), _metadata.file_path,
        current_timestamp()
 FROM '/Volumes/{{catalog}}/shoppulse_bronze/source_files/inventory_movements.jsonl'
)
FILEFORMAT = JSON;

CREATE OR REPLACE TEMP VIEW _inventory_staged AS
WITH parsed AS (
 SELECT NULLIF(TRIM(event_id),'') AS event_id,
        NULLIF(TRIM(warehouse_id),'') AS warehouse_id,
        NULLIF(TRIM(sku_id),'') AS sku_id,
        TRY_CAST(event_ts AS TIMESTAMP) AS event_ts,
        LOWER(TRIM(movement_type)) AS movement_type,
        TRY_CAST(qty_delta AS BIGINT) AS qty_delta,
        TRY_CAST(source_version AS BIGINT) AS source_version,
        source_file, ingested_at
 FROM {{catalog}}.shoppulse_bronze.inventory_events_raw
), ranked AS (
 SELECT *, ROW_NUMBER() OVER (
  PARTITION BY event_id
  ORDER BY source_version DESC NULLS LAST, ingested_at DESC, source_file DESC
 ) AS rn
 FROM parsed
)
SELECT *,
 CASE WHEN event_id IS NULL OR warehouse_id IS NULL OR sku_id IS NULL
          THEN 'missing_business_key'
      WHEN event_ts IS NULL OR source_version IS NULL THEN 'bad_event_timestamp_or_version'
      WHEN qty_delta IS NULL OR qty_delta = 0 THEN 'invalid_movement_quantity'
      WHEN movement_type NOT IN ('receipt','dispatch','return')
          THEN 'invalid_movement_type'
      WHEN rn > 1 THEN 'duplicate_or_superseded_event'
      ELSE NULL
 END AS rejection_reason
FROM ranked;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.inventory_events_rejected
USING DELTA AS
SELECT * FROM _inventory_staged WHERE rejection_reason IS NOT NULL;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.inventory_events_clean
USING DELTA AS
SELECT event_id, warehouse_id, sku_id, event_ts, movement_type,
       qty_delta, source_version
FROM _inventory_staged WHERE rejection_reason IS NULL;

-- This is cumulative NET MOVEMENT, NOT on-hand inventory without an opening snapshot.
CREATE OR REPLACE TABLE {{catalog}}.shoppulse_gold.inventory_net_movement
USING DELTA AS
SELECT warehouse_id, sku_id,
       SUM(qty_delta) AS net_quantity_change,
       COUNT(*) AS movement_count,
       MAX(event_ts) AS last_movement_at
FROM {{catalog}}.shoppulse_silver.inventory_events_clean
GROUP BY warehouse_id, sku_id;

