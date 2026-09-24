"""foreign-evidence: what a reissuer checked on a foreign credential (`this.i` @vho4mibp)."""

import copy
import json
from pathlib import Path

import jsonschema
import pytest

from schematools.said import compute_schema_said, saidify_sad

ROOT = Path(__file__).resolve().parents[4]
FOLDER = ROOT / "foreign-evidence"
CHECKS = ["size-bound", "framing", "typ", "x5t-thumbprint", "chain", "certificate-revocation",
          "signature", "time-window", "issuer-binding", "disclosure-digests", "key-binding",
          "status-list"]


def _schema() -> dict:
    return json.loads((FOLDER / "foreign-evidence.schema.json").read_text())


def _example() -> dict:
    return json.loads((FOLDER / "example.json").read_text())


def _validate(instance) -> None:
    jsonschema.Draft202012Validator(_schema(), format_checker=jsonschema.FormatChecker()).validate(
        instance)


def _refused(instance) -> None:
    with pytest.raises(jsonschema.ValidationError):
        _validate(instance)


def test_the_schema_names_itself_and_is_registered() -> None:
    schema = _schema()
    assert compute_schema_said(schema) == schema["$id"]
    registry = json.loads((ROOT / "registry.json").read_text())
    assert registry[schema["$id"]] == "foreign-evidence/foreign-evidence.schema.json"
    assert schema["version"] == "1.0.0"


def test_every_check_is_pinned_in_order_with_an_outcome() -> None:
    """Copilot on #12: the whole vocabulary, each {name, outcome}, one position per check."""
    checks = _schema()["properties"]["a"]["oneOf"][1]["properties"]["checks"]
    assert [item["properties"]["name"]["const"] for item in checks["prefixItems"]] == CHECKS
    assert checks["items"] is False and checks["minItems"] == len(CHECKS)
    for item in checks["prefixItems"]:
        assert item["properties"]["outcome"]["enum"] == ["passed", "not-performed"]
        assert item["required"] == ["name", "outcome"]


def test_the_example_records_every_check():
    checks = _example()["a"]["checks"]
    assert [c["name"] for c in checks] == CHECKS
    assert {c["outcome"] for c in checks} == {"passed", "not-performed"}


def test_the_example_validates_and_is_saidified() -> None:
    example = _example()
    _validate(example)
    assert example["s"] == _schema()["$id"]
    assert saidify_sad(example) == example
    assert example["u"] and example["a"]["u"]


def test_the_example_carries_no_claim_value() -> None:
    """Nothing from the foreign credential but its type, issuer and chain (@vho4mibp)."""
    attributes = _example()["a"]
    assert set(attributes) <= {"d", "u", "i", "dt", "format", "credentialType", "foreignIssuer",
                               "issuerChain", "trustAnchor", "checks", "caveats", "verifiedAt"}


@pytest.mark.parametrize("mutate", [
    lambda a: a["checks"][0].update(outcome="failed"),
    lambda a: a["checks"][0].update(outcome="skipped"),
    lambda a: a["checks"][0].update(name="vibes"),
    lambda a: a["checks"].pop(),
    lambda a: a["checks"].append({"name": "signature", "outcome": "passed"}),
    lambda a: a["checks"].reverse(),
    lambda a: a["checks"][0].pop("outcome"),
    lambda a: a["checks"][0].update(note="extra"),
    lambda a: a.update(checks=[c["name"] for c in a["checks"]]),
    lambda a: a.update(checks=[]),
    lambda a: a.update(format="jwt"),
    lambda a: a.update(verifiedAt="yesterday"),
    lambda a: a["issuerChain"][0].update(sha256="nothex"),
    lambda a: a.update(issuerChain=[]),
    lambda a: a.update(givenName="Testsson"),
    lambda a: a["trustAnchor"].pop("sha256"),
    lambda a: a.pop("checks"),
    lambda a: a.pop("i"),
    lambda a: a.update(caveats=["not a code"]),
], ids=["outcome-failed", "outcome-unknown", "unknown-check", "missing-check", "extra-check",
        "reordered", "no-outcome", "extra-member", "bare-names", "no-checks", "bad-format", "bad-time",
        "bad-digest", "empty-chain", "claim-value", "anchor-no-digest", "missing-checks",
        "missing-issuee", "bad-caveat"])
def test_anything_else_is_refused(mutate) -> None:
    instance = copy.deepcopy(_example())
    mutate(instance["a"])
    _refused(instance)


@pytest.mark.parametrize("field", ["rd", "u", "r", "a"])
def test_top_level_required(field: str) -> None:
    instance = _example()
    del instance[field]
    _refused(instance)


@pytest.mark.parametrize("section", ["a", "r"])
def test_compact_sections_validate(section: str) -> None:
    instance = _example()
    instance[section] = instance[section]["d"]
    _validate(instance)


def test_rules_are_the_published_rules_document() -> None:
    rules = json.loads((FOLDER / "rules.json").read_text())
    assert saidify_sad(rules) == rules
    assert _example()["r"] == rules


def test_every_negative_fixture_is_refused_and_pins_this_schema() -> None:
    fixtures = sorted((FOLDER / "invalid").glob("*.json"))
    assert len(fixtures) >= 6
    for path in fixtures:
        instance = json.loads(path.read_text())
        assert instance["s"] == _schema()["$id"], path.name
        _refused(instance)
