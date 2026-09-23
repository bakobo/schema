"""The current Core accepts compact references and still checks expanded blocks."""

import json
import hashlib
from pathlib import Path

import jsonschema
import pytest

from schematools.said import compute_schema_said


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


PRIOR_DEPENDENTS = (
    ("sedi-age", "3.0.0", "EFxTYHyCerqMSJthl17hGxZhcRz1lEP5cWtRZ-hsZh85", "de0cbf6a9fb7af7768cb00d7009f97fb0909f0a028cf1be07bea38bc3fce9c0e"),
    ("sedi-guardian", "3.0.0", "EDhcDjDkCgdCHQurAvXjYPx2bR9jpBxw6WvOYiismmOV", "5b56486b532435228f2006874f4b02ae3989ed1dfcc7b830a4535fb48b12ccd0"),
    ("sedi-present-age-portrait", "3.0.0", "EPOBcvL3nas-yNPNufD2bIlO7nwuJLy4MAvqSxJmfmh3", "b59aacd515b3dc2542a14a8c4c54fa5b9f5ef08934f4d563ed347aec4d921633"),
    ("sedi-present-county", "1.0.0", "EE1qJmXEgBbinrT_1fSe3_ccu-MWG7znc2D88f6aCxL_", "07874ff084ce526a6d3a3aee03a910440204136e544001cbd1542cabb3ad6f77"),
    ("sedi-ward-authz", "1.0.0", "EDLnuzqWAuaahMDwPIynm0StlbqrUZHKMehfmyaMwIEh", "c775f7864fb407c4a3099b01f9cb181d4fdec58b5ce6564e14818a18def3879f"),
    ("sedi-ward-core", "1.0.0", "ELQbIW0bvd8ocbitQmjsaKEMEMxPX5YDFOdsWCca171s", "86440df479b6622a069d69f078b7c486deb995e7e36ea9c2c34bb00bfb8a146b"),
)


@pytest.mark.parametrize("name,version,said,digest", PRIOR_DEPENDENTS)
def test_displaced_schema_bytes_remain_registered(name: str, version: str, said: str, digest: str) -> None:
    archived = f"{name}-pre-core-compact-{version}"
    relative = f"{archived}/{archived}.schema.json"
    raw = (ROOT / relative).read_bytes()
    schema = json.loads(raw)
    registry = json.loads((ROOT / "registry.json").read_text())
    assert registry[said] == relative
    assert schema["$id"] == said
    assert compute_schema_said(schema) == said
    assert hashlib.sha256(raw).hexdigest() == digest
