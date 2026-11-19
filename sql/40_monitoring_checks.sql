-- Read-only operational reports, run after Bronze / Silver / Gold builds.
SELECT 'bronze_orders' AS entity, COUNT(*) AS row_count
FROM {{catalog}}.shoppulse_bronze.olist_orders_raw
UNION ALL SELECT 'silver_orders', COUNT(*) FROM {{catalog}}.shoppulse_silver.orders_clean
UNION ALL SELECT 'silver_rejected_orders', COUNT(*) FROM {{catalog}}.shoppulse_silver.orders_rejected
UNION ALL SELECT 'bronze_items', COUNT(*) FROM {{catalog}}.shoppulse_bronze.olist_order_items_raw
UNION ALL SELECT 'silver_items', COUNT(*) FROM {{catalog}}.shoppulse_silver.order_items_clean
UNION ALL SELECT 'silver_rejected_items', COUNT(*) FROM {{catalog}}.shoppulse_silver.order_items_rejected
UNION ALL SELECT 'gold_items', COUNT(*) FROM {{catalog}}.shoppulse_gold.fact_order_item;

-- Business key checks.
SELECT order_id, COUNT(*) AS repetitions
FROM {{catalog}}.shoppulse_silver.orders_clean
GROUP BY order_id HAVING COUNT(*) > 1;

SELECT order_id, order_item_id, COUNT(*) AS repetitions
FROM {{catalog}}.shoppulse_silver.order_items_clean
GROUP BY order_id, order_item_id HAVING COUNT(*) > 1;

-- Reconciliation differences are SIGNALS to investigate, not proof of fraud.
SELECT * FROM {{catalog}}.shoppulse_gold.order_payment_reconciliation
WHERE ABS(difference_brl) > 0.01
ORDER BY ABS(difference_brl) DESC;

