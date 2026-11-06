-- ShopPulse, Module 1 / Lesson 2
-- Separate, disposable *practice* table, not production orders_raw.
-- Start with a fresh table. Run each statement individually and only once.
-- If the CREATE says the table already exists, stop rather than replacing it.

CREATE TABLE shoppulse_dev.orders_history_practice_01 (
    order_id INT,
    status STRING,
    amount DECIMAL(10, 2)
)
USING DELTA;

INSERT INTO shoppulse_dev.orders_history_practice_01
VALUES
    (9001, 'Pending', 200.00),
    (9002, 'Pending', 150.00);

-- Before the update: 9001 is Pending.
SELECT * FROM shoppulse_dev.orders_history_practice_01 ORDER BY order_id;

UPDATE shoppulse_dev.orders_history_practice_01
SET status = 'Delivered'
WHERE order_id = 9001;

-- After the update: 9001 is Delivered, 9002 remains Pending.
SELECT * FROM shoppulse_dev.orders_history_practice_01 ORDER BY order_id;

-- Newest commit first; expect an UPDATE with one updated row.
DESCRIBE HISTORY shoppulse_dev.orders_history_practice_01;

-- If DESCRIBE HISTORY shows the pre-update WRITE was version 1,
-- this read-only query returns the original Pending value.
-- Otherwise substitute the version number immediately BEFORE UPDATE.
SELECT *
FROM shoppulse_dev.orders_history_practice_01 VERSION AS OF 1
WHERE order_id = 9001;

-- Do NOT run RESTORE or VACUUM for this exercise.
