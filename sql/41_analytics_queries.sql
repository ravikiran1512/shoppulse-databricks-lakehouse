-- Dashboard examples: never sum payment rows after a 1:N order-item join.
SELECT * FROM {{catalog}}.shoppulse_gold.daily_delivered_sales
ORDER BY purchase_date DESC LIMIT 30;

-- Monthly delivered merchandise sales, BRL.
SELECT DATE_TRUNC('MONTH', purchase_date) AS purchase_month,
       SUM(delivered_orders) AS orders_per_day_sum,
       SUM(item_sales_brl) AS item_sales_brl
FROM {{catalog}}.shoppulse_gold.daily_delivered_sales
GROUP BY DATE_TRUNC('MONTH', purchase_date)
ORDER BY purchase_month;

-- Top categories by gross merchandise value (item price only).
SELECT COALESCE(p.category_name, 'unknown') AS category,
       COUNT(*) AS sold_lines,
       CAST(SUM(f.item_price_brl) AS DECIMAL(20,2)) AS sold_value_brl
FROM {{catalog}}.shoppulse_gold.fact_order_item f
LEFT JOIN {{catalog}}.shoppulse_gold.dim_product p ON f.product_id = p.product_id
WHERE f.order_status = 'delivered'
GROUP BY COALESCE(p.category_name, 'unknown')
ORDER BY sold_value_brl DESC LIMIT 20;

-- Customer value by repeat purchases (customer_unique_id, not per-order customer_id).
SELECT customer_unique_id, delivered_orders, delivered_item_sales_brl
FROM {{catalog}}.shoppulse_gold.customer_lifetime_value
WHERE delivered_orders >= 2
ORDER BY delivered_item_sales_brl DESC LIMIT 30;

