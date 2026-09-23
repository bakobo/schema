"""The Bakobo Summit age and holder-presentation profiles chain to Sam's Core."""

import json
from pathlib import Path

import pytest

from schematools.said import saidify_sad

ROOT = Path(__file__).resolve().parents[4]
CORE = "ELNhZbCUiafPrMFnL2vRGEjylRu8zug-3M-goUft8bfh"
RESIDENCE = "EEgFNN1XH90koG5J5pbXKlRNU6TnibizaTQmJcRfEcop"


def _load(name: str, filename: str) -> dict:
    return json.loads((ROOT / name / filename).read_text())


@pytest.mark.parametrize("name,version", [("sedi-age", "3.0.0"), ("sedi-present-age-portrait", "4.0.0")])
def test_new_major_version_chains_to_core(name: str, version: str) -> None:
    schema = _load(name, f"{name}.schema.json")
    example = _load(name, "example.json")
    assert schema["version"] == version
    assert schema["properties"]["e"]["oneOf"][1]["properties"]["identity"]["oneOf"][1]["properties"]["s"]["const"] == CORE
    assert example["e"]["identity"]["s"] == CORE
    assert example["s"] == schema["$id"]
    assert _load(f"{name}-2.0.0", f"{name}-2.0.0.schema.json")["version"] == "2.0.0"


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
