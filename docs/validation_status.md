# Test evidence: known, not assumed

As of 2026-11-19:

| Check | Evidence | Status |
|---|---|---|
| Previous orders file uploaded to Bronze | Student executed `COPY INTO` with exact 99,441 count | **Observed in Databricks earlier** |
| Previous orders rerun idempotency | Student reran and reported 99,441 unique orders and one distinct source file | **Observed in Databricks earlier** |
| Delta UPDATE / time travel lesson | Student verified Delivered current vs Pending v1 | **Observed in Databricks earlier** |
| Expanded eight-file ingestion | New SQL scripts added to GitHub | **Not yet run in Databricks** |
| Silver/Gold CTAS | Implemented; no actual runtime results | **Not yet run in Databricks** |
| Synthetic inventory | Deterministic generator and SQL files provided | **Not yet run against Databricks** |
| AUTO CDC / Auto Loader | Example pipeline sources prepared | **Not yet configured/executed** |
| Declarative bundle | YAML definition prepared | **CLI validation/deployment pending** |
| Data quality in Spark | Python runtime quality gates prepared | **Integration test pending** |
| Static Python checks | GitHub workflow configured | **Check CI run result on GitHub** |
| Performance benchmarks | No timing or query-profile evidence | **Not measured** |
| Governance controls | Read-only samples and guide | **Not deployed** |

Do not transform “script committed” into “pipeline executed” on a resume. Save sanitized SQL outputs and job run IDs only after verifying actual success.

