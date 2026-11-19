-- Grain: one line per (order_id, order_item_id), with positive price,
-- nonnegative freight, and an existing parent order.
CREATE OR REPLACE TEMP VIEW _shoppulse_items_profile AS
WITH typed AS (
 SELECT NULLIF(TRIM(order_id), '') AS order_id,
        TRY_CAST(order_item_id AS INT) AS order_item_id,
        NULLIF(TRIM(product_id), '') AS product_id,
        NULLIF(TRIM(seller_id), '') AS seller_id,
        TRY_CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_at,
        TRY_CAST(price AS DECIMAL(18,2)) AS item_price_brl,
        TRY_CAST(freight_value AS DECIMAL(18,2)) AS freight_brl,
        source_file, ingested_at
 FROM {{catalog}}.shoppulse_bronze.olist_order_items_raw
), ranked AS (
 SELECT *, ROW_NUMBER() OVER (
    PARTITION BY order_id, order_item_id
    ORDER BY ingested_at DESC, source_file DESC, product_id DESC
 ) AS row_num FROM typed
), checked AS (
 SELECT r.*, o.order_id AS parent_order_id
 FROM ranked r
 LEFT JOIN {{catalog}}.shoppulse_silver.orders_clean o ON r.order_id = o.order_id
)
SELECT *,
       CASE
         WHEN order_id IS NULL OR order_item_id IS NULL OR order_item_id <= 0
           THEN 'invalid_order_item_key'
         WHEN product_id IS NULL OR seller_id IS NULL THEN 'missing_product_or_seller'
         WHEN shipping_limit_at IS NULL THEN 'invalid_shipping_limit'
         WHEN item_price_brl IS NULL OR item_price_brl <= 0 THEN 'invalid_price'
         WHEN freight_brl IS NULL OR freight_brl < 0 THEN 'invalid_freight'
         WHEN parent_order_id IS NULL THEN 'missing_parent_order'
         WHEN row_num > 1 THEN 'duplicate_item_key'
         ELSE NULL
       END AS rejection_reason
FROM checked;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.order_items_rejected
USING DELTA AS SELECT * FROM _shoppulse_items_profile WHERE rejection_reason IS NOT NULL;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.order_items_clean
USING DELTA AS
SELECT order_id, order_item_id, product_id, seller_id, shipping_limit_at,
       item_price_brl, freight_brl, source_file, ingested_at
FROM _shoppulse_items_profile WHERE rejection_reason IS NULL;

