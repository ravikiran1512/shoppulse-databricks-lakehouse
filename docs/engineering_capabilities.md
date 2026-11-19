# Engineering capabilities and implementation coverage

This document maps the ShopPulse architecture to concrete data-platform capabilities, the code that implements them, and outstanding runtime verification. It is an engineering scope and evidence register, **not a claim that every component is deployed**.

| Engineering capability | Implementation | Evidence status |
|---|---|---|
| Batch source acquisition | `COPY INTO` for eight Olist CSVs; Unity Catalog managed volume | Original orders source previously verified; remaining sources pending |
| Reliable ingestion | Delta file tracking, source provenance, ingestion timestamp | File-level idempotency verified for the initial orders batch |
| SQL data processing | `TRY_CAST`, joins, CTEs, window functions, aggregate queries | Code committed; full multi-source output pending |
| Data quality | Rejected-row tables; uniqueness and referential checks in `runner.py` | Implemented, end-to-end execution pending |
| Dimensional modeling | Gold order-item fact, payment fact, customer/product/seller dimensions | Models committed, warehouse output pending |
| Business reporting | Daily merchandise sales, customer repeat purchases, late delivery, reconciliation | SQL metrics committed, values not yet verified |
| Operational monitoring | Quality gate task, monitoring SQL, incident runbook | Defined but not yet operated as a live service |
| Performance engineering | `EXPLAIN FORMATTED`, profile-first optimization approach | No measured benchmarks |
| Data governance | Unity Catalog schemas, privilege inspection, security controls plan | Initial schemas verified; advanced access policies not deployed |
| Workflow deployment | Databricks Declarative Automation Bundle and four-stage Job | Bundle validation and live run pending |
| Incremental CDC | Delta `MERGE` scenario and separate Lakeflow `AUTO CDC` SCD2 example | Example code; streaming deployment pending |
| Streaming ingestion | Auto Loader and declarative pipeline source | Example code; pipeline deployment pending |
| Semi-structured data | JSONL inventory, `VARIANT` parsing examples | Source generator and queries committed |
| AI-assisted enrichment | Restricted `ai_query` template | Endpoint and access not configured; not executed |
| Automated tests | GitHub Actions, pure Python tests and Spark quality gates | CI currently failing; see incident record |

## Engineering hardening backlog

### Data correctness
- Validate all eight source files and log exact row-count reconciliation.
- Implement per-source schema contracts, freshness thresholds, and quarantine for reference datasets and payment records.
- Replace secondary-column tie-breaking with a trusted source-event sequence wherever CDC feeds provide one.
- Publish grouped Gold tables only after all related inputs and validations pass.

### Reliability and operations
- Validate the bundle against a supported development workspace and observe actual task retries/recovery.
- Capture job duration, input row counts, invalid-record rates and failure alerts.
- Introduce controlled release/publish steps to prevent partial CTAS refreshes becoming user-visible.

### Security and lifecycle
- Apply least-privilege access, governed tags, masking policies and service identities in an authorized environment.
- Define retention, backup, right-to-erasure handling and approved data-sharing processes.

### Scale and performance
- Build a meaningful benchmark workload, capture a baseline Spark query plan and profile, apply one optimization and measure the outcome.
- Evaluate liquid clustering, file sizes, skew and join strategies based on observed plan metrics, not assumed performance wins.

### Integration breadth
- Configure Auto Loader checkpoints and a streaming pipeline with state recovery.
- Exercise late-arriving changes, idempotent merges, deletion events and an SCD Type 2 history view.
- Consider source connectors and downstream BI delivery only when credentials and operational requirements are available.

## Evidence standard

A file existing in GitHub proves that its **implementation has been committed**, not that the workload has executed successfully. Runtime claims require validated source ingestion, Databricks task outcomes, quality metrics and reproducible evidence. Any performance improvement must be supported by captured query profiles or benchmark measurements.

