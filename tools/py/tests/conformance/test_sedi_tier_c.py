"""Tier C's ward, guardian, and authorization graph follows the #1550 direction."""

import copy
import json
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[4]
CORE = "ED7zRxzpuvv89c6jDwgyBNOoW06Ut0wm_8jJQRqKYv_5"


def load(name: str, filename: str) -> dict:
    return json.loads((ROOT / name / filename).read_text())


def test_guardian_ward_is_disclosable_and_not_an_edge() -> None:
    schema = load("sedi-guardian", "sedi-guardian.schema.json")
    example = load("sedi-guardian", "example.json")
    assert schema["version"] == "3.0.0"
    attrs = schema["properties"]["a"]["oneOf"][1]
    assert {"scope", "powers", "ward"} <= set(attrs["required"])
    assert [arm["type"] for arm in attrs["properties"]["ward"]["oneOf"]] == ["string", "object"]
    edges = schema["properties"]["e"]["oneOf"][1]["properties"]
    assert "subject" not in edges
    assert edges["citizen"]["oneOf"][1]["properties"]["s"]["const"] == CORE
    assert edges["citizen"]["oneOf"][1]["properties"]["o"]["const"] == "E1E"
    compacted = copy.deepcopy(example)
    compacted["a"]["ward"] = example["a"]["ward"]["d"]
    Draft202012Validator(schema).validate(compacted)
    missing = copy.deepcopy(example)
    del missing["a"]["ward"]
    assert not Draft202012Validator(schema).is_valid(missing)
    assert load("sedi-guardian-2.0.0", "sedi-guardian-2.0.0.schema.json")["version"] == "2.0.0"


def test_ward_core_has_ni2i_guardianship_edge() -> None:
    guardian = load("sedi-guardian", "sedi-guardian.schema.json")
    schema = load("sedi-ward-core", "sedi-ward-core.schema.json")
    example = load("sedi-ward-core", "example.json")
    edge = schema["properties"]["e"]["oneOf"][1]["properties"]["guardian"]["oneOf"][1]["properties"]
    assert edge["s"]["const"] == guardian["$id"]
    assert edge["o"]["const"] == "NI2I"
    assert example["e"]["guardian"]["n"] == load("sedi-guardian", "example.json")["d"]


def test_guardian_issues_separately_revocable_ward_authorization() -> None:
    guardian = load("sedi-guardian", "example.json")
    ward = load("sedi-ward-core", "example.json")
    schema = load("sedi-ward-authz", "sedi-ward-authz.schema.json")
    example = load("sedi-ward-authz", "example.json")
    assert "rd" in schema["required"]
    assert example["i"] == guardian["a"]["i"]
    assert example["a"]["i"] == ward["a"]["i"]
    edges = schema["properties"]["e"]["oneOf"][1]["properties"]
    assert edges["authority"]["oneOf"][1]["properties"]["o"]["const"] == "I2I"
    assert edges["subject"]["oneOf"][1]["properties"]["o"]["const"] == "E1E"
    assert example["e"]["authority"]["n"] == guardian["d"]
    assert example["e"]["subject"]["n"] == ward["d"]
    assert isinstance(example["a"]["authz"]["rc"], list)
