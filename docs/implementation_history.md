# Implementation history and verified milestones

## Initial Delta / SQL proof of concept

- Created `workspace.default.orders_raw` as a Delta table and populated seven synthetic order records.
- Executed daily aggregation using `COUNT(*)`, `SUM(amount)`, `COUNT(DISTINCT customer_id)`, `WHERE`, `GROUP BY` and `ORDER BY`; verified expected outputs.
- Inspected transaction metadata and history with `DESCRIBE DETAIL` and `DESCRIBE HISTORY`.
- Updated an isolated Delta order and verified the new status in the current table while an earlier `VERSION AS OF 1` query returned the original status.

## First Olist Bronze ingestion

- Created the `shoppulse_bronze`, `shoppulse_silver` and `shoppulse_gold` schemas.
- Profiled historical Olist order source: **99,441 total rows and 99,441 distinct non-null order IDs**.
- Ingested the orders CSV into `workspace.shoppulse_bronze.olist_orders_raw` with `COPY INTO`.
- Re-executed ingestion; row count remained **99,441** with one distinct source file.
- The order-items file was identified as the next source but its successful ingestion was **not reported or independently verified**.

## Expanded repository implementation — November 19, 2026

- Added SQL scripts for eight Olist Bronze tables, file ingestion, profiling, typed Silver transformations and rejected-row handling.
- Added Gold fact and dimension tables, delivery and sales metrics and payment reconciliation.
- Introduced a Spark SQL runner, uniqueness and referential checks, deployment bundle and four-task batch workflow.
- Added synthetic inventory movement and CDC generators, separate Auto Loader/SCD Type 2 pipeline examples, and governance/performance SQL.
- Documented source grain, metric definitions, deployment steps, incident recovery and validation limitations.

## Verification backlog

The expanded multi-source pipeline **has not been executed end to end in Databricks**. Capture source/target counts, rejected-row distributions, exact Gold outputs, bundle validation, job-run results, CI test logs and query-performance profiles before describing these as demonstrated operating results.

### Data availability

The Olist CSVs were downloaded locally and uploaded to the user's Databricks workspace; they were not supplied as files in this repository. Source data is intentionally excluded from the public Git history to protect private and third-party information.

