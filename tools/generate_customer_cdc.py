"""Generate deterministic, clearly SYNTHETIC CDC events for optional AUTO CDC lab."""
import json
from pathlib import Path

OUTPUT = Path(__file__).resolve().parents[1] / "data/generated/customer_preferences.jsonl"


def events():
    return [
        {"customer_id":"C101","channel":"email","event_ts":"2026-11-01T08:00:00Z","op":"U"},
        {"customer_id":"C102","channel":"sms","event_ts":"2026-11-01T09:00:00Z","op":"U"},
        {"customer_id":"C101","channel":"sms","event_ts":"2026-11-02T08:00:00Z","op":"U"},
        {"customer_id":"C103","channel":"push","event_ts":"2026-11-02T10:00:00Z","op":"U"},
        {"customer_id":"C102","channel":"sms","event_ts":"2026-11-03T08:00:00Z","op":"D"},
    ]


if __name__ == "__main__":
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text("\n".join(json.dumps(e) for e in events()) + "\n")
    print(f"Wrote {len(events())} CDC events to {OUTPUT}")

