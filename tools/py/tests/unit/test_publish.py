"""Unit tests for the machine-site builder (this.i @o6bw3k)."""

from __future__ import annotations

import json

from schematools import publish
from schematools.cli import main
from schematools.said import SAID_LABEL


def _schema_said(repo):
    return json.loads((repo / "widget" / "widget.schema.json").read_text())[SAID_LABEL]


def test_build_site_produces_machine_site(synthetic_repo, tmp_path):
    out = tmp_path / "site"
    manifest = publish.build_site(synthetic_repo, out, base_url="https://x.example")

    said = _schema_said(synthetic_repo)
    # schema resolvable at its folder path, and byte-identical as an OOBI
    assert (out / "widget" / "widget.schema.json").is_file()
    assert (out / "oobi" / f"{said}.json").read_bytes() == (
        synthetic_repo / "widget" / "widget.schema.json"
    ).read_bytes()
    # registry, manifest, domain, landing
    assert (out / "registry.json").is_file()
    wk = json.loads((out / publish.MANIFEST_PATH).read_text())
    assert wk["baseUrl"] == "https://x.example"
    assert wk["schemas"][0]["name"] == "widget"
    assert wk["schemas"][0]["oobi"] == f"oobi/{said}.json"
    assert (out / "CNAME").read_text().strip() == publish.CNAME_HOST
    assert "widget" in (out / "index.html").read_text()
    assert manifest == wk


def test_build_site_excludes_invalid_corpus(synthetic_repo, tmp_path):
    invalid = synthetic_repo / "widget" / "invalid"
    invalid.mkdir()
    (invalid / "bad.json").write_text("{}")
    publish.build_site(synthetic_repo, tmp_path / "site")
    assert not (tmp_path / "site" / "widget" / "invalid").exists()


def test_rules_said_reads_const_else_none():
    assert publish._rules_said({"properties": {"r": {"const": "EAAA"}}}) == "EAAA"
    assert publish._rules_said({"properties": {"r": {"oneOf": [{"type": "string"}]}}}) is None
    assert publish._rules_said({}) is None  # no properties/r at all


def test_render_index_tolerates_missing_title_and_version():
    rows = [
        {"name": "a", "title": None, "version": None, "said": "E" + "z" * 43, "schema": "a/a.json", "oobi": "oobi/x.json"},
        {"name": "b", "title": "Bee", "version": "1.0.0", "said": "E" + "y" * 43, "schema": "b/b.json", "oobi": "oobi/y.json"},
    ]
    html = publish._render_index("https://x.example", rows)
    assert "a/a.json" in html and "Bee" in html


def test_publish_cli_builds_when_clean(synthetic_repo, tmp_path):
    out = tmp_path / "site"
    rc = main(["publish", "--root", str(synthetic_repo), "--out", str(out)])
    assert rc == 0
    assert (out / publish.MANIFEST_PATH).is_file()


def test_publish_cli_refuses_when_broken(synthetic_repo, tmp_path):
    (synthetic_repo / "widget" / "widget.schema.json").write_text("{ not json")
    out = tmp_path / "site"
    rc = main(["publish", "--root", str(synthetic_repo), "--out", str(out)])
    assert rc == 1
    assert not (out / publish.MANIFEST_PATH).exists()  # fail closed: nothing published
