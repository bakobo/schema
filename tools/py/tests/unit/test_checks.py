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


def test_structure_catches_invalid_jsonschema(synthetic_repo):
    # Valid JSON, but not a valid Draft 2020-12 schema (type must be a string/array).
    (synthetic_repo / "widget" / "widget.schema.json").write_text(json.dumps({"type": 123}))
    problems = checks.check_structure(synthetic_repo)
    assert len(problems) == 1 and "invalid JSON Schema" in problems[0].message


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


def test_example_refs_catches_stale_s(synthetic_repo):
    (synthetic_repo / "widget" / "example.json").write_text(json.dumps({"s": "E" + "Z" * 43}))
    problems = checks.check_example_refs(synthetic_repo)
    assert len(problems) == 1 and problems[0].check == "example_ref"


def test_example_refs_passes_when_s_matches_schema(synthetic_repo):
    schema = json.loads((synthetic_repo / "widget" / "widget.schema.json").read_text())
    (synthetic_repo / "widget" / "example.json").write_text(json.dumps({"s": schema[SAID_LABEL]}))
    assert checks.check_example_refs(synthetic_repo) == []


def test_example_saids_catches_inconsistent_instance(synthetic_repo):
    from schematools.said import saidify_sad

    # A plain (unversioned) SAD exercises the drift logic; the ACDC/v path is
    # covered by the conformance suite against the real corpus.
    good = saidify_sad({"d": "", "a": {"d": "", "x": "y"}})
    good["a"]["x"] = "tampered"  # content changed, SAIDs now stale
    (synthetic_repo / "widget" / "example.json").write_text(json.dumps(good))
    problems = checks.check_example_saids(synthetic_repo)
    assert len(problems) == 1 and problems[0].check == "example_said"


def test_example_saids_passes_self_consistent_instance(synthetic_repo):
    from schematools.said import saidify_sad

    good = saidify_sad({"d": "", "a": {"d": "", "x": "y"}})
    (synthetic_repo / "widget" / "example.json").write_text(json.dumps(good))
    assert checks.check_example_saids(synthetic_repo) == []


def test_example_saids_ignores_non_sad_example(synthetic_repo):
    (synthetic_repo / "widget" / "example.json").write_text(json.dumps({"note": "not a SAD"}))
    assert checks.check_example_saids(synthetic_repo) == []


def test_example_saids_reports_unsaidifiable(synthetic_repo):
    # Has a 'd' (looks like a SAD) but a malformed 'v' the ACDC saidifier rejects.
    (synthetic_repo / "widget" / "example.json").write_text(json.dumps({"v": "bogus", "d": ""}))
    problems = checks.check_example_saids(synthetic_repo)
    assert len(problems) == 1 and "cannot saidify" in problems[0].message


def test_example_saids_skips_unparseable_example(synthetic_repo):
    (synthetic_repo / "widget" / "example.json").write_text("{ not json")
    assert checks.check_example_saids(synthetic_repo) == []


# --- error paths on unparseable / dangling inputs -------------------------------


def _break_schema(repo):
    (repo / "widget" / "widget.schema.json").write_text("{ not json")


def test_said_integrity_reports_unparseable(synthetic_repo):
    _break_schema(synthetic_repo)
    problems = checks.check_said_integrity(synthetic_repo)
    assert len(problems) == 1 and "unparseable" in problems[0].message


def test_examples_reports_unparseable_schema(synthetic_repo):
    (synthetic_repo / "widget" / "example.json").write_text("{}")
    _break_schema(synthetic_repo)
    problems = checks.check_examples(synthetic_repo)
    assert any("schema unparseable" in p.message for p in problems)


def test_examples_reports_unparseable_example(synthetic_repo):
    (synthetic_repo / "widget" / "example.json").write_text("{ not json")
    problems = checks.check_examples(synthetic_repo)
    assert len(problems) == 1 and "invalid JSON" in problems[0].message


def test_registry_reports_unparseable_schema(synthetic_repo):
    _break_schema(synthetic_repo)
    problems = checks.check_registry(synthetic_repo)
    assert any("unparseable" in p.message for p in problems)


def test_registry_reports_dangling_path(synthetic_repo):
    reg = json.loads((synthetic_repo / REGISTRY_NAME).read_text())
    reg["E" + "G" * 43] = "ghost/ghost.schema.json"
    (synthetic_repo / REGISTRY_NAME).write_text(json.dumps(reg))
    problems = checks.check_registry(synthetic_repo)
    assert any("not found on disk" in p.message for p in problems)


def test_example_refs_skips_unparseable(synthetic_repo):
    (synthetic_repo / "widget" / "example.json").write_text("{ not json")
    assert checks.check_example_refs(synthetic_repo) == []
    _break_schema(synthetic_repo)
    assert checks.check_example_refs(synthetic_repo) == []


# --- format assertion -----------------------------------------------------------


def test_validator_asserts_date_time_format():
    # format must be ENFORCED, not merely annotated (this.i @f4mt6k).
    schema = {"type": "object", "properties": {"dt": {"type": "string", "format": "date-time"}}}
    assert list(checks._validator(schema).iter_errors({"dt": "not a date"}))
    assert not list(checks._validator(schema).iter_errors({"dt": "2025-01-01T00:00:00+00:00"}))


def test_validator_ignores_unknown_cesr_format():
    # An unknown format (cesr) is ignored, never a validation failure (this.i @f4mt6k).
    schema = {"type": "object", "properties": {"k": {"type": "string", "format": "cesr"}}}
    assert not list(checks._validator(schema).iter_errors({"k": "anything at all"}))


# --- negative-example corpus ----------------------------------------------------


def _write_invalid(repo, name, text):
    invalid = repo / "widget" / "invalid"
    invalid.mkdir(exist_ok=True)
    (invalid / name).write_text(text)


def test_negative_examples_absent_dir_is_clean(synthetic_repo):
    # No invalid/ directory at all -> nothing to check.
    assert checks.check_negative_examples(synthetic_repo) == []


def test_negative_examples_passes_when_fixture_rejected(synthetic_repo):
    # A fixture missing the required 'a' block is correctly rejected -> clean.
    _write_invalid(synthetic_repo, "missing-a.json", json.dumps({"d": "x"}))
    assert checks.check_negative_examples(synthetic_repo) == []


def test_negative_examples_flags_accepted_fixture(synthetic_repo):
    # A fully-valid instance parked in invalid/ means the "negative" is not one:
    # the schema accepts it, which the check must report as too-permissive.
    good = {"d": "", "a": {"d": "", "color": "blue"}}
    _write_invalid(synthetic_repo, "actually-valid.json", json.dumps(good))
    problems = checks.check_negative_examples(synthetic_repo)
    assert len(problems) == 1 and problems[0].check == "negative"
    assert "too permissive" in problems[0].message


def test_negative_examples_reports_unparseable_fixture(synthetic_repo):
    _write_invalid(synthetic_repo, "broken.json", "{ not json")
    problems = checks.check_negative_examples(synthetic_repo)
    assert len(problems) == 1 and "invalid JSON" in problems[0].message


def test_negative_examples_skips_when_schema_unparseable(synthetic_repo):
    _write_invalid(synthetic_repo, "missing-a.json", json.dumps({"d": "x"}))
    _break_schema(synthetic_repo)
    assert checks.check_negative_examples(synthetic_repo) == []
