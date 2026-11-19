# ShopPulse implementation and operationalization plan

**Current phase:** A multi-source retail lakehouse implementation is committed. The primary remaining work is execution, reconciliation, troubleshooting and performance measurement in a supported Databricks workspace.

| Workstream | Repository deliverable | Runtime status |
|---|---|---|
| SQL and Delta reference queries | `sql/01–03` | Verified against example tables |
| Bronze ingestion | `sql/10–12`, eight Olist source contracts | Original orders file verified; remaining sources pending |
| Silver cleaning and quarantine | `sql/20–23` | Needs full Databricks run |
| Gold dimensional and analytical models | `sql/30–31` | Needs output verification |
| Monitoring and data quality | `runner.py` and `sql/40–41` | Pending live task validation |
| Warehouse movement simulation | Deterministic generator and `sql/60` | Pending |
| Incremental changes and history | `sql/61` and Lakeflow `AUTO CDC` example | Pending |
| Batch orchestration | `databricks.yml` and `resources/job.yml` | Bundle validate/deploy/run pending |
| Streaming ingestion | Separate Auto Loader pipeline | Pending pipeline configuration |
| Optimization and governance | `sql/70–72`, policies and operational docs | Not benchmarked or deployed |
| Continuous integration | GitHub Actions and Python tests | Runner blocked before test execution; see `docs/ci_triage.md` |

## Next execution sequence

1. Confirm all eight Olist source CSV files are present under the configured Unity Catalog volume.
2. Execute Bronze loads, audit counts, and verify file-level rerun safety.
3. Build Silver and Gold datasets; validate uniqueness, payment reconciliation and quarantine counts.
4. Run the Job bundle in a development environment and document any configuration or SQL fixes.
5. Verify the CI runner, then add workspace-based integration tests without exposing secrets.
6. Configure and observe inventory/CDC and streaming examples as distinct workloads.
7. Benchmark representative queries and document **measured** optimization results.
8. Publish sanitized technical evidence, accurate architecture diagrams and a clear operational status.

The [capability register](engineering_capabilities.md) details code coverage, limitations, and production hardening. A compliant enterprise rollout would additionally require authenticated connectors, approved privacy and security policies, deployment approval, reliability monitoring, and incident response.

