"""The retained Bakobo governance artifact is usable in Sam-shaped r blocks."""

import json
from pathlib import Path

from schematools.said import saidify_sad

ROOT = Path(__file__).resolve().parents[4]


def test_standalone_governance_rules_have_sam_r_shape() -> None:
    rules = json.loads((ROOT / "sedi-id/rules.json").read_text())
    assert set(rules) == {"d", "l"}
    assert rules["l"]
    assert saidify_sad(rules) == rules
