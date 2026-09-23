"""SEDI presentations are issued into the holder's presentation registry (`this.i` @lm37js6k).

Sam Smith's Core and Residence name that registry in a.rd, "Issuee Presentation Registry SAID"
(keripy ec307cd74 tests/sedi/test_sedi.py:194, :417). The presentation patterns therefore require
a top-level rd, and the revisions that forbade it stay resolvable by their published SAIDs.
"""

import hashlib
import json
from pathlib import Path

import jsonschema
import pytest

from schematools.said import compute_schema_said, saidify_sad

ROOT = Path(__file__).resolve().parents[4]
PRESENTATIONS = {"sedi-present-county": "2.0.0", "sedi-present-age-portrait": "4.0.0"}
ARCHIVED = (
    ("sedi-present-county", "1.0.0", "EBzm1khKzF5_kasnw3QTKfcycQyqMc3WE6WXW5UM9o2L",
     "464f1e4a2298de77fee0690a63921ace1af0165a30843833ef963ecf0b62be4f"),
    ("sedi-present-age-portrait", "3.0.0", "EGScFnkqFnKv0c8X2yBXKieX7Ya6h7kAPiLz_48YsIL_",
     "dedb0f851e86019354ee7e1e87f90d99d94328ebcd54c8f134d1cd9265c212da"),
)


def _load(relative: str) -> dict:
    return json.loads((ROOT / relative).read_text())


def _schema(name: str) -> dict:
    return _load(f"{name}/{name}.schema.json")


@pytest.mark.parametrize("name", PRESENTATIONS)
def test_rd_is_required_and_declared_as_the_other_sedi_credentials_declare_it(name: str) -> None:
    schema = _schema(name)
    assert "rd" in schema["required"]
    assert schema["properties"]["rd"] == _schema("sedi-core")["properties"]["rd"]
    order = list(schema["properties"])
    assert order.index("i") < order.index("rd") < order.index("s")


@pytest.mark.parametrize("name,version", PRESENTATIONS.items())
def test_the_new_revision_is_a_new_major_version(name: str, version: str) -> None:
    assert _schema(name)["version"] == version


@pytest.mark.parametrize("name", PRESENTATIONS)
def test_the_example_carries_rd_and_validates(name: str) -> None:
    schema, example = _schema(name), _load(f"{name}/example.json")
    jsonschema.validate(example, schema)
    assert example["s"] == schema["$id"]
    assert list(example).index("rd") == list(example).index("i") + 1
    assert saidify_sad(example) == example


@pytest.mark.parametrize("name", PRESENTATIONS)
def test_an_rd_less_presentation_is_refused(name: str) -> None:
    schema, missing = _schema(name), _load(f"{name}/invalid/missing-rd.json")
    assert "rd" not in missing
    with pytest.raises(jsonschema.ValidationError, match="'rd' is a required property"):
        jsonschema.validate(missing, schema)


@pytest.mark.parametrize("name", PRESENTATIONS)
def test_each_negative_fixture_fails_for_its_own_reason_and_not_for_a_missing_rd(name: str) -> None:
    """Every fixture but missing-rd carries rd, so none of them passes a test by lacking it."""
    schema = _schema(name)
    for path in sorted((ROOT / name / "invalid").glob("*.json")):
        if path.name != "missing-rd.json":
            fixture = json.loads(path.read_text())
            assert "rd" in fixture, path.name
            assert fixture["s"] == schema["$id"], path.name


def test_the_rd_not_allowed_fixture_is_gone() -> None:
    assert not (ROOT / "sedi-present-age-portrait/invalid/rd-not-allowed.json").exists()


@pytest.mark.parametrize("name,version,said,digest", ARCHIVED)
def test_the_published_revision_stays_resolvable_byte_for_byte(name, version, said, digest) -> None:
    archived = f"{name}-pre-presentation-rd-{version}"
    relative = f"{archived}/{archived}.schema.json"
    raw = (ROOT / relative).read_bytes()
    schema = json.loads(raw)
    registry = _load("registry.json")
    assert registry[said] == relative
    assert schema["$id"] == said == compute_schema_said(schema)
    assert hashlib.sha256(raw).hexdigest() == digest
    assert _schema(name)["$id"] != said
    assert registry[_schema(name)["$id"]] == f"{name}/{name}.schema.json"


@pytest.mark.parametrize("name", PRESENTATIONS)
def test_the_example_is_issued_into_the_registry_its_identity_far_node_names(name: str) -> None:
    """Copilot on #10: rd is the presenter's presentation registry, which Core names in a.rd."""
    presentation = _load(f"{name}/example.json")
    core = _load("sedi-core/example.json")
    assert presentation["e"]["identity"]["n"] == core["d"]
    assert presentation["i"] == core["a"]["i"]
    assert presentation["rd"] == core["a"]["rd"]


def test_core_and_residence_name_the_same_presentation_registry() -> None:
    """Both are issued to the same SMAID, whose one presentation registry both name."""
    core, residence = _load("sedi-core/example.json"), _load("sedi-residence/example.json")
    assert core["a"]["i"] == residence["a"]["i"]
    assert core["a"]["rd"] == residence["a"]["rd"]
