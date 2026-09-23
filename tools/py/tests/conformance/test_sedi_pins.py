"""Pinned Sam Smith SEDI schema vectors from WebOfTrust/keripy ec307cd74.

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
    "sedi-core": (
        "ED7zRxzpuvv89c6jDwgyBNOoW06Ut0wm_8jJQRqKYv_5",
        "543ffc58f48bf6d04dc3f49f9967ae36e586c863798bd67eefe2ff3485ef3a4e",
    ),
    "sedi-residence": (
        "EEgFNN1XH90koG5J5pbXKlRNU6TnibizaTQmJcRfEcop",
        "a9c23887bcd8d436a70367ccd1f683cb78305bb281d047bfad19e0f7bb6d4227",
    ),
}


@pytest.mark.parametrize("name", PINS)
def test_sam_schema_pin(name: str) -> None:
    expected_said, expected_sha256 = PINS[name]
    raw = (ROOT / name / f"{name}.schema.json").read_bytes()
    schema = json.loads(raw)
    assert schema["$id"] == expected_said, SAM_SOURCE
    assert compute_schema_said(schema) == expected_said, SAM_SOURCE
    assert hashlib.sha256(raw).hexdigest() == expected_sha256, SAM_SOURCE
