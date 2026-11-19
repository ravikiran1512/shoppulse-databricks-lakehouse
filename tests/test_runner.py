"""Pure-Python safety tests: Spark integration runs in Databricks, not CI."""
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
from shoppulse import runner


class SqlRunnerTests(unittest.TestCase):
    def test_catalog_validation(self):
        self.assertEqual(runner.validate_catalog("workspace"), "workspace")
        self.assertEqual(runner.validate_catalog("retail_dev_1"), "retail_dev_1")
        for candidate in ["prod;DROP SCHEMA x", "a.b", "a-b", "", "1catalog"]:
            with self.subTest(candidate=candidate):
                with self.assertRaises(ValueError):
                    runner.validate_catalog(candidate)

    def test_sql_render(self):
        sql = "SELECT * FROM {{catalog}}.shoppulse_silver.orders_clean;"
        self.assertIn("workspace.shoppulse_silver",
                      runner.render_sql(sql, "workspace"))

    def test_statement_splitting_quoted_semicolons(self):
        sql = "-- first; comment\nSELECT 'a;b' AS x;\nSELECT 'it''s;ok' AS y;"
        chunks = runner.split_sql(sql)
        self.assertEqual(len(chunks), 2)
        self.assertIn("'a;b'", chunks[0])
        self.assertIn("'it''s;ok'", chunks[1])

    def test_script_files_exist_and_render(self):
        for group in runner.SCRIPT_GROUPS.values():
            for filename in group:
                with self.subTest(filename=filename):
                    source = (ROOT / "sql" / filename).read_text()
                    rendered = runner.render_sql(source, "workspace")
                    self.assertNotIn("{{catalog}}", rendered)
                    self.assertTrue(runner.split_sql(rendered))

    def test_order_item_grain_and_payment_guardrail(self):
        gold = (ROOT / "sql" / "30_gold_model.sql").read_text()
        self.assertIn("order_item_id", gold)
        self.assertIn("GROUP BY order_id", gold)
        self.assertIn("fact_order_payment", gold)


if __name__ == "__main__":
    unittest.main()

