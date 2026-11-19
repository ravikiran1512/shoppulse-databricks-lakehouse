"""Run ordered, parameterized Databricks Spark SQL scripts.

This runner intentionally uses stdlib only until it starts a SparkSession:
local CI can validate configuration without requiring Spark or Databricks.
Run as a Databricks serverless Spark Python task or in an attached notebook.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re

PROJECT_ROOT = Path(__file__).resolve().parents[2]
SCRIPT_GROUPS = {
    "ingest": ["10_bronze_setup.sql", "11_bronze_copy_into.sql"],
    "audit": ["12_bronze_audit.sql"],
    "silver": ["20_silver_orders.sql", "21_silver_items.sql",
               "22_silver_reference.sql", "23_silver_reviews.sql"],
    "gold": ["30_gold_model.sql", "31_gold_metrics.sql"],
}
CATALOG_RE = re.compile(r"^[A-Za-z_][A-Za-z_0-9]*$")


def validate_catalog(value: str) -> str:
    """Never concatenate untrusted SQL identifiers into Spark SQL."""
    if not CATALOG_RE.fullmatch(value):
        raise ValueError("Catalog must be a single safe identifier (letters, digits, _).")
    return value


def render_sql(sql: str, catalog: str) -> str:
    return sql.replace("{{catalog}}", validate_catalog(catalog))


def split_sql(sql: str) -> list[str]:
    """Split our SQL files on semicolons, respecting quoted SQL string literals.

    This is NOT a general SQL parser: do not add stored procedures or multiline
    strings containing semicolons without adopting a real parser.
    """
    source = "\n".join(
        line for line in sql.splitlines()
        if line.strip() and not line.lstrip().startswith("--")
    )
    parts: list[str] = []
    buf: list[str] = []
    quoted = False
    i = 0
    while i < len(source):
        char = source[i]
        if char == "'":
            buf.append(char)
            if quoted and i + 1 < len(source) and source[i + 1] == "'":
                buf.append("'")
                i += 2
                continue
            quoted = not quoted
        elif char == ";" and not quoted:
            if "".join(buf).strip():
                parts.append("".join(buf).strip())
            buf = []
        else:
            buf.append(char)
        i += 1
    if quoted:
        raise ValueError("Unterminated single-quoted SQL literal")
    if "".join(buf).strip():
        parts.append("".join(buf).strip())
    return parts


def run_script(spark, file_name: str, catalog: str) -> None:
    path = PROJECT_ROOT / "sql" / file_name
    statements = split_sql(render_sql(path.read_text(encoding="utf-8"), catalog))
    print(f"[ShopPulse] {file_name}: {len(statements)} SQL statements")
    for index, statement in enumerate(statements, start=1):
        print(f"[ShopPulse] executing {file_name} statement {index}")
        # Spark SQL DDL and DML trigger execution here.
        spark.sql(statement)


def quality_checks(spark, catalog: str) -> None:
    """Fail the job if fundamental key and referential contracts are violated."""
    bronze = f"{catalog}.shoppulse_bronze"
    silver = f"{catalog}.shoppulse_silver"
    gold = f"{catalog}.shoppulse_gold"

    def scalar(query: str) -> int:
        return int(spark.sql(query).first()[0])

    if scalar(f"SELECT COUNT(*) FROM {bronze}.olist_orders_raw") == 0:
        raise AssertionError("Bronze orders is empty: check source uploads")
    if scalar(f"SELECT COUNT(*) FROM {silver}.orders_clean") == 0:
        raise AssertionError("Silver orders is empty")
    if scalar(f"SELECT COUNT(*) FROM {gold}.fact_order_item") == 0:
        raise AssertionError("Gold fact_order_item is empty")

    checks = {
        "duplicate_silver_order_id": f"""
            SELECT COUNT(*) FROM (
              SELECT order_id FROM {silver}.orders_clean
              GROUP BY order_id HAVING COUNT(*) > 1
            ) t""",
        "duplicate_silver_item_key": f"""
            SELECT COUNT(*) FROM (
              SELECT order_id, order_item_id FROM {silver}.order_items_clean
              GROUP BY order_id, order_item_id HAVING COUNT(*) > 1
            ) t""",
        "orphan_silver_items": f"""
            SELECT COUNT(*) FROM {silver}.order_items_clean i
            LEFT JOIN {silver}.orders_clean o ON i.order_id = o.order_id
            WHERE o.order_id IS NULL""",
        "invalid_silver_item_price": f"""
            SELECT COUNT(*) FROM {silver}.order_items_clean
            WHERE item_price_brl IS NULL OR item_price_brl <= 0
               OR freight_brl IS NULL OR freight_brl < 0""",
        "duplicate_gold_item_key": f"""
            SELECT COUNT(*) FROM (
              SELECT order_id, order_item_id FROM {gold}.fact_order_item
              GROUP BY order_id, order_item_id HAVING COUNT(*) > 1
            ) t""",
    }
    failures = {}
    for name, query in checks.items():
        result = scalar(query)
        print(f"[ShopPulse][quality] {name}={result}")
        if result != 0:
            failures[name] = result
    print(f"[ShopPulse][quality] rejected_orders="
          f"{scalar(f'SELECT COUNT(*) FROM {silver}.orders_rejected')}")
    print(f"[ShopPulse][quality] rejected_items="
          f"{scalar(f'SELECT COUNT(*) FROM {silver}.order_items_rejected')}")
    if failures:
        raise AssertionError(f"Data contract failures: {failures}")
    print("[ShopPulse] Quality gates passed (not a full financial reconciliation)")


def execute_stage(spark, stage: str, catalog: str) -> None:
    catalog = validate_catalog(catalog)
    if stage == "all":
        for step in ("ingest", "silver", "gold", "quality"):
            execute_stage(spark, step, catalog)
        return
    if stage == "quality":
        quality_checks(spark, catalog)
        return
    for name in SCRIPT_GROUPS[stage]:
        run_script(spark, name, catalog)


def main() -> None:
    parser = argparse.ArgumentParser(description="ShopPulse Databricks SQL pipeline")
    parser.add_argument("--catalog", default="workspace")
    parser.add_argument("--stage", choices=(*SCRIPT_GROUPS, "quality", "all"),
                        default="all")
    args = parser.parse_args()
    catalog = validate_catalog(args.catalog)
    from pyspark.sql import SparkSession  # Import only inside Databricks runtime
    spark = SparkSession.builder.getOrCreate()
    execute_stage(spark, args.stage, catalog)


if __name__ == "__main__":
    main()

