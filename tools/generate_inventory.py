"""Generate reproducible SYNTHETIC warehouse events (never pretend Olist contains stock).

Run: python tools/generate_inventory.py
Output: data/generated/inventory_movements.jsonl; upload into Bronze source_files volume.
"""
from __future__ import annotations
import json
from pathlib import Path
import random
from datetime import datetime, timedelta, timezone

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "data" / "generated" / "inventory_movements.jsonl"


def generate(seed: int = 2026) -> list[dict]:
    rng = random.Random(seed)
    events = []
    start = datetime(2026, 11, 1, tzinfo=timezone.utc)
    for i in range(750):
        warehouse = f"WH{rng.randint(1, 5):02d}"
        sku = f"SKU{rng.randint(1, 60):04d}"
        movement = rng.choice(["receipt", "dispatch", "return"])
        quantity = rng.randint(1, 20) * (-1 if movement == "dispatch" else 1)
        ts = start + timedelta(hours=rng.randint(0, 600))
        events.append({
            "event_id": f"M{i+1:05d}",
            "warehouse_id": warehouse,
            "sku_id": sku,
            "event_ts": ts.isoformat(),
            "movement_type": movement,
            "qty_delta": str(quantity),
            "source_version": "1",
        })
    # Deliberate anomalies for Silver/quarantine exercises.
    events.append(dict(events[0]))  # duplicate same event_id
    broken = dict(events[1])
    broken["event_id"] = "M_BAD"
    broken["qty_delta"] = "invalid"
    events.append(broken)
    correction = dict(events[2])
    correction["qty_delta"] = "9"
    correction["source_version"] = "2"
    events.append(correction)  # same event_id, later version wins
    return events


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT.open("w", encoding="utf-8") as file:
        for item in generate():
            file.write(json.dumps(item, sort_keys=True) + "\n")
    print(f"Generated {OUTPUT} ({len(generate())} events)")


if __name__ == "__main__":
    main()

