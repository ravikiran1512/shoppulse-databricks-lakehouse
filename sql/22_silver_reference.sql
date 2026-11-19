-- Reference tables are deduplicated at their natural keys; no invented surrogate
-- key is needed at this stage. Olist's customer_id identifies an order/customer
-- address record; customer_unique_id is the cross-order shopper identity.
CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.customers_clean
USING DELTA AS
WITH ranked AS (
 SELECT NULLIF(TRIM(customer_id),'') AS customer_id,
        NULLIF(TRIM(customer_unique_id),'') AS customer_unique_id,
        customer_zip_code_prefix,
        INITCAP(TRIM(customer_city)) AS customer_city,
        UPPER(TRIM(customer_state)) AS customer_state,
        ROW_NUMBER() OVER (PARTITION BY customer_id
          ORDER BY ingested_at DESC, source_file DESC) AS rn
 FROM {{catalog}}.shoppulse_bronze.olist_customers_raw
)
SELECT customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state
FROM ranked WHERE rn = 1 AND customer_id IS NOT NULL AND customer_unique_id IS NOT NULL;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.products_clean
USING DELTA AS
WITH ranked AS (
 SELECT NULLIF(TRIM(product_id),'') AS product_id,
        NULLIF(TRIM(product_category_name),'') AS category_pt,
        TRY_CAST(product_weight_g AS DOUBLE) AS weight_g,
        TRY_CAST(product_length_cm AS DOUBLE) AS length_cm,
        TRY_CAST(product_height_cm AS DOUBLE) AS height_cm,
        TRY_CAST(product_width_cm AS DOUBLE) AS width_cm,
        ROW_NUMBER() OVER (PARTITION BY product_id
          ORDER BY ingested_at DESC, source_file DESC) AS rn
 FROM {{catalog}}.shoppulse_bronze.olist_products_raw
)
SELECT product_id, category_pt, weight_g, length_cm, height_cm, width_cm
FROM ranked WHERE rn = 1 AND product_id IS NOT NULL;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.sellers_clean
USING DELTA AS
WITH ranked AS (
 SELECT NULLIF(TRIM(seller_id),'') AS seller_id, seller_zip_code_prefix,
        INITCAP(TRIM(seller_city)) AS seller_city,
        UPPER(TRIM(seller_state)) AS seller_state,
        ROW_NUMBER() OVER (PARTITION BY seller_id
          ORDER BY ingested_at DESC, source_file DESC) AS rn
 FROM {{catalog}}.shoppulse_bronze.olist_sellers_raw
)
SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state
FROM ranked WHERE rn = 1 AND seller_id IS NOT NULL;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.payments_clean
USING DELTA AS
WITH parsed AS (
 SELECT NULLIF(TRIM(order_id),'') AS order_id,
        TRY_CAST(payment_sequential AS INT) AS payment_sequential,
        LOWER(TRIM(payment_type)) AS payment_type,
        TRY_CAST(payment_installments AS INT) AS payment_installments,
        TRY_CAST(payment_value AS DECIMAL(18,2)) AS payment_value_brl,
        ingested_at, source_file
 FROM {{catalog}}.shoppulse_bronze.olist_order_payments_raw
), ranked AS (
 SELECT *, ROW_NUMBER() OVER (
    PARTITION BY order_id, payment_sequential ORDER BY ingested_at DESC, source_file DESC
 ) AS rn FROM parsed
)
SELECT order_id, payment_sequential, payment_type, payment_installments, payment_value_brl
FROM ranked
WHERE rn = 1 AND order_id IS NOT NULL AND payment_sequential > 0
  AND payment_value_brl >= 0;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_silver.category_translation
USING DELTA AS
WITH ranked AS (
 SELECT TRIM(product_category_name) AS category_pt,
        TRIM(product_category_name_english) AS category_en,
        ROW_NUMBER() OVER (PARTITION BY product_category_name
          ORDER BY ingested_at DESC, source_file DESC) AS rn
 FROM {{catalog}}.shoppulse_bronze.olist_category_translation_raw
)
SELECT category_pt, category_en FROM ranked WHERE rn = 1 AND category_pt IS NOT NULL;

