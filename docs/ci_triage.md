# GitHub Actions CI status

**Status (2026-11-19): blocked before job execution.** GitHub did not start the `python-tests` runner in the observed runs; this is an account-level Actions restriction, **not a Python test failure**. No test assertions or Spark workloads ran. Private account configuration details are intentionally omitted from this public repository.

- [Latest observed run](https://github.com/ravikiran1512/shoppulse-databricks-lakehouse/actions/runs/44515535404)
- The GitHub Actions workflow is configured in `.github/workflows/ci.yml`.
- No green CI claim should be made until GitHub successfully starts the job and both steps pass.

## Resolution checklist

1. Resolve the GitHub account-level restriction using the account's private settings or GitHub Support. Do not publish billing information or credentials in repository issues.
2. Rerun the workflow from GitHub Actions when job execution has been re-enabled.
3. Review actual `Compile Python source` and `Unit tests` steps for any code errors, fix if needed, and require a green run.
4. Independently validate Databricks ingestion, transformations, data quality, and deployment in a supported workspace.

## Reproduce locally while CI is blocked

```bash
python --version  # Python 3.11+
python -m compileall -q src tests pipelines
python -m unittest discover -s tests -v
```

These are standard-library checks only. They do not prove Databricks SQL, Spark, Lakeflow, or bundle execution.
