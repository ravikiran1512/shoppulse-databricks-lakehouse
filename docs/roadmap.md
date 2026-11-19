# ShopPulse completion and certification roadmap (updated Nov 2026)

The **full reference implementation is checked in**, while full end-to-end verification remains outstanding.

| Milestone | Repository deliverable | Workspace verification |
|---|---|---|
| Foundational SQL and Delta history | `sql/01–03`, original docs | Learner verified |
| Full Bronze ingestion (8 CSVs) | `sql/10–12` | Orders done earlier; remaining inputs pending |
| Silver cleaning and quarantine | `sql/20–23` | Pending |
| Gold dimensional/analytical tables | `sql/30–31` | Pending |
| Monitoring and quality checks | `runner.py`, `sql/40–41` | Pending |
| Warehouse net movement simulation | generator, `sql/60` | Pending |
| Incremental CDC and SCD | `sql/61`, Lakeflow AUTO CDC example | Pending |
| Batch orchestration | `databricks.yml`, `resources/job.yml` | Pending bundle validate/run |
| Streaming ingestion | Lakeflow Auto Loader example | Pending pipeline setup |
| Performance, VARIANT, security | `sql/70–72` and docs | Conceptual/optional exercises |
| CI/test foundation | GitHub Actions, stdlib tests | Confirm GitHub workflow on first commit |
| Professional exam map | `docs/exam_matrix.md` | Full nine-domain plan, not a completion claim |

Further enterprise subjects (Lakehouse Federation, Clean Rooms, controlled ABAC deployments, REST/SDK, real CDC connectors, advanced incident response and large-scale profiling) are deliberately marked **not deployed**. The exam mapping describes how to study them, rather than misrepresenting exercise code as production operations.

