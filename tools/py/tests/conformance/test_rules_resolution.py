"""Every externally addressed governance revision remains retrievable by SAID."""

import json
import hashlib
from pathlib import Path

from schematools.repo import discover_schemas, load_registry
from schematools.said import saidify_sad

ROOT = Path(__file__).resolve().parents[4]
HISTORICAL_ARTIFACTS = {
    "sedi-guardian-2.0.0/rules.json": (
        "EOW7nnASAYoY72gJ7brJwE0V2Hm8o6RfZvN2gNeyKmO0",
        "5ba1331e20718a920895d41fb547b2bb6f067f220973f31ff626e7b2590965f2",
    ),
    "sedi-id-2.0.0/rules.json": (
        "EA5O9z0TB932sm8kJIVdAIpwLpEWRWC5--VNS5r69frn",
        "d92f07ef59c895360712d9a16b644790dfc96578786ce0721d7afeddb16e5d1d",
    ),
}


def test_rules_saids_resolve_to_unchanged_artifacts() -> None:
    registry = load_registry(ROOT)
    artifacts: dict[str, set[str]] = {}
    for path in ROOT.glob("*/rules*.json"):
        rules = json.loads(path.read_text())
        assert saidify_sad(rules) == rules, path
        artifacts.setdefault(rules["d"], set()).add(path.relative_to(ROOT).as_posix())

    referenced = {said for said, _ in HISTORICAL_ARTIFACTS.values()}
    for entry in discover_schemas(ROOT):
        for path in entry.path.parent.rglob("*.json"):
            stack = [json.loads(path.read_text())]
            while stack:
                node = stack.pop()
                if isinstance(node, dict):
                    r = node.get("r")
                    if isinstance(r, str) and r.startswith("E") and len(r) == 44:
                        referenced.add(r)
                    stack.extend(node.values())
                elif isinstance(node, list):
                    stack.extend(node)
    for said, rel in registry.items():
        if Path(rel).name.startswith("rules"):
            referenced.add(said)
            assert rel in artifacts.get(said, set())

    assert referenced <= artifacts.keys(), f"Unresolvable rules SAIDs: {sorted(referenced - artifacts.keys())}"
    for rel, (said, digest) in HISTORICAL_ARTIFACTS.items():
        assert registry[said] == rel
        assert hashlib.sha256((ROOT / rel).read_bytes()).hexdigest() == digest
