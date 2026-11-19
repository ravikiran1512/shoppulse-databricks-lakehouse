-- Initial profiling; these source sizes are NOT permanently hardcoded contracts.
SELECT 'orders' AS dataset, COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS unique_keys
FROM {{catalog}}.shoppulse_bronze.olist_orders_raw
UNION ALL
SELECT 'order_items', COUNT(*), COUNT(DISTINCT CONCAT_WS('|', order_id, order_item_id))
FROM {{catalog}}.shoppulse_bronze.olist_order_items_raw
UNION ALL
SELECT 'customers', COUNT(*), COUNT(DISTINCT customer_id)
FROM {{catalog}}.shoppulse_bronze.olist_customers_raw
UNION ALL
SELECT 'products', COUNT(*), COUNT(DISTINCT product_id)
FROM {{catalog}}.shoppulse_bronze.olist_products_raw
UNION ALL
SELECT 'payments', COUNT(*), COUNT(DISTINCT CONCAT_WS('|', order_id, payment_sequential))
FROM {{catalog}}.shoppulse_bronze.olist_order_payments_raw
UNION ALL
SELECT 'sellers', COUNT(*), COUNT(DISTINCT seller_id)
FROM {{catalog}}.shoppulse_bronze.olist_sellers_raw;

