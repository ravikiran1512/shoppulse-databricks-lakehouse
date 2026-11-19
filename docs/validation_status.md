# Test evidence: known, not assumed

As of 2026-11-19:

| Check | Evidence | Status |
|---|---|---|
| Previous orders file uploaded to Bronze | Previously executed `COPY INTO`, exact 99,441 count | **Observed in Databricks earlier** |
| Orders rerun idempotency | Previously reran: 99,441 distinct orders, one source file | **Observed in Databricks earlier** |
| Delta UPDATE / time-travel verification | Delivered current vs Pending version 1 | **Observed in Databricks earlier** |
| Expanded eight-file ingestion | New SQL scripts committed | **Not run in Databricks** |
| Silver/Gold CTAS | Implemented; no runtime results | **Not run in Databricks** |
| Synthetic inventory | Deterministic generator and SQL files provided | **Not run against Databricks** |
| AUTO CDC / Auto Loader | Example pipeline sources prepared | **Not configured/executed** |
| Declarative bundle | YAML definition prepared | **CLI validate/deploy pending** |
| Data quality in Spark | Python quality gates prepared | **Integration test pending** |
| Static Python checks | GitHub workflow run failed twice; logs unavailable | **CI failing; see [CI triage](ci_triage.md)** |
| Performance benchmarks | No timing or query-profile evidence | **Not measured** |
| Governance controls | Read-only samples and guide | **Not deployed** |

Do not transform “script committed” into “pipeline executed” on a resume. Save sanitized SQL outputs and job run IDs only after verifying actual success.

