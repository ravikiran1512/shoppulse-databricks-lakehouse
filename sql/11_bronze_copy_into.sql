-- Re-runnable file-level ingestion with COPY INTO.
-- Place the 8 official Olist CSVs in /Volumes/<catalog>/shoppulse_bronze/source_files/.
-- COPY INTO tracks previously loaded files; it DOES NOT deduplicate rows across files.
-- Do not set COPY_OPTIONS ('force' = 'true') for ordinary re-runs.
COPY INTO {{catalog}}.shoppulse_bronze.olist_orders_raw
FROM (
  SELECT order_id, customer_id, order_status, order_purchase_timestamp,
         order_approved_at, order_delivered_carrier_date,
         order_delivered_customer_date, order_estimated_delivery_date,
         _metadata.file_path AS source_file, current_timestamp() AS ingested_at
  FROM '/Volumes/{{catalog}}/shoppulse_bronze/source_files/olist_orders_dataset.csv'
)
FILEFORMAT = CSV FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'false');

COPY INTO {{catalog}}.shoppulse_bronze.olist_order_items_raw
FROM (
  SELECT order_id, order_item_id, product_id, seller_id, shipping_limit_date,
         price, freight_value, _metadata.file_path AS source_file,
         current_timestamp() AS ingested_at
  FROM '/Volumes/{{catalog}}/shoppulse_bronze/source_files/olist_order_items_dataset.csv'
)
FILEFORMAT = CSV FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'false');

COPY INTO {{catalog}}.shoppulse_bronze.olist_customers_raw
FROM (
  SELECT customer_id, customer_unique_id, customer_zip_code_prefix,
         customer_city, customer_state, _metadata.file_path AS source_file,
         current_timestamp() AS ingested_at
  FROM '/Volumes/{{catalog}}/shoppulse_bronze/source_files/olist_customers_dataset.csv'
)
FILEFORMAT = CSV FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'false');

COPY INTO {{catalog}}.shoppulse_bronze.olist_products_raw
FROM (
  SELECT product_id, product_category_name, product_name_lenght,
         product_description_lenght, product_photos_qty, product_weight_g,
         product_length_cm, product_height_cm, product_width_cm,
         _metadata.file_path AS source_file, current_timestamp() AS ingested_at
  FROM '/Volumes/{{catalog}}/shoppulse_bronze/source_files/olist_products_dataset.csv'
)
FILEFORMAT = CSV FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'false');

COPY INTO {{catalog}}.shoppulse_bronze.olist_sellers_raw
FROM (
  SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state,
         _metadata.file_path AS source_file, current_timestamp() AS ingested_at
  FROM '/Volumes/{{catalog}}/shoppulse_bronze/source_files/olist_sellers_dataset.csv'
)
FILEFORMAT = CSV FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'false');

COPY INTO {{catalog}}.shoppulse_bronze.olist_order_payments_raw
FROM (
  SELECT order_id, payment_sequential, payment_type, payment_installments,
         payment_value, _metadata.file_path AS source_file,
         current_timestamp() AS ingested_at
  FROM '/Volumes/{{catalog}}/shoppulse_bronze/source_files/olist_order_payments_dataset.csv'
)
FILEFORMAT = CSV FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'false');

COPY INTO {{catalog}}.shoppulse_bronze.olist_order_reviews_raw
FROM (
  SELECT review_id, order_id, review_score, review_comment_title,
         review_comment_message, review_creation_date, review_answer_timestamp,
         _metadata.file_path AS source_file, current_timestamp() AS ingested_at
  FROM '/Volumes/{{catalog}}/shoppulse_bronze/source_files/olist_order_reviews_dataset.csv'
)
FILEFORMAT = CSV FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'false');

COPY INTO {{catalog}}.shoppulse_bronze.olist_category_translation_raw
FROM (
  SELECT product_category_name, product_category_name_english,
         _metadata.file_path AS source_file, current_timestamp() AS ingested_at
  FROM '/Volumes/{{catalog}}/shoppulse_bronze/source_files/product_category_name_translation.csv'
)
FILEFORMAT = CSV FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'false');

