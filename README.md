# ShopPulse — Databricks SQL Data Engineering Project

An evolving, hands-on portfolio project for learning **Databricks SQL, Delta Lake, and production data engineering**, aligned with the Databricks Certified Data Engineer Professional learning objectives.

> **Status: Module 1, Lessons 1–2 complete.** This is a learning-in-progress repository, not a completed production pipeline.

## Business problem

ShopPulse is a fictional e-commerce retailer. Operations and finance teams need dependable reporting on orders, revenue, delivery, cancellations, and returns. The eventual goal is a governed, incremental Bronze/Silver/Gold lakehouse that handles duplicate events, late-arriving updates, and historical changes.

The first milestone uses seven synthetic orders to demonstrate SQL reporting and Delta transaction history.

## Tools

- Databricks Free Edition and Databricks SQL Editor
- Spark SQL and Delta Lake
- Unity Catalog (catalog, schema, table organization)
- Planned later: Auto Loader, Lakeflow, Delta CDC, Jobs, monitoring, governance, and Databricks Asset Bundles

No credentials, real customer data, or workspace screenshots are included.

## Repository structure

```text
sql/
  01_setup_and_seed.sql       Create a Delta table and insert seven test orders
  02_daily_revenue.sql        Delivered-order daily revenue query
  03_delta_history_lab.sql   Isolated UPDATE and time-travel practice
docs/
  architecture.md            Proposed lakehouse architecture (not implemented yet)
  learning_log.md            Verified work and learning progress
  roadmap.md                 Next stages toward the professional certification
```

## Reproduce the first two lessons

1. Open **SQL Editor** in a Databricks workspace and select a writable Unity Catalog workspace catalog.
2. Create a **new query tab**. Run each statement separately, not the entire file repeatedly.
3. Run `sql/01_setup_and_seed.sql` once. It creates a dedicated `shoppulse_dev` schema and a managed Delta table. **Do not rerun its INSERT**; that would duplicate the sample rows.
4. Run `sql/02_daily_revenue.sql` and compare the output below.
5. Use a second query tab to follow `sql/03_delta_history_lab.sql`, one statement at a time. **Do not recreate or reseed its practice table after the first successful run.**

The original learning session used `workspace.default.orders_raw` and `workspace.default.orders_history_practice_01`. The checked-in scripts use `shoppulse_dev` to offer a cleaner, reproducible project layout. These organized-schema scripts have not yet been executed against that schema.

### Expected daily revenue result

Only `Delivered` orders count toward these figures; `amount` represents the total order amount in this introductory fixture.

| order_date | total_orders | total_revenue | unique_customers |
| --- | ---: | ---: | ---: |
| 2026-11-01 | 2 | 450.00 | 2 |
| 2026-11-02 | 2 | 450.00 | 2 |
| 2026-11-03 | 1 | 120.00 | 1 |

**Important modeling note:** In later lessons we will calculate financial metrics from the correct order-item/payment grain, handle refunds and currency, and add data quality checks. The sample metric is intentionally simplified.

## Evidence and status

The student ran the initial queries in Databricks Free Edition and verified:

- A Delta-format managed table with seven sample orders.
- The exact three-row daily revenue result shown above.
- A Delta UPDATE that changed one order and committed a new table version.
- A time-travel query that returned the original order status without restoring the table.

See [the learning log](docs/learning_log.md) for the detailed checkpoint. Results were observed in the student's workspace; this repository does not yet include automated integration tests or CI.

## Security and reproducibility

All data is fictional. Never commit Databricks access tokens, `.env` files, full `DESCRIBE HISTORY` output containing account identifiers, or raw personal screenshots. Future examples should use sanitized metadata and parameterized workspace configuration.

## Next milestone

Design a Bronze/Silver/Gold model, introduce realistic e-commerce source tables, and build SQL validation rules. See [the roadmap](docs/roadmap.md).
