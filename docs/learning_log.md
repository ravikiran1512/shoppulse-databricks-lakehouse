# Verified learning log

## Module 1, Lesson 1 — Databricks SQL basics

**Completed in the student's Databricks Free Edition workspace.**

- Created `workspace.default.orders_raw` as a Delta table.
- Inserted 7 fictional orders.
- Wrote a `Delivered`-only daily aggregation using `COUNT(*)`, `SUM(amount)`, `COUNT(DISTINCT customer_id)`, `WHERE`, `GROUP BY`, and `ORDER BY`.
- Observed the expected daily result: 450.00, 450.00, 120.00, with order counts 2, 2, 1.
- Quiz: 2/3 correct. Area to review: purpose of Delta Lake versus traditional databases.

## Module 1, Lesson 2 — Delta Lake history

**Completed in the student's Databricks Free Edition workspace.**

- Used `DESCRIBE DETAIL` to verify Delta format for `workspace.default.orders_raw`.
- Observed initial history version 1, operation `WRITE`.
- Created `workspace.default.orders_history_practice_01` and inserted two fictional orders.
- Updated order 9001 from `Pending` to `Delivered`.
- Confirmed an `UPDATE` at version 2 with `numUpdatedRows = 1`.
- Queried current state (`Delivered`) and version 1 (`Pending`) without restoring the table.
- Quiz: 2/3 correct. Area to review: atomicity (a failed transaction does not partially commit).

## Current limitations

- No automated CI or large-scale pipeline has been implemented yet.
- The checked-in SQL standardizes examples under `shoppulse_dev`, whereas hands-on results were observed in `workspace.default`.
- History outputs were intentionally summarized to avoid exposing account information.

## Next checkpoint

Module 1, Lesson 3: Medallion architecture, data grain, and the first Bronze/Silver/Gold schema design.
