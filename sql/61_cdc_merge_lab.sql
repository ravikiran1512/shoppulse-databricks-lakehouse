-- ISOLATED SCD Type 1 MERGE lab; never run against production customer tables.
-- Example demonstrates order-independent dedup by sequence, correct reruns.
CREATE SCHEMA IF NOT EXISTS {{catalog}}.shoppulse_dev;
CREATE OR REPLACE TABLE {{catalog}}.shoppulse_dev.customer_preferences_lab
USING DELTA AS
SELECT 'C101' AS customer_id, 'email' AS preferred_channel, 1 AS seq
UNION ALL SELECT 'C102', 'sms', 1;

CREATE OR REPLACE TEMP VIEW _preference_change_events AS
SELECT 'C101' AS customer_id, 'sms' AS preferred_channel, 2 AS seq, 'U' AS op
UNION ALL SELECT 'C101', 'email', 1, 'U'
UNION ALL SELECT 'C103', 'email', 1, 'I'
UNION ALL SELECT 'C102', 'sms', 2, 'D';

MERGE INTO {{catalog}}.shoppulse_dev.customer_preferences_lab AS target
USING (
 SELECT customer_id, preferred_channel, seq, op
 FROM (
  SELECT *, ROW_NUMBER() OVER (
    PARTITION BY customer_id ORDER BY seq DESC
  ) rn FROM _preference_change_events
 ) WHERE rn = 1
) AS source
ON target.customer_id = source.customer_id
WHEN MATCHED AND source.op = 'D' AND source.seq > target.seq
  THEN DELETE
WHEN MATCHED AND source.op <> 'D' AND source.seq > target.seq
  THEN UPDATE SET target.preferred_channel = source.preferred_channel,
                  target.seq = source.seq
WHEN NOT MATCHED AND source.op <> 'D'
  THEN INSERT (customer_id, preferred_channel, seq)
       VALUES (source.customer_id, source.preferred_channel, source.seq);

SELECT * FROM {{catalog}}.shoppulse_dev.customer_preferences_lab ORDER BY customer_id;
-- This teaching script resets the lab table; the MERGE alone is rerun-safe.
-- Do NOT confuse SCD1 MERGE with the optional Lakeflow SCD2 AUTO CDC lab.

