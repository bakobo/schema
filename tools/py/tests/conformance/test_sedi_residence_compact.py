"""The current Residence accepts compact references and still checks expanded blocks (@a5kbqzfs)."""

import json
from pathlib import Path

import jsonschema
import pytest

from schematools.said import compute_schema_said

ROOT = Path(__file__).resolve().parents[4]
ATTRIBUTES = (
    "street", "city", "county", "state", "postcode", "country", "issuedDate", "expirationDate",
)
SAM_RESIDENCE = "EEgFNN1XH90koG5J5pbXKlRNU6TnibizaTQmJcRfEcop"


def _schema() -> dict:
    return json.loads((ROOT / "sedi-residence/sedi-residence.schema.json").read_text())


def _example() -> dict:
    return json.loads((ROOT / "sedi-residence/example.json").read_text())


def _validate(instance: dict) -> None:
    jsonschema.Draft202012Validator(_schema()).validate(instance)


def test_the_expanded_example_validates() -> None:
    _validate(_example())


@pytest.mark.parametrize("name", ATTRIBUTES)
def test_compact_attribute_block_validates(name: str) -> None:
    instance = _example()
    instance["a"][name] = instance["a"][name]["d"]
    _validate(instance)


def test_the_county_step_reveals_county_and_withholds_street_and_postcode() -> None:
    instance = _example()
    for name in ATTRIBUTES:
        if name != "county":
            instance["a"][name] = instance["a"][name]["d"]
    assert isinstance(instance["a"]["county"], dict)
    _validate(instance)


def test_compact_core_identity_edge_validates() -> None:
    instance = _example()
    instance["e"]["coreIdentity"] = instance["e"]["coreIdentity"]["d"]
    _validate(instance)


@pytest.mark.parametrize("name", ATTRIBUTES)
def test_expanded_attribute_constraints_survive(name: str) -> None:
    instance = _example()
    del instance["a"][name]["value"]
    with pytest.raises(jsonschema.ValidationError):
        _validate(instance)


@pytest.mark.parametrize("name", ATTRIBUTES)
def test_a_block_is_still_required(name: str) -> None:
    instance = _example()
    del instance["a"][name]
    with pytest.raises(jsonschema.ValidationError):
        _validate(instance)


def test_expanded_core_identity_constraints_survive() -> None:
    instance = _example()
    del instance["e"]["coreIdentity"]["n"]
    with pytest.raises(jsonschema.ValidationError):
        _validate(instance)


@pytest.mark.parametrize("section", ["a", "e"])
def test_compact_section_validates(section: str) -> None:
    instance = _example()
    instance[section] = instance[section]["d"]
    _validate(instance)


def test_the_amendment_is_versioned_and_named_as_bakobos() -> None:
    schema = _schema()
    assert schema["version"] == "0.2.0"
    assert schema["$id"] != SAM_RESIDENCE
    assert _example()["s"] == schema["$id"]


def test_sams_residence_remains_resolvable() -> None:
    old = json.loads((ROOT / "sedi-residence-0.1.0/sedi-residence-0.1.0.schema.json").read_text())
    registry = json.loads((ROOT / "registry.json").read_text())
    assert old["$id"] == SAM_RESIDENCE == compute_schema_said(old)
    assert registry[SAM_RESIDENCE] == "sedi-residence-0.1.0/sedi-residence-0.1.0.schema.json"
    assert registry[_schema()["$id"]] == "sedi-residence/sedi-residence.schema.json"


def test_the_county_presentation_pins_the_current_residence() -> None:
    county = json.loads((ROOT / "sedi-present-county/sedi-present-county.schema.json").read_text())
    edge = county["properties"]["e"]["oneOf"][1]["properties"]["residence"]["oneOf"][1]
    assert edge["properties"]["s"]["const"] == _schema()["$id"]
