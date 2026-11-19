# Verified learning log & implementation record

## Completed earlier in Databricks Free Edition
- **Module 1, Lesson 1:** `workspace.default.orders_raw` Delta table, seven synthetic orders, daily `COUNT(*)`/`SUM`/`COUNT(DISTINCT)` results matching the exercise; certification quiz 2/3.
- **Module 1, Lesson 2:** `DESCRIBE DETAIL` and `DESCRIBE HISTORY`; `UPDATE` created table version 2; order 9001 shown as Delivered currently and Pending using `VERSION AS OF 1`; certification quiz 2/3.
- **Module 1, Lesson 3:** three UC schemas created (`shoppulse_bronze` / `silver` / `gold`); original Olist orders source profiled at 99,441 total and unique order IDs; `COPY INTO` uploaded same count to `workspace.shoppulse_bronze.olist_orders_raw` and second invocation did not duplicate rows.
- **Module 1, Lesson 3, Exercise 3D:** ingestion and profiling of order items was assigned, **not yet reported complete**.

## This repository expansion — November 19, 2026
- Authored batch ingestion for eight Olist CSVs, Bronze table DDL, Silver cleaning/quarantine, Gold facts and business metrics.
- Added a Spark SQL runner with data-contract quality gates, bundle workflow, static CI, analytic SQL and optional synthetic inventory + CDC + Lakeflow examples.
- Added data contracts, architecture, security/operations documentation, runbook and revised Oct 9, 2026 exam mapping.

## Next validation milestone
Upload remaining Olist CSVs to the existing Bronze volume, then execute the SQL files in runbook order. Capture quarantined counts, Gold grain checks, actual bundle validation and any runtime errors. Commit **verified fixes** and report measured outputs; avoid fictitious success metrics.

### Source data notice
The downloaded Kaggle source files are on the learner's computer/workspace; they were **not** uploaded into this ChatGPT session and are not available for direct execution here.

