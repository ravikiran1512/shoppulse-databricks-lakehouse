"""Deterministic local synthetic data tests without Spark or external packages."""
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import generate_inventory
import generate_customer_cdc


class SyntheticGeneratorTests(unittest.TestCase):
    def test_inventory_is_deterministic(self):
        first = generate_inventory.generate()
        self.assertEqual(first, generate_inventory.generate())
        self.assertEqual(len(first), 753)

    def test_inventory_anomalies_are_intentional(self):
        events = generate_inventory.generate()
        ids = [x["event_id"] for x in events]
        self.assertLess(len(set(ids)), len(ids))
        self.assertTrue(any(e["qty_delta"] == "invalid" for e in events))
        self.assertTrue(any(e["source_version"] == "2" for e in events))

    def test_customer_cdc_sequence(self):
        changes = generate_customer_cdc.events()
        self.assertEqual(len(changes), 5)
        self.assertTrue(any(x["op"] == "D" for x in changes))


if __name__ == "__main__":
    unittest.main()

