# Operator runbook — ShopPulse from zero to Gold

## Prerequisites

- Databricks workspace with a writable Unity Catalog catalog. Examples default to `workspace`.
- All eight Olist CSVs downloaded from Kaggle; keep exact original names. Do not commit them.
- UC volume file upload permission; SQL Warehouse for manual SQL; serverless Jobs and Databricks CLI for bundle route (optional).
- Do not assume a successful local unit test means Databricks execution has passed.

## Path A — Manually run in SQL Editor (most accessible in Free Edition)

**1. Setup.** Open `sql/10_bronze_setup.sql`, replace all `{{catalog}}` with `workspace`, run the statements in SQL Editor in order. Existing `workspace.default` learning tables are not touched.

**2. Upload.** In Catalog Explorer open `workspace.shoppulse_bronze.source_files`. Upload all eight files to the root of the volume. Exact paths:

```text
/Volumes/workspace/shoppulse_bronze/source_files/olist_orders_dataset.csv
/Volumes/workspace/shoppulse_bronze/source_files/olist_order_items_dataset.csv
/Volumes/workspace/shoppulse_bronze/source_files/olist_customers_dataset.csv
/Volumes/workspace/shoppulse_bronze/source_files/olist_products_dataset.csv
/Volumes/workspace/shoppulse_bronze/source_files/olist_sellers_dataset.csv
/Volumes/workspace/shoppulse_bronze/source_files/olist_order_payments_dataset.csv
/Volumes/workspace/shoppulse_bronze/source_files/olist_order_reviews_dataset.csv
/Volumes/workspace/shoppulse_bronze/source_files/product_category_name_translation.csv
```

**3. Ingest.** Run `sql/11_bronze_copy_into.sql`, then profile `sql/12_bronze_audit.sql`. Do not force-reload files; the normal COPY INTO behavior tracks loaded files.

**4. Silver.** Run `sql/20_silver_orders.sql`, then `21_silver_items.sql`, `22_silver_reference.sql` and `23_silver_reviews.sql`. Keep the statements within each file on the same SQL session because the script creates and uses temporary views. Silver creates cleansed tables and reject tables; it DOES NOT delete source rows.

**5. Gold.** Run `sql/30_gold_model.sql` then `31_gold_metrics.sql`. Verify `fact_order_item` uniqueness, daily sales, delivery performance and payment reconciliation.

**6. Checks.** Run `sql/40_monitoring_checks.sql`; query `sql/41_analytics_queries.sql`. Before publicizing results, run the Python quality stage in Databricks or equivalent SQL checks.

## Path B — Databricks CLI / Declarative Automation Bundle

1. [Install Databricks CLI](https://docs.databricks.com/aws/en/dev-tools/cli/install). Authenticate securely (`databricks auth login --host <workspace-url>`). Never commit local config or personal access tokens.
2. Clone this GitHub repository and open its root.
3. Upload the eight source CSVs as above.
4. Run `databricks bundle validate -t dev --var catalog=workspace`.
5. Run `databricks bundle deploy -t dev --var catalog=workspace`.
6. Run `databricks bundle run shoppulse_batch -t dev --var catalog=workspace` and inspect four task runs: `ingest` → `silver` → `gold` → `quality`.
7. If bundle validation fails due to workspace-specific serverless capability or permissions, stop and use Path A; do not improvise broad access grants.

The job sources are `src/shoppulse/runner.py` and `sql/*.sql`. It uses a serverless environment v2 and no hardcoded credentials. No schedule is enabled by default.

## Required verification evidence

- Bronze row counts and distinct keys, including source file provenance.
- Current `orders_clean` and `order_items_clean` row counts; reason breakdown of both quarantine tables.
- Zero repeated `order_id` in clean orders and zero repeated (`order_id`, `order_item_id`) in clean items.
- Zero item orphans and invalid money values post-cleaning.
- Gold item fact counts match valid Silver items; reconciliation differences investigated.
- Save sanitized query outputs, not personal workspace IDs or emails.

## Optional operational labs

- `python tools/generate_inventory.py` → upload `data/generated/inventory_movements.jsonl` to the volume → execute `sql/60_inventory_pipeline.sql` to see revisions, duplicate events, quarantine, and warehouse net movement.
- `sql/61_cdc_merge_lab.sql` provides an isolated rerun-safe SCD1 MERGE exercise. It intentionally resets its own lab table.
- `pipelines/inventory_autoloader.py` is an optional Lakeflow Pipeline source that needs an inventory stream directory and a configured `shoppulse.inventory_source` pipeline setting.
- `pipelines/customer_preferences_cdc.py` is an **independent** optional Lakeflow Pipeline SCD2 CDC example. Generate `tools/generate_customer_cdc.py` output, upload to a CDC directory, configure `shoppulse.cdc_source`, and run with supported pipeline capacity. These examples are not auto-deployed by the batch bundle.

## Recovering safely

- Missing file: check exact spelling/case and the volume path; confirm the first 10 rows with `read_files`.
- COPY INTO schema failure: inspect raw CSV header and destination columns. Do **not** `force = true` or drop tables blindly.
- Repeated business keys: inspect Silver ranking and quarantine; do not remove Bronze records.
- Stale Gold: rerun Silver→Gold→quality after reviewing input data. Because CTAS is per-table, partial builds require repair.
- Poor performance: compare query profiles and use `EXPLAIN FORMATTED` before choosing clustering or optimization.
- Permission error: request targeted volume/catalog/table privileges from an authorized admin; never use tokens in notebooks or public GitHub.

