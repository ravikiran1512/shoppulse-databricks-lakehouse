-- These measures are HISTORICAL BRL gross merchandise metrics, NOT GAAP revenue.
-- Delivered-order item totals are distinguished from payment receipts and refunds.
CREATE OR REPLACE TABLE {{catalog}}.shoppulse_gold.daily_delivered_sales
USING DELTA AS
SELECT purchase_date,
       COUNT(DISTINCT order_id) AS delivered_orders,
       COUNT(*) AS delivered_items,
       CAST(SUM(item_price_brl) AS DECIMAL(20,2)) AS item_sales_brl,
       CAST(SUM(freight_brl) AS DECIMAL(20,2)) AS freight_brl,
       CAST(SUM(gross_line_charge_brl) AS DECIMAL(20,2)) AS gross_charge_brl
FROM {{catalog}}.shoppulse_gold.fact_order_item
WHERE order_status = 'delivered'
GROUP BY purchase_date;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_gold.customer_lifetime_value
USING DELTA AS
SELECT c.customer_unique_id,
       COUNT(DISTINCT f.order_id) AS delivered_orders,
       CAST(SUM(f.item_price_brl) AS DECIMAL(20,2)) AS delivered_item_sales_brl,
       MIN(f.purchased_at) AS first_purchase_at,
       MAX(f.purchased_at) AS last_purchase_at
FROM {{catalog}}.shoppulse_gold.fact_order_item f
INNER JOIN {{catalog}}.shoppulse_gold.dim_customer c
  ON f.customer_id = c.customer_id
WHERE f.order_status = 'delivered'
GROUP BY c.customer_unique_id;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_gold.delivery_performance
USING DELTA AS
SELECT TO_DATE(purchased_at) AS purchase_date,
       COUNT(*) AS delivered_orders,
       SUM(CASE WHEN delivered_at > estimated_delivery_at THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * SUM(CASE WHEN delivered_at > estimated_delivery_at THEN 1 ELSE 0 END)
                / NULLIF(COUNT(*), 0), 2) AS late_delivery_pct,
       ROUND(AVG(DATEDIFF(TO_DATE(delivered_at), TO_DATE(purchased_at))), 2) AS avg_delivery_days
FROM {{catalog}}.shoppulse_silver.orders_clean
WHERE order_status = 'delivered' AND delivered_at IS NOT NULL
  AND estimated_delivery_at IS NOT NULL
GROUP BY TO_DATE(purchased_at);

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_gold.order_payment_reconciliation
USING DELTA AS
WITH item_totals AS (
 SELECT order_id,
        CAST(SUM(gross_line_charge_brl) AS DECIMAL(20,2)) AS line_total_brl
 FROM {{catalog}}.shoppulse_gold.fact_order_item
 GROUP BY order_id
)
SELECT i.order_id, o.order_status, i.line_total_brl, p.paid_amount_brl,
       CAST(p.paid_amount_brl - i.line_total_brl AS DECIMAL(20,2)) AS difference_brl
FROM item_totals i
JOIN {{catalog}}.shoppulse_silver.orders_clean o ON i.order_id = o.order_id
LEFT JOIN {{catalog}}.shoppulse_gold.fact_order_payment p ON i.order_id = p.order_id;

