"""Tier C's ward, guardian, and authorization graph follows the #1550 direction."""

import copy
import json
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[4]
CORE = "ECxPtf9IpBUT1pRZK4eaLA8O2jlc1oXYioYjcHo09eUC"


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


def test_the_wards_core_reaches_its_guardianship_through_sams_guardians_group() -> None:
    """@hxqwde3o: the ward's identity is Sam Smith's Core (keripy 80f77b73), whose optional
    guardians edge group names the guardianship by NI2I; Bakobo's ward-core is superseded."""
    guardian = load("sedi-guardian", "example.json")
    core = load("sedi-core", "sedi-core.schema.json")
    ward = load("sedi-core", "examples/wyn-ward.json")
    group = core["properties"]["e"]["oneOf"][1]["properties"]["guardians"]
    assert set(group["properties"]) == {"d", "u", "o", "first", "second", "third", "fourth"}
    Draft202012Validator(core).validate(ward)
    first = ward["e"]["guardians"]["first"]
    assert (first["n"], first["s"], first["o"]) == (guardian["d"], guardian["s"], "NI2I")
    assert ward["e"]["guardians"]["o"] == "OR"
    assert ward["a"]["primary"] is False
    assert "Superseded" in (ROOT / "sedi-ward-core" / "index.md").read_text()


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
    ward = load("sedi-core", "examples/wyn-ward.json")
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

    Gal (Sam Smith's guardian) is the guardian and Wyn, Sam's ward, is the ward (@hxqwde3o).
    """
    guardian = load("sedi-guardian", "example.json")
    ward_core = load("sedi-core", "examples/wyn-ward.json")
    authz = load("sedi-ward-authz", "example.json")
    gal = "EIaSWASllNlAuAFcDG1xbXGEkVw_oL0CX8_o1XkFTegY"
    wyn = "EKr8JLtfqWCmHrxO3yu8ocS2n9o0Tlspeaqm9ZOf3FM1"
    assert (guardian["a"]["i"], guardian["a"]["ward"]["i"]) == (gal, wyn)
    gal_core = load("sedi-core", "examples/gal.json")  # Sam's issued vector for Gal
    assert gal_core["a"]["i"] == gal and gal_core["s"] == CORE
    assert (guardian["e"]["citizen"]["n"], guardian["e"]["citizen"]["s"]) == (gal_core["d"], CORE)
    assert ward_core["a"]["i"] == wyn and ward_core["s"] == CORE
    assert ward_core["e"]["guardians"]["first"]["n"] == guardian["d"]
    assert (authz["i"], authz["a"]["i"]) == (gal, wyn)
    assert authz["e"]["subject"]["s"] == CORE
    assert authz["e"]["authority"]["n"] == guardian["d"]
    assert authz["e"]["subject"]["n"] == ward_core["d"]
