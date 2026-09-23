"""The current Core accepts compact references and still checks expanded blocks."""

import json
from pathlib import Path

import jsonschema
import pytest


ROOT = Path(__file__).resolve().parents[4]
ATTRIBUTES = (
    "givenName", "middleName", "familyName", "birthDate", "facialImageProof",
    "legalPresenceStatus", "issuedDate", "expirationDate",
)


def _schema() -> dict:
    return json.loads((ROOT / "sedi-core/sedi-core.schema.json").read_text())


def _example() -> dict:
    return json.loads((ROOT / "sedi-core/example.json").read_text())


@pytest.mark.parametrize("name", ATTRIBUTES)
def test_compact_attribute_block_validates(name: str) -> None:
    instance = _example()
    instance["a"][name] = instance["a"][name]["d"]
    jsonschema.Draft202012Validator(_schema()).validate(instance)


def test_compact_utah_agent_edge_validates() -> None:
    instance = _example()
    instance["e"]["utahAgent"] = instance["e"]["utahAgent"]["d"]
    jsonschema.Draft202012Validator(_schema()).validate(instance)


@pytest.mark.parametrize("name", ATTRIBUTES)
def test_expanded_attribute_constraints_survive(name: str) -> None:
    instance = _example()
    del instance["a"][name]["value"]
    with pytest.raises(jsonschema.ValidationError):
        jsonschema.Draft202012Validator(_schema()).validate(instance)


def test_expanded_utah_agent_constraints_survive() -> None:
    instance = _example()
    del instance["e"]["utahAgent"]["n"]
    with pytest.raises(jsonschema.ValidationError):
        jsonschema.Draft202012Validator(_schema()).validate(instance)


@pytest.mark.parametrize("section", ["a", "e"])
def test_compact_section_validates(section: str) -> None:
    instance = _example()
    instance[section] = instance[section]["d"]
    jsonschema.Draft202012Validator(_schema()).validate(instance)


def test_original_core_revision_remains_resolvable() -> None:
    old = json.loads((ROOT / "sedi-core-0.1.0/sedi-core-0.1.0.schema.json").read_text())
    registry = json.loads((ROOT / "registry.json").read_text())
    assert old["$id"] == "ED7zRxzpuvv89c6jDwgyBNOoW06Ut0wm_8jJQRqKYv_5"
    assert registry[old["$id"]] == "sedi-core-0.1.0/sedi-core-0.1.0.schema.json"
