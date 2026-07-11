"""Unit tests for the schematools CLI."""

from __future__ import annotations

import json

import pytest

from schematools.cli import main
from tests.support import minimal_schema


def test_check_clean_repo_returns_zero(synthetic_repo, capsys):
    assert main(["check", "--root", str(synthetic_repo)]) == 0
    assert "OK" in capsys.readouterr().out


def test_check_dirty_repo_returns_one(synthetic_repo, capsys):
    (synthetic_repo / "widget" / "widget.schema.json").write_text("{ broken")
    assert main(["check", "--root", str(synthetic_repo)]) == 1
    assert "FAIL" in capsys.readouterr().out


def test_check_auto_detects_root_from_cwd(synthetic_repo, monkeypatch, capsys):
    monkeypatch.chdir(synthetic_repo)
    assert main(["check"]) == 0


def test_saidify_writes_said(tmp_path):
    path = tmp_path / "s.schema.json"
    path.write_text(json.dumps(minimal_schema("Widget", "color")))
    assert main(["saidify", "-f", str(path)]) == 0
    assert json.loads(path.read_text())["$id"].startswith("E")


def test_saidify_sad_writes_d(tmp_path):
    path = tmp_path / "instance.json"
    path.write_text(json.dumps({"d": "", "a": {"d": "", "x": "y"}}))
    assert main(["saidify-sad", "-f", str(path)]) == 0
    assert json.loads(path.read_text())["d"].startswith("E")


def test_registry_rebuilds(synthetic_repo):
    (synthetic_repo / "registry.json").write_text("{}")  # stale/empty
    assert main(["registry", "--root", str(synthetic_repo)]) == 0
    registry = json.loads((synthetic_repo / "registry.json").read_text())
    assert len(registry) == 1


def test_no_subcommand_errors():
    with pytest.raises(SystemExit):
        main([])
