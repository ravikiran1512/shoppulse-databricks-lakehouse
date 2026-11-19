-- Dimensional model. Fact grain: one order line (order_id, order_item_id).
-- DO NOT join raw payment rows to item rows before aggregation: 1:N x 1:N fanout.
CREATE OR REPLACE TABLE {{catalog}}.shoppulse_gold.dim_customer
USING DELTA AS
SELECT customer_id, customer_unique_id, customer_city, customer_state
FROM {{catalog}}.shoppulse_silver.customers_clean;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_gold.dim_product
USING DELTA AS
SELECT p.product_id, p.category_pt,
       COALESCE(t.category_en, p.category_pt, 'unknown') AS category_name,
       p.weight_g, p.length_cm, p.height_cm, p.width_cm
FROM {{catalog}}.shoppulse_silver.products_clean p
LEFT JOIN {{catalog}}.shoppulse_silver.category_translation t
  ON p.category_pt = t.category_pt;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_gold.dim_seller
USING DELTA AS
SELECT seller_id, seller_city, seller_state
FROM {{catalog}}.shoppulse_silver.sellers_clean;

CREATE OR REPLACE TABLE {{catalog}}.shoppulse_gold.fact_order_item
USING DELTA AS
SELECT i.order_id, i.order_item_id, i.product_id, i.seller_id,
       o.customer_id, o.order_status, o.purchased_at,
       TO_DATE(o.purchased_at) AS purchase_date,
       o.delivered_at, o.estimated_delivery_at,
       i.item_price_brl, i.freight_brl,
       CAST(i.item_price_brl + i.freight_brl AS DECIMAL(18,2)) AS gross_line_charge_brl
FROM {{catalog}}.shoppulse_silver.order_items_clean i
INNER JOIN {{catalog}}.shoppulse_silver.orders_clean o
  ON i.order_id = o.order_id;

-- Payments are aggregated at order grain BEFORE any reconciliation join.
CREATE OR REPLACE TABLE {{catalog}}.shoppulse_gold.fact_order_payment
USING DELTA AS
SELECT order_id, COUNT(*) AS payment_part_count,
       CAST(SUM(payment_value_brl) AS DECIMAL(18,2)) AS paid_amount_brl,
       CONCAT_WS(', ', SORT_ARRAY(COLLECT_SET(payment_type))) AS payment_types
FROM {{catalog}}.shoppulse_silver.payments_clean
GROUP BY order_id;

