-- Reviews can have multiple rows per order; review_id, not order_id, is the key.
CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.reviews_clean
USING DELTA AS
WITH typed AS (
 SELECT NULLIF(TRIM(review_id),'') AS review_id,
        NULLIF(TRIM(order_id),'') AS order_id,
        TRY_CAST(review_score AS INT) AS review_score,
        TRY_CAST(review_creation_date AS TIMESTAMP) AS review_created_at,
        TRY_CAST(review_answer_timestamp AS TIMESTAMP) AS review_answered_at,
        source_file, ingested_at
 FROM {{catalog}}.shoppulse_bronze.olist_order_reviews_raw
), ranked AS (
 SELECT *, ROW_NUMBER() OVER (
   PARTITION BY review_id, order_id
   ORDER BY ingested_at DESC, source_file DESC
 ) AS rn FROM typed
)
SELECT review_id, order_id, review_score, review_created_at, review_answered_at
FROM ranked
WHERE rn = 1 AND review_id IS NOT NULL AND order_id IS NOT NULL
  AND review_score BETWEEN 1 AND 5;

