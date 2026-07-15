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
    # canonical manifest is the .well-known path; a non-dot alias is byte-identical
    assert publish.MANIFEST_PATH == ".well-known/acdc-schemas.json"
    assert (out / publish.ROOT_ALIAS_MANIFEST).read_text() == (out / publish.MANIFEST_PATH).read_text()
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


# --- Zensical source generation (this.i @z5nc4d) --------------------------------


def test_build_docs_uses_index_md_when_present(synthetic_repo, tmp_path):
    (synthetic_repo / "widget" / "index.md").write_text("# Widget\n\nHand-written narrative.\n")
    docs = tmp_path / "_docs"
    names = publish.build_docs(synthetic_repo, docs)
    assert names == ["widget"]
    # page sits in the schema folder so its relative links resolve; the sidebar
    # collapses it to one link via the navigation.indexes theme feature
    assert "Hand-written narrative." in (docs / "widget" / "index.md").read_text()
    landing = (docs / "index.md").read_text()
    assert "[widget](widget/)" in landing and "discovery manifest" in landing


def test_build_docs_stubs_when_no_index_md(synthetic_repo, tmp_path):
    docs = tmp_path / "_docs"
    publish.build_docs(synthetic_repo, docs)
    # minimal_schema has a title "Widget" but no index.md -> generated stub
    assert "# Widget" in (docs / "widget" / "index.md").read_text()


def test_build_docs_folds_in_committed_docs_dir(synthetic_repo, tmp_path):
    committed = synthetic_repo / "docs"
    committed.mkdir()
    (committed / "style.md").write_text("# House style\n")
    out = tmp_path / "_docs"
    publish.build_docs(synthetic_repo, out)
    assert (out / "style.md").read_text() == "# House style\n"  # committed page carried through


def test_build_docs_cli(synthetic_repo, tmp_path):
    rc = main(["build-docs", "--root", str(synthetic_repo), "--out", str(tmp_path / "_docs")])
    assert rc == 0
    assert (tmp_path / "_docs" / "index.md").is_file()


# --- federation layer (this.i @f7dr3k) ------------------------------------------

_FEDERATION = {
    "registries": [
        {"name": "Us", "operator": "Bakobo", "self": True, "homepage": "https://x.example/",
         "registry": "https://x.example/registry.json", "sourceRepo": "https://github.com/bakobo/schema",
         "resolution": "static", "notes": "self"},
        {"name": "Bare", "resolution": "source-only"},  # no homepage/repo/registry -> exercises _md_link '—'
    ],
    "specifications": [{"name": "ACDC", "url": "https://spec.example/acdc"}],
}


def _write_federation(repo):
    (repo / "federation.json").write_text(json.dumps(_FEDERATION))


def test_load_federation_present_and_absent(synthetic_repo):
    assert publish.load_federation(synthetic_repo) is None
    _write_federation(synthetic_repo)
    assert publish.load_federation(synthetic_repo)["registries"][0]["name"] == "Us"


def test_build_site_emits_registries_when_federation_present(synthetic_repo, tmp_path):
    _write_federation(synthetic_repo)
    publish.build_site(synthetic_repo, tmp_path / "site")
    assert (tmp_path / "site" / publish.REGISTRIES_PATH).is_file()


def test_build_site_skips_registries_without_federation(synthetic_repo, tmp_path):
    publish.build_site(synthetic_repo, tmp_path / "site")
    assert not (tmp_path / "site" / publish.REGISTRIES_PATH).exists()


def test_build_docs_emits_ecosystem_and_links_it(synthetic_repo, tmp_path):
    _write_federation(synthetic_repo)
    out = tmp_path / "_docs"
    publish.build_docs(synthetic_repo, out)
    eco = (out / "ecosystem.md").read_text()
    assert "Us" in eco and "*(this site)*" in eco and "Bare" in eco and "ACDC" in eco
    assert "—" in eco  # the Bare entry has no links
    assert "ecosystem/" in (out / "index.md").read_text()  # landing links to it


def test_build_docs_no_ecosystem_without_federation(synthetic_repo, tmp_path):
    out = tmp_path / "_docs"
    publish.build_docs(synthetic_repo, out)
    assert not (out / "ecosystem.md").exists()
    assert "ecosystem/" not in (out / "index.md").read_text()


# --- output escaping / URL sanitization (review SEC-F1, HSX-F3) -----------------


def test_safe_url_allows_http_and_relative_drops_others():
    assert publish._safe_url("https://x.example/") == "https://x.example/"
    assert publish._safe_url("http://x.example") == "http://x.example"
    assert publish._safe_url("/registry.json") == "/registry.json"
    assert publish._safe_url("javascript:alert(1)") is None  # active-content scheme dropped
    assert publish._safe_url("data:text/html,x") is None
    assert publish._safe_url(None) is None
    assert publish._safe_url("") is None


def test_esc_html_handles_none_and_specials():
    assert publish._esc_html(None) == ""
    assert publish._esc_html('<b>&"x</b>') == "&lt;b&gt;&amp;&quot;x&lt;/b&gt;"


def test_esc_md_neutralizes_html_table_and_link_syntax():
    assert publish._esc_md(None) == ""
    out = publish._esc_md("<script>|a[b]`c`\nd")
    assert "<script>" not in out and "\n" not in out
    assert "\\|" in out and "\\[" in out and "\\]" in out and "\\`" in out


def test_md_link_sanitizes_unsafe_scheme():
    assert publish._md_link("x", "javascript:alert(1)") == "—"
    assert publish._md_link("x", "https://ok.example") == "[x](https://ok.example)"


def test_render_index_escapes_untrusted_and_declares_lang():
    rows = [{"name": "<img src=x onerror=alert(1)>", "title": "<b>t</b>", "version": "1&2",
             "said": "E" + "z" * 43, "schema": "a/a.json", "oobi": "oobi/x.json"}]
    html = publish._render_index("https://x.example", rows)
    assert '<html lang="en">' in html
    assert "<img src=x onerror=alert(1)>" not in html  # escaped
    assert "&lt;img" in html and 'scope="col"' in html


def test_render_ecosystem_escapes_injection_and_drops_bad_homepage():
    federation = {
        "registries": [
            {"name": "<script>x</script>", "operator": "a|b", "resolution": "static",
             "homepage": "javascript:alert(1)", "notes": "n[e](u)"},
        ],
        "specifications": [{"name": "Spec", "url": "javascript:alert(2)"}],
    }
    md = publish._render_ecosystem(federation)
    assert "<script>x</script>" not in md  # raw HTML neutralized
    assert "javascript:alert(1)" not in md  # unsafe homepage dropped, not a link target
    assert "javascript:alert(2)" not in md  # unsafe spec url dropped
    assert "a\\|b" in md  # table-cell break escaped


# --- SEO (this.i @s6eqk4) -------------------------------------------------------


def test_front_matter_sanitizes_and_caps():
    fm = publish._front_matter('a "quote" and\na newline ' + "x" * 300)
    assert fm.startswith("---\ndescription: \"") and fm.endswith("---\n\n")
    assert "\\\"quote\\\"" in fm  # quotes escaped
    assert "\n" not in fm.split('description: "', 1)[1].split('"', 1)[0]  # value single-line
    assert len(fm) < 260  # capped


def test_schema_description_falls_back():
    assert publish._schema_description({"description": "D"}, "w") == "D"
    assert "ACDC credential schema" in publish._schema_description({}, "widget")


def test_build_docs_writes_unique_meta_descriptions(synthetic_repo, tmp_path):
    out = tmp_path / "_docs"
    publish.build_docs(synthetic_repo, out)
    page = (out / "widget" / "index.md").read_text()
    assert page.startswith("---\ndescription:")  # front-matter present -> unique <meta>
    assert (out / "index.md").read_text().startswith("---\ndescription:")


def test_build_site_writes_robots_with_sitemap(synthetic_repo, tmp_path):
    publish.build_site(synthetic_repo, tmp_path / "site", base_url="https://x.example/")
    robots = (tmp_path / "site" / "robots.txt").read_text()
    assert "Sitemap: https://x.example/sitemap.xml" in robots


# --- federation Layer 2: meta-schema (this.i @m5tqw3) ---------------------------


def _write_meta_schema(repo):
    # copy the real committed meta-schema so the dogfood test is meaningful
    from pathlib import Path

    from schematools.repo import find_repo_root

    real = find_repo_root(Path(__file__).resolve().parent) / publish.META_SCHEMA_SRC
    (repo / "spec").mkdir(exist_ok=True)
    (repo / "spec" / "acdc-schema-registry.schema.json").write_text(real.read_text())


def test_meta_schema_absent_no_pointer(synthetic_repo, tmp_path):
    manifest = publish.build_site(synthetic_repo, tmp_path / "site")
    assert "$schema" not in manifest
    assert not (tmp_path / "site" / publish.META_SCHEMA_PATH).exists()


def test_meta_schema_published_and_manifest_conforms(synthetic_repo, tmp_path):
    from jsonschema import Draft202012Validator

    _write_meta_schema(synthetic_repo)
    out = tmp_path / "site"
    manifest = publish.build_site(synthetic_repo, out, base_url="https://x.example")
    # published at the root, and the manifest points at it
    meta = json.loads((out / publish.META_SCHEMA_PATH).read_text())
    Draft202012Validator.check_schema(meta)  # it is a valid Draft 2020-12 schema
    assert manifest["$schema"] == "https://x.example/acdc-schema-registry.schema.json"
    # dogfood: the emitted manifest validates against its own meta-schema
    assert not list(Draft202012Validator(meta).iter_errors(manifest))
