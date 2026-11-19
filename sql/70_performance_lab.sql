-- Execute only after the Gold pipeline is built. Compare Databricks query profiles.
EXPLAIN FORMATTED
SELECT purchase_date, SUM(item_sales_brl)
FROM {{catalog}}.shoppulse_gold.daily_delivered_sales
WHERE purchase_date BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
GROUP BY purchase_date;

-- Maintenance commands are INTENTIONALLY commented out until you have
-- captured baseline query profile and have appropriate permissions:
-- OPTIMIZE {{catalog}}.shoppulse_gold.fact_order_item;
-- ANALYZE TABLE {{catalog}}.shoppulse_gold.fact_order_item COMPUTE STATISTICS;
-- NEVER use VACUUM RETAIN 0 HOURS for this project.
-- At ~100k orders, speedups may be negligible; do not invent benchmarks.

