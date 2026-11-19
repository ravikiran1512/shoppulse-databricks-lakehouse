# Databricks Data Engineer Professional (Oct 9, 2026) coverage matrix

**Source of truth:** [Official Databricks exam guide, published October 9, 2026](https://www.databricks.com/sites/default/files/2026-10/Databricks-Certified-Data-Engineer-Professional-Exam-Guide-9-Oct-2026.pdf). **60 scored multiple-choice questions, 120 minutes, nine domains.** Previous versions of our learning roadmap referenced the older 10-domain / 59-question exam and should be considered superseded.

| Official domain | Weight | ShopPulse coverage | Hands-on proof status |
|---|---:|---|---|
| 1. Developing Code for Data Processing using Python and SQL | 23% | `src/shoppulse/runner.py`, `sql/20-41`, declarative bundle, Auto Loader, AUTO CDC examples | Core code committed; only initial SQL exercises workspace-verified |
| 2. Data Ingestion & Acquisition | 12% | `COPY INTO` for 8 Olist sources; JSONL inventory; Auto Loader example | First orders COPY INTO verified previously; remaining ingestion pending |
| 3. Data Manipulation | 12% | `TRY_CAST`, window dedup, joins, aggregations, `VARIANT` examples, Silver quarantines | Not yet executed end to end |
| 4. Monitoring and Alerting | 10% | Query-based checks, Python job gates, job runbook, system table exercises | Static docs/code only; system tables may be restricted |
| 5. Cost & Performance Optimization | 15% | `EXPLAIN FORMATTED`, optimization lab, data skipping and small-file study | No benchmark measurements claimed |
| 6. Ensuring Data Security and Compliance | 8% | Privilege inspection, access-control template, retention and deletion playbook | Requires administrator and governance testing |
| 7. Data Governance | 5% | UC catalog/schema/volume design, lineage/grain docs, privilege inheritance reading | Catalog/schema exercises verified; advanced governance pending |
| 8. Debugging and Deploying | 10% | Declarative Automation Bundle, four-stage Job, local CI, runbook and recovery scenarios | Bundle not yet validated in live workspace |
| 9. Data Modeling | 5% | Order-item fact, order-level payment fact, customer/product/seller dimensions, daily BI tables | Models coded, not yet query-verified |

Total 100%. These weights are exam-domain weights, **not** a percentage-complete score.

## Advanced exam features that require separate exercises
No honest portfolio should claim one Olist batch pipeline demonstrates **all** Professional objectives. The following are explicit extension labs or research tasks:

- **Compute and dependencies:** serverless environments, wheel dependency conflicts, high-memory tasks, task retries, Python/Pandas/SQL UDFs.
- **Lakeflow:** streaming tables vs materialized views, pipeline expectations drop/fail/quarantine; AUTO CDC SCD1/SCD2; streaming checkpoints and watermarks; foreachBatch semantics; Job If/Else and For Each.
- **Ingestion:** Lakeflow Connect SQL Server/MySQL/PostgreSQL; Kafka/Kinesis/Pub/Sub; Iceberg, binary; OpenSharing, Delta Sharing, Clean Rooms; Lakehouse Federation.
- **Semi-structured/AI:** VARIANT parse_json / variant_get included; `ai_query` shown as a restricted, *non-executed* template (model endpoint required).
- **Observability:** `system.billing.usage` and Lakeflow event logs, Alerts, Databricks SDK/REST APIs, job repair.
- **Optimization:** CDF, deletion vectors, liquid clustering / `CLUSTER BY AUTO`, predictive optimization, caching; compare measured profiles before/after.
- **Privacy/governance:** ABAC policies/tags, row filters, column masks, PII handling, GDPR deletion requests, permission inheritance, materialized views and metric views.
- **Deployment:** Git folders, separate environments, restricted secrets, Databricks CLI and API deployment under approval.

## Suggested study/verification sequence
1. Run all eight Bronze ingestions and capture row counts.
2. Execute Silver/Gold build and rectify any SQL/runtime issues; save sanitized quality evidence.
3. Run and repair the four-stage bundle in an authorized development workspace.
4. Run optional inventory and AUTO CDC SCD2 labs separately, plus failure/restart testing.
5. Measure one slow query using the Databricks query profile, optimize, and report **observed**, not invented, gains.
6. Exercise UC governance with a dedicated test principal if your workspace permissions allow it.
7. Work through every uncovered bullet in the latest official exam guide with short scenario quizzes.

**Exam caveat:** Always recheck the official guide approximately two weeks before sitting the exam, as Databricks can revise its blueprint.

