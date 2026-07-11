"""Unit tests for SAID computation (the keri oracle wrapper)."""

from __future__ import annotations

import copy

from schematools.said import SAID_LABEL, compute_schema_said, saidify_schema


def _schema() -> dict:
    return {
        "$id": "",
        "type": "object",
        "properties": {
            "d": {"type": "string"},
            "a": {
                "oneOf": [
                    {"type": "string"},
                    {"$id": "", "type": "object", "properties": {"d": {"type": "string"}}},
                ]
            },
        },
    }


def test_saidify_populates_top_level_and_block_ids():
    out = saidify_schema(_schema())
    assert out[SAID_LABEL].startswith("E")  # Blake3-256 CESR prefix
    expanded_arm = out["properties"]["a"]["oneOf"][1]
    assert expanded_arm[SAID_LABEL].startswith("E")


def test_saidify_does_not_mutate_input():
    original = _schema()
    snapshot = copy.deepcopy(original)
    saidify_schema(original)
    assert original == snapshot


def test_compute_is_deterministic_and_idempotent():
    schema = _schema()
    first = compute_schema_said(schema)
    saidified = saidify_schema(schema)
    # Re-saidifying an already-saidified schema yields the same top-level SAID.
    assert compute_schema_said(saidified) == first


def test_content_change_changes_said():
    before = compute_schema_said(_schema())
    tampered = _schema()
    tampered["properties"]["d"]["type"] = "integer"
    assert compute_schema_said(tampered) != before


def test_stored_said_matches_recomputed_after_saidify():
    saidified = saidify_schema(_schema())
    assert saidified[SAID_LABEL] == compute_schema_said(saidified)
