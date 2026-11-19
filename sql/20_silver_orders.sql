-- Grain: one latest valid row per order_id. Bronze is never overwritten.
-- The temporary view allows both accepted and rejected records to be audited.
CREATE OR REPLACE TEMP VIEW _shoppulse_orders_profile AS
WITH typed AS (
  SELECT
    NULLIF(TRIM(order_id), '') AS order_id,
    NULLIF(TRIM(customer_id), '') AS customer_id,
    LOWER(TRIM(order_status)) AS order_status,
    TRY_CAST(order_purchase_timestamp AS TIMESTAMP) AS purchased_at,
    TRY_CAST(order_approved_at AS TIMESTAMP) AS approved_at,
    TRY_CAST(order_delivered_carrier_date AS TIMESTAMP) AS carrier_at,
    TRY_CAST(order_delivered_customer_date AS TIMESTAMP) AS delivered_at,
    TRY_CAST(order_estimated_delivery_date AS TIMESTAMP) AS estimated_delivery_at,
    source_file, ingested_at
  FROM {{catalog}}.shoppulse_bronze.olist_orders_raw
), ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY order_id
           ORDER BY ingested_at DESC, source_file DESC, customer_id DESC, order_status DESC
         ) AS row_num
  FROM typed
)
SELECT *,
       CASE
         WHEN order_id IS NULL THEN 'missing_order_id'
         WHEN customer_id IS NULL THEN 'missing_customer_id'
         WHEN purchased_at IS NULL THEN 'invalid_purchase_timestamp'
         WHEN order_status NOT IN ('created','approved','invoiced','processing',
                                   'shipped','delivered','unavailable','canceled')
              OR order_status IS NULL THEN 'unknown_status'
         WHEN row_num > 1 THEN 'duplicate_order_id'
         ELSE NULL
       END AS rejection_reason
FROM ranked;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.orders_rejected
USING DELTA AS
SELECT * FROM _shoppulse_orders_profile WHERE rejection_reason IS NOT NULL;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.orders_clean
USING DELTA AS
SELECT order_id, customer_id, order_status, purchased_at, approved_at,
       carrier_at, delivered_at, estimated_delivery_at, source_file, ingested_at
FROM _shoppulse_orders_profile
WHERE rejection_reason IS NULL;

