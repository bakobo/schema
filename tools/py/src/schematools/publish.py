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

import html
import json
import shutil
from pathlib import Path

from .repo import REGISTRY_NAME, SchemaEntry, discover_schemas, load_registry
from .said import SAID_LABEL

DEFAULT_BASE_URL = "https://schema.bakobo.com"
CNAME_HOST = "schema.bakobo.com"
# Canonical discovery-manifest path: the web-standard `.well-known/` location,
# which also aligns with the KERI ecosystem's `.well-known/…` convention. GitHub
# Pages CAN serve `.well-known` (WebOfTrust does); the only barrier was
# `upload-pages-artifact` stripping top-level dot-entries, which the Pages
# workflow now avoids by tarring the site itself (this.i @o6bw3k). A byte-
# identical non-dot alias is also emitted for convenience / hosts that differ.
MANIFEST_PATH = ".well-known/acdc-schemas.json"
ROOT_ALIAS_MANIFEST = "acdc-schemas.json"

# Federation: the hand-edited directory of OTHER ACDC schema registries (this.i
# @f7dr3k), rendered into a machine index and a human Ecosystem page.
FEDERATION_NAME = "federation.json"
REGISTRIES_PATH = "registries.json"
ACDC_SPEC_URL = "https://trustoverip.github.io/kswg-acdc-specification/"

# Layer 2 (this.i @m5tqw3): the published JSON Schema FOR the discovery manifest.
META_SCHEMA_SRC = "spec/acdc-schema-registry.schema.json"
META_SCHEMA_PATH = "acdc-schema-registry.schema.json"


def load_federation(root: str | Path) -> dict | None:
    """The parsed ``federation.json`` if the repo has one, else ``None``."""
    path = Path(root) / FEDERATION_NAME
    if not path.is_file():
        return None
    return json.loads(path.read_text())


# Untrusted content — schema title/name/version and, above all, third-party
# federation.json entries (name/operator/notes/homepage/…, contributable by PR) —
# is interpolated into generated HTML and Markdown. Escape it so the trusted
# resolver domain cannot carry stored injection (this.i @o6bw3k; review SEC-F1).
_SAFE_URL_SCHEMES = ("http://", "https://")


def _safe_url(url: str | None) -> str | None:
    """A URL safe to use as a link target, else ``None``.

    Only absolute http(s) URLs and site-relative paths are allowed; anything
    else (``javascript:``, ``data:``, …) is dropped so a federation entry cannot
    inject an active-content link into the published site.
    """
    if not url:
        return None
    u = url.strip()
    if u.startswith(_SAFE_URL_SCHEMES) or u.startswith("/"):
        return u
    return None


def _esc_html(value: object) -> str:
    """HTML-escape a value for safe interpolation into generated HTML."""
    return html.escape("" if value is None else str(value))


def _esc_md(value: object) -> str:
    """Escape a value for a Markdown table cell.

    Neutralizes raw-HTML injection (Markdown passes HTML through), table-cell
    breaks (``|``), and link/image/code syntax, and folds newlines to spaces so
    a single value cannot restructure the table.
    """
    text = html.escape("" if value is None else str(value))
    text = text.replace("\\", "\\\\")
    for ch in ("|", "[", "]", "`"):
        text = text.replace(ch, "\\" + ch)
    return text.replace("\n", " ").replace("\r", " ")


def _md_link(text: str, url: str | None) -> str:
    """A markdown link to a sanitized URL, or an em-dash when there is none/unsafe."""
    safe = _safe_url(url)
    return f"[{_esc_md(text)}]({safe})" if safe else "—"


def _front_matter(description: str) -> str:
    """YAML front-matter carrying a page ``description`` (unique <meta> for SEO)."""
    desc = " ".join(description.split())[:200].replace("\\", "\\\\").replace('"', '\\"')
    return f'---\ndescription: "{desc}"\n---\n\n'


def _schema_description(schema: dict, name: str) -> str:
    """A schema's own ``description``, or a sensible default for the meta tag."""
    return schema.get("description") or f"{name} — an ACDC credential schema."


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
    """Copy a schema folder's top-level files plus the ``examples/`` gallery.

    The ``invalid/`` should-reject corpus is deliberately NOT published; the
    ``examples/`` gallery (this.i @g4tn7w) IS, so the worked-example links in the
    narrative resolve on the site.
    """
    dst = out / entry.name
    dst.mkdir(parents=True, exist_ok=True)
    for item in sorted(entry.path.parent.iterdir()):
        if item.is_file():
            shutil.copy2(item, dst / item.name)
    if entry.examples:
        (dst / "examples").mkdir(exist_ok=True)
        for example in entry.examples:
            shutil.copy2(example, dst / "examples" / example.name)


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
        f'      <tr><td><a href="{_esc_html(s["schema"])}">{_esc_html(s["name"])}</a></td>'
        f'<td>{_esc_html(s["title"] or "")}</td><td><code>{_esc_html(s["version"] or "")}</code></td>'
        f'<td><a href="{_esc_html(s["oobi"])}" aria-label="OOBI for {_esc_html(s["name"])}">'
        f'<code>{_esc_html(s["said"][:12])}…</code></a></td></tr>'
        for s in schemas
    )
    return f"""<!doctype html>
<html lang="en">
<meta charset="utf-8">
<title>Bakobo ACDC schema registry</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body{{font:16px/1.5 system-ui,sans-serif;max-width:52rem;margin:3rem auto;padding:0 1rem}}
  table{{border-collapse:collapse;width:100%}} th,td{{text-align:left;padding:.4rem .6rem;border-bottom:1px solid #ddd}}
  code{{font-size:.85em}}
</style>
<h1>Bakobo ACDC schema registry</h1>
<p>General-purpose <a href="{ACDC_SPEC_URL}">ACDC</a>
credential schemas, each addressed by its SAID. Machine index:
<a href="{MANIFEST_PATH}">discovery manifest</a> · <a href="registry.json">registry.json</a>.
Source: <a href="https://github.com/bakobo/schema">github.com/bakobo/schema</a>.</p>
<table>
  <thead><tr><th scope="col">Schema</th><th scope="col">Asserts</th><th scope="col">Version</th><th scope="col">OOBI (SAID)</th></tr></thead>
  <tbody>
{rows}
  </tbody>
</table>
<p><em>Each schema also resolves as a SAID-addressed OOBI under <code>{_esc_html(base_url)}/oobi/&lt;said&gt;.json</code>.
A richer browsable site is in progress.</em></p>
</html>
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
    federation = load_federation(root)

    rows = []
    for entry in entries:
        schema = json.loads(entry.path.read_text())
        rows.append(f"| [{entry.name}]({entry.name}/) | {schema.get('title', '')} | `{schema.get('version', '')}` |")
    eco_link = " See also [other ACDC schema registries](ecosystem/)." if federation else ""
    landing = _front_matter(
        "Registry of general-purpose ACDC (Authentic Chained Data Container) credential schemas — "
        "GCD and more — each a KERI JSON Schema addressed by its SAID and resolvable as an OOBI."
    ) + (
        "# Bakobo ACDC schema registry\n\n"
        f"General-purpose [ACDC]({ACDC_SPEC_URL}) (Authentic Chained Data Container) credential "
        "schemas — GCD chief among them — for [KERI](https://trustoverip.github.io/kswg-keri-specification/)-"
        "based verifiable credentials. Each schema is a Draft 2020-12 JSON Schema addressed by its "
        "**SAID** (a self-addressing content hash) and resolvable as an **OOBI**. "
        f"Machine index: [registry.json](registry.json) · [discovery manifest]({MANIFEST_PATH}).{eco_link}\n\n"
        "| Schema | Asserts | Version |\n|---|---|---|\n" + "\n".join(rows) + "\n"
    )
    (out / "index.md").write_text(landing)

    # ``<name>/index.md`` (not a flat ``<name>.md``) so the page sits IN the schema
    # folder and its relative links to the schema JSON and icons resolve; the flat
    # sidebar link per schema comes from the explicit nav in zensical.toml (@z5nc4d).
    # Each page carries a unique <meta description> from its schema (this.i @s6eqk4).
    for entry in entries:
        schema = json.loads(entry.path.read_text())
        page_dir = out / entry.name
        page_dir.mkdir(exist_ok=True)
        (page_dir / "index.md").write_text(
            _front_matter(_schema_description(schema, entry.name)) + _schema_doc(entry)
        )

    if federation:
        eco = _front_matter(
            "Directory of known ACDC schema registries across the KERI ecosystem — GLEIF vLEI, "
            "Provenant, WebOfTrust and more — each schema SAID-addressed and OOBI-resolvable."
        ) + _render_ecosystem(federation)
        (out / "ecosystem.md").write_text(eco)

    return [entry.name for entry in entries]


def _render_ecosystem(federation: dict) -> str:
    """The 'Ecosystem' page: a table of known ACDC schema registries + specs."""
    reg_rows = []
    for r in federation.get("registries", []):
        label = _esc_md(r["name"]) + (" *(this site)*" if r.get("self") else "")
        home = _safe_url(r.get("homepage"))
        name_cell = f"[{label}]({home})" if home else label
        reg_rows.append(
            f"| {name_cell} | {_esc_md(r.get('operator', ''))} "
            f"| `{_esc_md(r.get('resolution', ''))}` "
            f"| {_md_link('repo', r.get('sourceRepo'))} · {_md_link('registry', r.get('registry'))} "
            f"| {_esc_md(r.get('notes', ''))} |"
        )
    spec_rows = [f"- {_md_link(s['name'], s['url'])}" for s in federation.get("specifications", [])]
    return (
        "# Ecosystem — other ACDC schema registries\n\n"
        f"[ACDC]({ACDC_SPEC_URL}) (Authentic Chained Data Container) credential schemas are published "
        "by several organizations across the KERI ecosystem. Because every schema is identified by its "
        "**SAID** (a content hash), the same schema is identical wherever it is served — a static site, "
        "a KERI **OOBI** endpoint (`/oobi/{said}`), or a source repository. This page indexes the "
        "registries we know of; the machine-readable version is [registries.json](registries.json).\n\n"
        "| Registry | Operator | Resolution | Links | Notes |\n|---|---|---|---|---|\n"
        + "\n".join(reg_rows) + "\n\n"
        "`resolution`: **static** = browsable schema JSON at stable URLs · **oobi** = served via KERI "
        "`/oobi/{said}` · **source-only** = repository, no confirmed public host · **unknown** = host "
        "not confirmed.\n\n"
        "## Specifications\n\n" + "\n".join(spec_rows) + "\n\n"
        "## Publish your own\n\n"
        f"Adopt the [discovery-manifest schema](../{META_SCHEMA_PATH}) — serve a "
        "`/.well-known/acdc-schemas.json` conforming to it, and your registry is machine-discoverable "
        "by the same convention. Then open a PR adding an entry to "
        "[`federation.json`](https://github.com/bakobo/schema/blob/main/federation.json).\n"
    )


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

    # discovery manifest — self-describing via a $schema pointer when the repo
    # publishes the Layer-2 meta-schema (this.i @m5tqw3)
    schemas = [_manifest_entry(entry, rel_to_said[entry.rel]) for entry in entries]
    manifest = {"baseUrl": base_url, "schemas": schemas}
    meta_src = root / META_SCHEMA_SRC
    if meta_src.is_file():
        shutil.copy2(meta_src, out / META_SCHEMA_PATH)
        manifest = {"$schema": f"{base_url.rstrip('/')}/{META_SCHEMA_PATH}", **manifest}
    body = json.dumps(manifest, indent=2) + "\n"
    canonical = out / MANIFEST_PATH  # .well-known/acdc-schemas.json
    canonical.parent.mkdir(parents=True, exist_ok=True)
    canonical.write_text(body)
    (out / ROOT_ALIAS_MANIFEST).write_text(body)  # non-dot alias

    # federation index of other ACDC registries, if the repo has one (@f7dr3k)
    federation = load_federation(root)
    if federation is not None:
        (out / REGISTRIES_PATH).write_text(json.dumps(federation, indent=2) + "\n")

    # custom domain, crawler hints, landing page
    (out / "CNAME").write_text(CNAME_HOST + "\n")
    (out / "robots.txt").write_text(
        f"User-agent: *\nAllow: /\nSitemap: {base_url.rstrip('/')}/sitemap.xml\n"
    )
    (out / "index.html").write_text(_render_index(base_url, schemas))

    return manifest
