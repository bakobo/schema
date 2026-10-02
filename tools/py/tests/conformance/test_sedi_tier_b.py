"""The Bakobo Summit age and holder-presentation profiles chain to Sam's Core."""

import json
from pathlib import Path

import pytest

from schematools.said import saidify_sad

ROOT = Path(__file__).resolve().parents[4]
CORE = "EAyyREL1r5OL8Z9HGl47df26rn_JRLsC7PVDBH5RtwLs"
RESIDENCE = "EH7ayivQLHwfBKwFhg7mcpOzHEWcvvJ24EO0OyzvPVKQ"
AGE = "EH-ZOEzzWm5hw351zL3IBJiEMDnJiKrv17lQp2JFj8Sb"


def _load(name: str, filename: str) -> dict:
    return json.loads((ROOT / name / filename).read_text())


def test_the_portrait_presentation_chains_to_core_and_sams_age() -> None:
    schema = _load("sedi-present-age-portrait", "sedi-present-age-portrait.schema.json")
    example = _load("sedi-present-age-portrait", "example.json")
    edges = schema["properties"]["e"]["oneOf"][1]["properties"]
    assert schema["version"] == "4.0.0"
    assert edges["identity"]["oneOf"][1]["properties"]["s"]["const"] == CORE
    assert edges["age"]["oneOf"][1]["properties"]["s"]["const"] == AGE
    assert example["e"]["identity"]["s"] == CORE
    assert example["e"]["age"]["s"] == AGE
    assert example["s"] == schema["$id"]
    assert _load("sedi-present-age-portrait-2.0.0", "sedi-present-age-portrait-2.0.0.schema.json")["version"] == "2.0.0"


def test_sams_age_replaces_ours_and_ours_is_archived_as_superseded() -> None:
    """@3x2jtfxc: Sam's Age at keripy 9a8b7aa7 is the current sedi-age; Bakobo's 3.0.0 profile stays resolvable."""
    sams = _load("sedi-age", "sedi-age.schema.json")
    ours = _load("sedi-age-3.0.0", "sedi-age-3.0.0.schema.json")
    registry = json.loads((ROOT / "registry.json").read_text())
    assert sams["$id"] == AGE
    assert ours["version"] == "3.0.0"
    assert registry[ours["$id"]] == "sedi-age-3.0.0/sedi-age-3.0.0.schema.json"
    assert "Superseded" in (ROOT / "sedi-age-3.0.0" / "index.md").read_text()
    example = _load("sedi-age", "example.json")
    core = _load("sedi-core", "example.json")
    edge = example["e"]["coreIdentity"]
    assert (edge["n"], edge["s"], edge["o"]) == (core["d"], CORE, ["E1E", "NI2I"])
    assert example["A"][1]["i"] == core["a"]["i"]


def test_age_uses_sam_envelope_sections() -> None:
    props = _load("sedi-age", "sedi-age.schema.json")["properties"]
    assert [arm["type"] for arm in props["s"]["oneOf"]] == ["string", "object"]
    assert [arm["type"] for arm in props["r"]["oneOf"]] == ["string", "object"]
    assert set(props["r"]["oneOf"][1]["required"]) == {"d", "l"}


def test_county_presentation_links_core_and_residence() -> None:
    schema = _load("sedi-present-county", "sedi-present-county.schema.json")
    example = _load("sedi-present-county", "example.json")
    edges = schema["properties"]["e"]["oneOf"][1]["properties"]
    assert schema["version"] == "2.0.0"
    assert set(edges) >= {"identity", "residence"}
    assert edges["identity"]["oneOf"][1]["properties"]["s"]["const"] == CORE
    assert edges["residence"]["oneOf"][1]["properties"]["s"]["const"] == RESIDENCE
    assert example["e"]["identity"]["s"] == CORE
    assert example["e"]["residence"]["s"] == RESIDENCE


def test_county_presentation_example_matches_its_source_credentials() -> None:
    presentation = _load("sedi-present-county", "example.json")
    core = _load("sedi-core", "example.json")
    residence = _load("sedi-residence", "example.json")
    for label, source in (("identity", core), ("residence", residence)):
        edge = presentation["e"][label]
        assert (edge["n"], edge["s"]) == (source["d"], source["s"])
        assert presentation["i"] == source["a"]["i"]
    assert saidify_sad(presentation) == presentation
    assert presentation["a"]["county"] == residence["a"]["county"]["value"]


@pytest.mark.parametrize("name", ["sedi-age", "sedi-present-age-portrait", "sedi-present-county", "sedi-guardian"])
def test_current_bakobo_sedi_profiles_have_no_v1_inner_schema_ids(name: str) -> None:
    schema = _load(name, f"{name}.schema.json")
    assert '"$id"' not in json.dumps(schema["properties"])
