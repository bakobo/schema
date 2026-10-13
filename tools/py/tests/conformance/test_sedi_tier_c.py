"""Tier C's ward, guardian, and authorization graph follows the #1550 direction."""

import json
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[4]
CORE = "EN0JtdzBmFuTUzyJG9CXZhtdu-bW0V6L95bsVBzi-cY-"
GUARDIAN = "EDJzXg34opr6-odFix6lpiccfHF7ksITHuIES_MQRH4b"
GAL = "EIaSWASllNlAuAFcDG1xbXGEkVw_oL0CX8_o1XkFTegY"
GUY = "EDB8gKNwzurf33pV2hsyGR9XFOmitDhc0LUzDamcU2JR"
WYN = "EKr8JLtfqWCmHrxO3yu8ocS2n9o0Tlspeaqm9ZOf3FM1"


def load(name: str, filename: str) -> dict:
    return json.loads((ROOT / name / filename).read_text())


def test_the_guardianship_is_sams_and_names_the_ward_by_aid() -> None:
    """@6uxg0vj0: Sam Smith's GuardianSchema (keripy 927c0cb8) is the current sedi-guardian.

    The ward is an AID string in the attributes; utahAgent is the only edge. Bakobo's 3.0.0
    profile, with scope, powers, basis, recognition and its citizen edge, stays resolvable.
    """
    schema = load("sedi-guardian", "sedi-guardian.schema.json")
    assert (schema["$id"], schema["version"]) == (GUARDIAN, "0.1.0")
    attrs = schema["properties"]["a"]["oneOf"][1]
    assert set(attrs["required"]) == {"d", "u", "i", "role", "ward", "issuedDate"}
    assert set(attrs["properties"]) == {"d", "u", "i", "rd", "role", "ward", "issuedDate", "expirationDate"}
    assert attrs["properties"]["ward"] == {"description": attrs["properties"]["ward"]["description"], "type": "string"}
    assert set(schema["properties"]["e"]["oneOf"][1]["properties"]) == {"d", "u", "utahAgent"}
    for name, guardian in ((GAL, load("sedi-guardian", "example.json")), (GUY, load("sedi-guardian", "examples/guy.json"))):
        Draft202012Validator(schema).validate(guardian)
        assert (guardian["s"], guardian["a"]["i"], guardian["a"]["ward"], guardian["a"]["role"]) == (GUARDIAN, name, WYN, "parent")
    ours = load("sedi-guardian-pre-927c0cb8-3.0.0", "sedi-guardian-pre-927c0cb8-3.0.0.schema.json")
    assert ours["version"] == "3.0.0" and {"scope", "powers"} <= set(ours["properties"]["a"]["oneOf"][1]["required"])
    assert "Superseded" in (ROOT / "sedi-guardian-pre-927c0cb8-3.0.0" / "index.md").read_text()
    assert load("sedi-guardian-2.0.0", "sedi-guardian-2.0.0.schema.json")["version"] == "2.0.0"


def test_the_wards_core_reaches_both_parent_guardianships_through_sams_guardians_group() -> None:
    """@hxqwde3o, @6uxg0vj0: Wyn's Core is Sam Smith's vector at keripy 927c0cb8, whose guardians
    group is OR over Guy's and Gal's guardianships by NI2I; Bakobo's ward-core stays superseded."""
    core = load("sedi-core", "sedi-core.schema.json")
    ward = load("sedi-core", "examples/wyn-ward.json")
    group = core["properties"]["e"]["oneOf"][1]["properties"]["guardians"]
    assert set(group["properties"]) == {"d", "u", "o", "first", "second", "third", "fourth"}
    Draft202012Validator(core).validate(ward)
    assert ward["e"]["guardians"]["o"] == "OR"
    for label, guardian in (("first", load("sedi-guardian", "examples/guy.json")), ("second", load("sedi-guardian", "example.json"))):
        edge = ward["e"]["guardians"][label]
        assert (edge["n"], edge["s"], edge["o"]) == (guardian["d"], GUARDIAN, "NI2I")
        assert guardian["a"]["ward"] == ward["a"]["i"]
    assert set(ward["e"]["guardians"]) == {"d", "u", "o", "first", "second"}
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

    Guy and Gal are Wyn's parent guardians in Sam Smith's vectors at keripy 927c0cb8 (@6uxg0vj0);
    Gal issues the ward authorization, reaching her guardianship and Wyn's Core.
    """
    guardian = load("sedi-guardian", "example.json")
    ward_core = load("sedi-core", "examples/wyn-ward.json")
    authz = load("sedi-ward-authz", "example.json")
    assert (guardian["a"]["i"], guardian["a"]["ward"]) == (GAL, WYN)
    gal_core = load("sedi-core", "examples/gal.json")  # Sam's issued vector for Gal
    assert gal_core["a"]["i"] == GAL and gal_core["s"] == CORE
    assert ward_core["a"]["i"] == WYN and ward_core["s"] == CORE
    assert ward_core["e"]["guardians"]["second"]["n"] == guardian["d"]
    assert (authz["i"], authz["a"]["i"]) == (GAL, WYN)
    assert (authz["e"]["authority"]["n"], authz["e"]["authority"]["s"]) == (guardian["d"], GUARDIAN)
    assert (authz["e"]["subject"]["n"], authz["e"]["subject"]["s"]) == (ward_core["d"], CORE)
