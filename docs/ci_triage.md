# CI troubleshooting checkpoint — 2026-11-19

**Observed GitHub Actions result:** the first static/unit-test workflow run did not pass. Retrying the failed job also ended in failure. The connector reported job `python-tests` as failed, but returned **no job steps**, and GitHub job-log download returned a missing log blob (404). Therefore the exact root cause **has not been established**.

- [Observed run](https://github.com/ravikiran1512/shoppulse-databricks-lakehouse/actions/runs/44513153251)
- A red CI run is **not evidence that the Spark SQL pipeline failed**: that pipeline has not been executed by this GitHub workflow.
- A red CI run is **also not evidence that tests passed**. Do not represent CI as green until it is.

## Reproduce locally
Clone the repository, then run:

```bash
python --version  # Python 3.11+ required
python -m compileall -q src tests pipelines
python -m unittest discover -s tests -v
```

These are pure Python checks; no Spark runtime, Databricks CLI, network access, or private CSVs are required. They validate scaffolding, not business transformation output.

## Diagnose the failure in GitHub
1. Open the observed Actions run above; expand the `python-tests` job.
2. If the run has **no executed steps**, inspect repository `Settings → Actions → General` (whether Actions and the referenced `actions/checkout` and `actions/setup-python` are allowed), account billing/runner availability and any banner message. Do not assume a code syntax issue without logs.
3. If checkout or setup-python failed, use the exact step logs to diagnose external runner/action issues.
4. If `Compile Python source` failed, copy the file path/line to an issue, fix and rerun.
5. If `Unit tests` failed, copy the failing assertion traceback, reproduce the test locally and fix the relevant code.
6. Keep credentials out of any public issue or screenshot.

## What's needed before production claims
- Green local and GitHub static CI with documented test evidence.
- Databricks bundle validation, full Olist data ingestion, Silver/Gold runtime integration tests, DQ outcome and measured performance.

