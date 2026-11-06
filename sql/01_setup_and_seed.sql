-- ShopPulse, Module 1 / Lesson 1
-- Select YOUR WRITABLE WORKSPACE CATALOG in Databricks SQL Editor first.
-- Run these statements individually, in order.
-- The INSERT must only be run once on an EMPTY table.

CREATE SCHEMA IF NOT EXISTS shoppulse_dev;

CREATE TABLE IF NOT EXISTS shoppulse_dev.orders_raw (
    order_id INT,
    customer_id INT,
    order_date DATE,
    status STRING,
    amount DECIMAL(10, 2)
)
USING DELTA;

-- Verify this returns 0 before executing the INSERT.
SELECT COUNT(*) AS existing_rows
FROM shoppulse_dev.orders_raw;

-- SEED ONCE: rerunning creates duplicate orders.
INSERT INTO shoppulse_dev.orders_raw
    (order_id, customer_id, order_date, status, amount)
VALUES
    (1001, 101, DATE '2026-11-01', 'Delivered', 250.00),
    (1002, 102, DATE '2026-11-01', 'Delivered', 200.00),
    (1003, 101, DATE '2026-11-02', 'Cancelled', 100.00),
    (1004, 103, DATE '2026-11-02', 'Delivered', 150.00),
    (1005, 104, DATE '2026-11-02', 'Pending', 90.00),
    (1006, 101, DATE '2026-11-02', 'Delivered', 300.00),
    (1007, 104, DATE '2026-11-03', 'Delivered', 120.00);

SELECT *
FROM shoppulse_dev.orders_raw
ORDER BY order_id;
