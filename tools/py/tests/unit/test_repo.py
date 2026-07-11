"""Unit tests for schema-repo discovery."""

from __future__ import annotations

import pytest

from schematools.repo import discover_schemas, find_repo_root, load_registry


def test_discover_finds_the_synthetic_schema(synthetic_repo):
    entries = discover_schemas(synthetic_repo)
    assert [e.name for e in entries] == ["widget"]
    assert entries[0].rel == "widget/widget.schema.json"
    assert entries[0].example is None


def test_discover_ignores_non_schema_and_dot_dirs(synthetic_repo):
    (synthetic_repo / "docs").mkdir()
    (synthetic_repo / "docs" / "notes.md").write_text("hi")
    (synthetic_repo / ".hidden").mkdir()
    # a dir without <name>/<name>.schema.json is not a schema
    (synthetic_repo / "loose").mkdir()
    (synthetic_repo / "loose" / "other.json").write_text("{}")
    assert [e.name for e in discover_schemas(synthetic_repo)] == ["widget"]


def test_discover_picks_up_example(synthetic_repo):
    (synthetic_repo / "widget" / "example.json").write_text("{}")
    entry = discover_schemas(synthetic_repo)[0]
    assert entry.example is not None and entry.example.name == "example.json"


def test_find_repo_root_walks_up_from_a_file(synthetic_repo):
    deep = synthetic_repo / "widget" / "widget.schema.json"
    assert find_repo_root(deep) == synthetic_repo


def test_find_repo_root_raises_without_registry(tmp_path):
    with pytest.raises(FileNotFoundError):
        find_repo_root(tmp_path)


def test_load_registry_has_one_entry(synthetic_repo):
    registry = load_registry(synthetic_repo)
    assert len(registry) == 1
    (said,) = registry
    assert registry[said] == "widget/widget.schema.json"
