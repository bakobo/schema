"""Tier C's ward, guardian, and authorization graph follows the #1550 direction."""

import copy
import json
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[4]
CORE = "EAyyREL1r5OL8Z9HGl47df26rn_JRLsC7PVDBH5RtwLs"


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


def test_ward_core_inherits_sam_core_optional_message_type() -> None:
    core = load("sedi-core", "sedi-core.schema.json")
    ward = load("sedi-ward-core", "sedi-ward-core.schema.json")
    example = load("sedi-ward-core", "example.json")
    assert "t" not in core["required"]
    assert "t" not in ward["required"]
    assert ward["properties"]["t"] == core["properties"]["t"]
    assert "t" not in example
    Draft202012Validator(ward).validate(example)


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


def test_the_tier_c_examples_form_one_coherent_graph() -> None:
    """Codex on #15: a re-pin must not collapse guardian and ward into one AID.

    Gal (Sam Smith's guardian in keripy 9a8b7aa7) is the guardian and Guy is the ward.
    """
    guardian = load("sedi-guardian", "example.json")
    ward_core = load("sedi-ward-core", "example.json")
    authz = load("sedi-ward-authz", "example.json")
    gal = "EIaSWASllNlAuAFcDG1xbXGEkVw_oL0CX8_o1XkFTegY"
    guy = "EDB8gKNwzurf33pV2hsyGR9XFOmitDhc0LUzDamcU2JR"
    assert (guardian["a"]["i"], guardian["a"]["ward"]["i"]) == (gal, guy)
    assert guardian["e"]["citizen"]["n"] == "EA4iEqsUF-Fu6aT1DgBkqPWeT3Rw0W367veAkYSCkRMV"  # Gal's Core
    assert ward_core["a"]["i"] == guy
    assert ward_core["e"]["guardian"]["n"] == guardian["d"]
    assert (authz["i"], authz["a"]["i"]) == (gal, guy)
    assert authz["e"]["authority"]["n"] == guardian["d"]
    assert authz["e"]["subject"]["n"] == ward_core["d"]
