"""Build the deployable machine site (this.i @o6bw3k).

Given a schema repo and an output directory, emits a self-contained static site:

  - ``<name>/<name>.schema.json`` (+ examples, icons, index.md) — each schema
    resolvable at a stable folder URL, with proper ``application/json``.
  - ``registry.json`` — the crawl-free SAID -> path index.
  - ``oobi/<said>.json`` — a byte-identical copy of each schema, addressed by
    its SAID: the ACDC OOBI. Resolution SAID-verifies the body, so the ``.json``
    extension is cosmetic to the trust model but keeps the file browsable.
  - ``.well-known/acdc-schemas.json`` — a discovery manifest: the machine front
    door a crawler finds from the domain root.
  - ``CNAME`` and ``index.html`` — custom domain + a generated registry landing.

The output is complete and deployable WITHOUT any HTML generator; Zensical
(this.i @z5nc4d) layers browsable per-schema pages on top separately.
"""

from __future__ import annotations

import json
import shutil
from pathlib import Path

from .repo import REGISTRY_NAME, SchemaEntry, discover_schemas, load_registry
from .said import SAID_LABEL

DEFAULT_BASE_URL = "https://schema.bakobo.com"
CNAME_HOST = "schema.bakobo.com"
# Canonical discovery-manifest path. It is a ROOT (non-dot) path because GitHub
# Pages' upload-pages-artifact strips every top-level dot-entry (--exclude
# ".[^/]*"), so a `.well-known/` file never reaches the deployed site. The
# `.well-known` mirror is emitted too, for the cross-host convention (this.i
# @o6bw3k), but the manifest advertises and the site links to the root path.
MANIFEST_PATH = "acdc-schemas.json"
WELL_KNOWN_MANIFEST = ".well-known/acdc-schemas.json"


def _rules_said(schema: dict) -> str | None:
    """The governance/rules SAID a schema pins, if it fixes one via ``r.const``.

    Schemas that bind a specific rules block (citation, org-vet) expose it as a
    ``const`` on the ``r`` property; schemas whose ``r`` is a compact/expanded
    ``oneOf`` (or absent) pin nothing here and return ``None``.
    """
    r = schema.get("properties", {}).get("r")
    if isinstance(r, dict):
        return r.get("const")
    return None


def _copy_schema_folder(entry: SchemaEntry, out: Path) -> None:
    """Copy a schema folder's top-level files (skips the ``invalid/`` corpus)."""
    dst = out / entry.name
    dst.mkdir(parents=True, exist_ok=True)
    for item in sorted(entry.path.parent.iterdir()):
        if item.is_file():
            shutil.copy2(item, dst / item.name)


def _manifest_entry(entry: SchemaEntry, said: str) -> dict:
    schema = json.loads(entry.path.read_text())
    return {
        "said": said,
        "name": entry.name,
        "title": schema.get("title"),
        "credentialType": schema.get("credentialType"),
        "version": schema.get("version"),
        "schema": entry.rel,
        "oobi": f"oobi/{said}.json",
        "rules": _rules_said(schema),
    }


def _render_index(base_url: str, schemas: list[dict]) -> str:
    rows = "\n".join(
        f'      <tr><td><a href="{s["schema"]}">{s["name"]}</a></td>'
        f'<td>{s["title"] or ""}</td><td><code>{s["version"] or ""}</code></td>'
        f'<td><a href="{s["oobi"]}"><code>{s["said"][:12]}…</code></a></td></tr>'
        for s in schemas
    )
    return f"""<!doctype html>
<meta charset="utf-8">
<title>Bakobo ACDC schema registry</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body{{font:16px/1.5 system-ui,sans-serif;max-width:52rem;margin:3rem auto;padding:0 1rem}}
  table{{border-collapse:collapse;width:100%}} th,td{{text-align:left;padding:.4rem .6rem;border-bottom:1px solid #ddd}}
  code{{font-size:.85em}}
</style>
<h1>Bakobo ACDC schema registry</h1>
<p>General-purpose <a href="https://trustoverip.github.io/tswg-acdc-specification/">ACDC</a>
credential schemas, each addressed by its SAID. Machine index:
<a href="{MANIFEST_PATH}">discovery manifest</a> · <a href="registry.json">registry.json</a>.
Source: <a href="https://github.com/bakobo/schema">github.com/bakobo/schema</a>.</p>
<table>
  <thead><tr><th>Schema</th><th>Asserts</th><th>Version</th><th>OOBI (SAID)</th></tr></thead>
  <tbody>
{rows}
  </tbody>
</table>
<p><em>Each schema also resolves as a SAID-addressed OOBI under <code>{base_url}/oobi/&lt;said&gt;.json</code>.
A richer browsable site is in progress.</em></p>
"""


def _schema_doc(entry: SchemaEntry) -> str:
    """The narrative markdown for a schema: its ``index.md``, or a stub."""
    src = entry.path.parent / "index.md"
    if src.is_file():
        return src.read_text()
    schema = json.loads(entry.path.read_text())
    return f"# {schema.get('title', entry.name)}\n\n{schema.get('description', '')}\n"


def build_docs(root: str | Path, out: str | Path) -> list[str]:
    """Generate the Zensical source tree (this.i @z5nc4d) from the corpus.

    Folds in the committed ``docs/`` (hand-written pages such as the house
    style), then writes a landing ``index.md`` plus ``<name>/index.md`` per
    schema (the committed schema ``index.md`` narratives are the source of
    truth). Referenced icons and the raw JSON are NOT copied here; they come
    from the machine site (@o6bw3k) when the built HTML is merged over it.
    Returns the schema names.
    """
    root = Path(root)
    out = Path(out)
    out.mkdir(parents=True, exist_ok=True)

    committed = root / "docs"
    if committed.is_dir():
        shutil.copytree(committed, out, dirs_exist_ok=True)

    entries = discover_schemas(root)

    rows = []
    for entry in entries:
        schema = json.loads(entry.path.read_text())
        rows.append(f"| [{entry.name}]({entry.name}/) | {schema.get('title', '')} | `{schema.get('version', '')}` |")
    landing = (
        "# Bakobo ACDC schema registry\n\n"
        "General-purpose [ACDC](https://trustoverip.github.io/tswg-acdc-specification/) credential "
        "schemas, each addressed by its SAID. Machine index: "
        f"[registry.json](registry.json) · [discovery manifest]({MANIFEST_PATH}).\n\n"
        "| Schema | Asserts | Version |\n|---|---|---|\n" + "\n".join(rows) + "\n"
    )
    (out / "index.md").write_text(landing)

    # ``<name>/index.md`` (not a flat ``<name>.md``) so the page sits IN the
    # schema folder and its relative links to the schema JSON and icons resolve.
    # The sidebar renders each as a single link (no folder/index nesting) via the
    # ``navigation.indexes`` theme feature: a section whose only content is its
    # index page collapses to one clickable link (this.i @z5nc4d).
    for entry in entries:
        page_dir = out / entry.name
        page_dir.mkdir(exist_ok=True)
        (page_dir / "index.md").write_text(_schema_doc(entry))

    return [entry.name for entry in entries]


def build_site(root: str | Path, out: str | Path, base_url: str = DEFAULT_BASE_URL) -> dict:
    """Assemble the machine site under ``out``; return the discovery manifest dict."""
    root = Path(root)
    out = Path(out)
    out.mkdir(parents=True, exist_ok=True)

    entries = discover_schemas(root)
    registry = load_registry(root)
    rel_to_said = {rel: said for said, rel in registry.items()}

    # per-schema folders + registry index
    for entry in entries:
        _copy_schema_folder(entry, out)
    shutil.copy2(root / REGISTRY_NAME, out / REGISTRY_NAME)

    # OOBIs: byte-identical schema copies addressed by SAID
    oobi_dir = out / "oobi"
    oobi_dir.mkdir(exist_ok=True)
    for said, rel in registry.items():
        shutil.copy2(root / rel, oobi_dir / f"{said}.json")

    # discovery manifest
    schemas = [_manifest_entry(entry, rel_to_said[entry.rel]) for entry in entries]
    manifest = {"baseUrl": base_url, "schemas": schemas}
    body = json.dumps(manifest, indent=2) + "\n"
    (out / MANIFEST_PATH).write_text(body)  # canonical, served on GitHub Pages
    mirror = out / WELL_KNOWN_MANIFEST  # cross-host convention mirror
    mirror.parent.mkdir(parents=True, exist_ok=True)
    mirror.write_text(body)

    # custom domain + landing page
    (out / "CNAME").write_text(CNAME_HOST + "\n")
    (out / "index.html").write_text(_render_index(base_url, schemas))

    return manifest
