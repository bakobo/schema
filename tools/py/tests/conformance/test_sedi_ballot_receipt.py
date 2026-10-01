"""sedi-ballot-receipt: a clerk's receipt for mail-in ballot packet possession (`this.i` @3l8uwufr)."""

import copy
import json
from pathlib import Path

import jsonschema
import pytest

from schematools.said import compute_schema_said, saidify_sad

ROOT = Path(__file__).resolve().parents[4]
FOLDER = ROOT / "sedi-ballot-receipt"
ATTRIBUTES = {"d", "u", "i", "election", "packet", "request", "exchange", "heldAt", "basis"}


def _schema() -> dict:
    return json.loads((FOLDER / "sedi-ballot-receipt.schema.json").read_text())


def _example() -> dict:
    return json.loads((FOLDER / "example.json").read_text())


def _validate(instance: dict) -> None:
    jsonschema.Draft202012Validator(
        _schema(), format_checker=jsonschema.Draft202012Validator.FORMAT_CHECKER).validate(instance)


def _refused(instance: dict) -> None:
    with pytest.raises(jsonschema.ValidationError):
        _validate(instance)


def test_the_schema_names_itself_and_is_registered() -> None:
    schema = _schema()
    assert compute_schema_said(schema) == schema["$id"]
    registry = json.loads((ROOT / "registry.json").read_text())
    assert registry[schema["$id"]] == "sedi-ballot-receipt/sedi-ballot-receipt.schema.json"
    assert schema["version"] == "1.0.0"
    assert schema["credentialType"] == "SEDI_Ballot_Packet_Receipt"


def test_the_example_validates_and_is_saidified() -> None:
    example = _example()
    _validate(example)
    assert example["s"] == _schema()["$id"]
    assert saidify_sad(example) == example
    assert example["i"] != example["a"]["i"], "the clerk issues to the presenting holder"


def test_the_attribute_section_carries_nothing_about_the_voter_or_the_ballot() -> None:
    """No voter attribute, no ballot content: exactly the receipt's own fields (@3l8uwufr)."""
    block = _schema()["properties"]["a"]["oneOf"][1]
    assert set(block["properties"]) == ATTRIBUTES
    assert set(block["required"]) == ATTRIBUTES
    assert block["additionalProperties"] is False


def test_the_receipt_has_no_edge_to_the_presented_credential_and_no_extra_sections() -> None:
    schema = _schema()
    assert "e" not in schema["properties"]
    assert schema["additionalProperties"] is False
    instance = _example()
    instance["e"] = {"d": instance["d"]}
    _refused(instance)


@pytest.mark.parametrize("field", sorted(ATTRIBUTES))
def test_every_attribute_is_required(field: str) -> None:
    instance = _example()
    del instance["a"][field]
    _refused(instance)


@pytest.mark.parametrize("field", ["v", "t", "d", "i", "rd", "s", "a"])
def test_top_level_required(field: str) -> None:
    instance = _example()
    del instance[field]
    _refused(instance)


@pytest.mark.parametrize("field", ["givenName", "familyName", "birthDate", "choice", "ballot"])
def test_no_voter_or_ballot_attribute_is_admitted(field: str) -> None:
    instance = _example()
    instance["a"][field] = "x"
    _refused(instance)


def test_the_compact_attribute_section_validates() -> None:
    instance = _example()
    instance["a"] = instance["a"]["d"]
    _validate(instance)


@pytest.mark.parametrize("where", ["top", "block"])
@pytest.mark.parametrize("nonce", ["", "0A" + "x" * 21])
def test_a_nonce_shorter_than_a_128_bit_salt_is_refused(where: str, nonce: str) -> None:
    """A printed packet identifier is guessable, so the attribute nonce must really blind it."""
    instance = _example()
    (instance if where == "top" else instance["a"])["u"] = nonce
    _refused(instance)


@pytest.mark.parametrize("field", ["election", "packet", "request", "exchange", "basis"])
def test_an_empty_identifier_is_refused(field: str) -> None:
    instance = _example()
    instance["a"][field] = ""
    _refused(instance)


@pytest.mark.parametrize("value", ["2026-11-17", "2026-11-17T09:00:00", "yesterday",
                                   "2026-11-17T09:00:00+0000"])
def test_held_at_is_an_rfc_3339_date_time(value: str) -> None:
    instance = _example()
    instance["a"]["heldAt"] = value
    _refused(instance)


def test_a_wrong_message_type_is_refused() -> None:
    instance = copy.deepcopy(_example())
    instance["t"] = "bar"
    _refused(instance)


def test_every_negative_fixture_is_refused_and_pins_this_schema() -> None:
    fixtures = sorted((FOLDER / "invalid").glob("*.json"))
    assert len(fixtures) >= 4
    for path in fixtures:
        instance = json.loads(path.read_text())
        assert instance["s"] == _schema()["$id"], path.name
        _refused(instance)


def test_the_page_names_what_is_deliberately_absent() -> None:
    text = (FOLDER / "index.md").read_text()
    for phrase in ("voter attribute", "edge", "ballot card", "SEDI Management AID"):
        assert phrase in text, phrase
