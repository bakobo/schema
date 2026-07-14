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
MANIFEST_PATH = ".well-known/acdc-schemas.json"


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
    well_known = out / MANIFEST_PATH
    well_known.parent.mkdir(parents=True, exist_ok=True)
    well_known.write_text(json.dumps(manifest, indent=2) + "\n")

    # custom domain + landing page
    (out / "CNAME").write_text(CNAME_HOST + "\n")
    (out / "index.html").write_text(_render_index(base_url, schemas))

    return manifest
