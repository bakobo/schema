"""Unit tests for the repo-wide invariant checks.

Each test starts from a fully-valid synthetic repo and introduces exactly one
defect, asserting the corresponding check catches it (and, where relevant, that
the others stay quiet).
"""

from __future__ import annotations

import json

from schematools import checks
from schematools.repo import REGISTRY_NAME
from schematools.said import SAID_LABEL

from tests.support import minimal_schema, write_registry, write_schema


def test_clean_repo_has_no_problems(synthetic_repo):
    assert checks.run_all(synthetic_repo) == []


def test_structure_catches_invalid_json(synthetic_repo):
    (synthetic_repo / "widget" / "widget.schema.json").write_text("{ not json")
    problems = checks.check_structure(synthetic_repo)
    assert len(problems) == 1 and problems[0].check == "structure"
    assert "invalid JSON" in problems[0].message


def test_said_integrity_catches_tampered_id(synthetic_repo):
    path = synthetic_repo / "widget" / "widget.schema.json"
    schema = json.loads(path.read_text())
    schema["title"] = "Tampered"  # change content, leave stale $id
    path.write_text(json.dumps(schema, indent=2))
    problems = checks.check_said_integrity(synthetic_repo)
    assert len(problems) == 1 and problems[0].check == "said"
    assert "recomputed" in problems[0].message


def test_registry_catches_orphan_schema(synthetic_repo):
    # Add a second valid schema but do NOT re-index it.
    write_schema(synthetic_repo, "gadget", minimal_schema("Gadget", "size"))
    problems = checks.check_registry(synthetic_repo)
    assert len(problems) == 1
    assert "absent from registry.json" in problems[0].message


def test_registry_catches_key_id_mismatch(synthetic_repo):
    reg_path = synthetic_repo / REGISTRY_NAME
    registry = json.loads(reg_path.read_text())
    (said,) = list(registry)
    registry["E" + "A" * 43] = registry.pop(said)  # wrong key -> $id mismatch
    reg_path.write_text(json.dumps(registry, indent=2))
    problems = checks.check_registry(synthetic_repo)
    assert any("!= schema $id" in p.message for p in problems)


def test_examples_catches_bad_instance(synthetic_repo):
    # An example missing the required 'a' block fails validation.
    (synthetic_repo / "widget" / "example.json").write_text(json.dumps({"d": "x"}))
    write_registry(synthetic_repo)
    problems = checks.check_examples(synthetic_repo)
    assert len(problems) == 1 and problems[0].check == "example"


def test_examples_passes_valid_instance(synthetic_repo):
    schema = json.loads((synthetic_repo / "widget" / "widget.schema.json").read_text())
    said = schema[SAID_LABEL]
    good = {"d": "", "a": {"d": "", "color": "blue"}}
    # sanity: compact-vs-expanded 'a' expanded arm requires d + color
    (synthetic_repo / "widget" / "example.json").write_text(json.dumps(good))
    assert said  # schema is saidified
    assert checks.check_examples(synthetic_repo) == []
