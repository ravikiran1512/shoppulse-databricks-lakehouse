-- ShopPulse: delivered-order daily revenue reference query
-- Business question: daily revenue, order count, and distinct purchasing
-- customers, considering only Delivered orders.

SELECT
    order_date,
    COUNT(*) AS total_orders,
    SUM(amount) AS total_revenue,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM shoppulse_dev.orders_raw
WHERE status = 'Delivered'
GROUP BY order_date
ORDER BY order_date ASC;
