"""Pinned SEDI schema vectors, including Sam Smith's original Core revision.

The byte hashes also catch edits to formatting or key order that a schema SAID,
which is computed over canonical JSON, cannot detect.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

import pytest

from schematools.said import compute_schema_said

ROOT = Path(__file__).resolve().parents[4]
SAM_SOURCE = "https://github.com/WebOfTrust/keripy/blob/ec307cd74/tests/sedi/test_sedi.py"

PINS = {
    "sedi-iar": (
        "EHp3Ik9q-6-sT0IFaLRJDEjd-j3zMRdy1aN6O6awCsZd",
        "1ad44ebf935f69d2a0dfad37ba0fa4f8f563fec6d357ef8ac67e570d4c002afc",
    ),
    "sedi-core-0.1.0": (
        "ED7zRxzpuvv89c6jDwgyBNOoW06Ut0wm_8jJQRqKYv_5",
        "543ffc58f48bf6d04dc3f49f9967ae36e586c863798bd67eefe2ff3485ef3a4e",
    ),
    "sedi-residence-0.1.0": (
        "EEgFNN1XH90koG5J5pbXKlRNU6TnibizaTQmJcRfEcop",
        "a9c23887bcd8d436a70367ccd1f683cb78305bb281d047bfad19e0f7bb6d4227",
    ),
}

CURRENT_CORE = (
    "ELNhZbCUiafPrMFnL2vRGEjylRu8zug-3M-goUft8bfh",
    "fecf18fcffc622820783e5cc8cc66653a61bf1ea6797a0d6ef5b46965b092cb9",
)

CURRENT_RESIDENCE = (
    "EDg5tBqnVFoGILBgIknKs-0CHv3au4GczuPgjf4jx1X2",
    "2bfe9f3ab0836714554f90bc971cb2723306453ad0f953825dc22459ffa9797d",
)


@pytest.mark.parametrize("name", PINS)
def test_sam_schema_pin(name: str) -> None:
    expected_said, expected_sha256 = PINS[name]
    raw = (ROOT / name / f"{name}.schema.json").read_bytes()
    schema = json.loads(raw)
    assert schema["$id"] == expected_said, SAM_SOURCE
    assert compute_schema_said(schema) == expected_said, SAM_SOURCE
    assert hashlib.sha256(raw).hexdigest() == expected_sha256, SAM_SOURCE


def test_bakobo_compact_core_pin() -> None:
    raw = (ROOT / "sedi-core/sedi-core.schema.json").read_bytes()
    schema = json.loads(raw)
    assert schema["$id"] == CURRENT_CORE[0]
    assert compute_schema_said(schema) == CURRENT_CORE[0]
    assert hashlib.sha256(raw).hexdigest() == CURRENT_CORE[1]


def test_bakobo_compact_residence_pin() -> None:
    raw = (ROOT / "sedi-residence/sedi-residence.schema.json").read_bytes()
    schema = json.loads(raw)
    assert schema["$id"] == CURRENT_RESIDENCE[0]
    assert compute_schema_said(schema) == CURRENT_RESIDENCE[0]
    assert hashlib.sha256(raw).hexdigest() == CURRENT_RESIDENCE[1]
