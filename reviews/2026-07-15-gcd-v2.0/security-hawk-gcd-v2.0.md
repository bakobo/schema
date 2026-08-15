# Security Review: bakobo/schema

**Date / Effort / Commit:** 2026-07-15 / deep / `877e9f0` (main) — run label `gcd-v2.0`

## Attack surface enumerated

This is a **JSON-Schema publication repo**, not a running service. The trust-bearing
assets are the SAID-addressed schemas and the static site published to
`https://schema.bakobo.com`. I examined:

- **Entry points / untrusted-input paths.** The active toolchain is `tools/py/src/schematools`
  (`cli.py`, `checks.py`, `publish.py`, `repo.py`, `said.py`). It is a local/CI CLI, not a
  network listener — its "input" is repo files (schemas, examples, `registry.json`,
  `federation.json`, `this.i`). The one path that ingests **externally-authored** content is
  `federation.json`: the published Ecosystem page (`publish._render_ecosystem`) explicitly
  invites third parties to *"open a PR adding an entry to `federation.json`"*, so those fields
  are attacker-influenced (via PR) and flow into rendered HTML/Markdown.
- **Sinks.** `publish._render_index` (raw HTML string interpolation) and
  `publish._render_ecosystem` / `build_docs` (Markdown link interpolation) — both emit content
  served on the trusted domain. No SQL/exec/eval/deserialization of untrusted input in the live
  tooling. (`oldtools/api/server.py`+`serving.py` is a legacy falcon server, not built or
  deployed by this repo's active pipeline; noted but out of the live blast radius.)
- **Trust decisions / crypto.** `said.py` recomputes each schema's Blake3-256 SAID via keri's
  `Saider`/`SerderACDC`; `checks.check_said_integrity` compares recomputed vs embedded `$id`.
  keri is pinned **exact** (`keri==1.2.13`) because a different keri could silently change every
  SAID — a correct and important choice. `saidify_sad` finishes versioned ACDCs through
  `SerderACDC(makify=True)` so content edits (not just SAID-swaps) re-verify.
- **Supply chain.** Two workflows consume actions; `pages.yml` holds `pages: write` +
  `id-token: write`. Python deps are lockfile-frozen (`uv sync --frozen`). `zensical==0.0.50`
  and `keri==1.2.13` pinned exact; `jsonschema`/`pyyaml` floored.
- **Secrets.** No key material handled anywhere in the live tooling; SAIDs are public content
  hashes, not secrets. Grep for `key|secret|seed|passcode|private` in logging/serialize paths:
  clean.

## Executive summary

Posture is **good for a static-schema repo**: fail-closed publish (`cmd_publish` refuses to
build if any check fails), exact-pinned crypto oracle, no secrets in scope, no injection into an
exec/SQL sink. The most material exploitable path is **stored HTML injection into the published
site** via unescaped interpolation of schema/`federation.json` fields into `index.html` and the
Ecosystem Markdown — reachable because federation entries are solicited from third parties by PR.
The most urgent hygiene fix is the **supply-chain gap** in `pages.yml`: a third-party action is
pinned to a movable tag while the job can write Pages and mint an OIDC token, and
`upload-artifact@v4` runs on the deprecated node20 runtime.

## Top findings

### F1: Unescaped interpolation into published HTML/Markdown (stored injection on schema.bakobo.com)
- **Severity:** MEDIUM · **Confidence:** LIKELY · **Location:** `tools/py/src/schematools/publish.py:110-139` (`_render_index`), `:213-245` (`_render_ecosystem`), `:172-201` (`build_docs`)
- **Attacker:** an external party submitting a `federation.json` entry (the Ecosystem page
  explicitly solicits these by PR) — or, more weakly, a schema author controlling `title` /
  `description` / `version`.
- **Reachable path:** `_render_index` builds `index.html` by f-string interpolation of
  `s["name"]`, `s["title"]`, `s["version"]`, `s["said"]` **with no HTML escaping**;
  `_render_ecosystem` and `build_docs` interpolate `federation.json` `name` / `operator` /
  `homepage` / `notes` and each schema `title` straight into Markdown link/table syntax. A
  `homepage` of `javascript:alert(...)`, or a `title`/`notes` containing `<script>`, `<img
  onerror=…>`, or link-breaking `](...)`, lands verbatim in a page served from the trusted
  origin. `_front_matter` only escapes `\` and `"` for the YAML front-matter — nothing escapes
  the HTML/Markdown body.
- **Concrete effect:** stored XSS / content-spoofing on `schema.bakobo.com`, a domain whose
  whole purpose is to be a *trusted* resolver of credential schemas — script execution there can
  rewrite the very schema/OOBI links visitors copy.
- **Rubric item(s) failed:** #2 (untrusted input reaching a sink unbounded/unencoded), #6
  (data crossing a trust boundary — third-party PR content → trusted site — without validation).
- **Recommendation:** HTML-escape every interpolated value in `_render_index` (`html.escape`,
  and reject/scheme-allowlist `homepage`/URL fields to `https?:`); escape or strictly validate
  `federation.json` string fields before Markdown interpolation (at minimum forbid `<`, and
  constrain URLs to `http(s)`). Compensating control if deferred: the human+Copilot PR review on
  `federation.json`/schema changes is the only current gate — record it as the accepted control
  and add a schema-validation step for `federation.json` (a JSON Schema already exists at
  `spec/acdc-schema-registry.schema.json` for the manifest; add one for federation input).

### F2: Third-party action on a movable tag in the Pages-writing / OIDC job
- **Severity:** MEDIUM · **Confidence:** CONFIRMED · **Location:** `.github/workflows/pages.yml:34` (and `ci.yml:19`) — `astral-sh/setup-uv@v8.3.2`
- **Attacker:** whoever can move the `v8.3.2` tag on `astral-sh/setup-uv` (upstream compromise or
  a maintainer-account takeover of a third-party action).
- **Reachable path:** `pages.yml` runs with `pages: write` **and** `id-token: write`; a moved
  `v8.3.2` tag would execute attacker code in that job, which can poison the artifact that
  becomes `schema.bakobo.com` (serving forged schemas/OOBIs) and mint an OIDC token. The repo's
  own `infra.instructions.md` states the standard: *"Third-party actions pinned to a tag instead
  of a SHA — tags can be moved."* First-party `actions/*` are lower-risk; `astral-sh/setup-uv`
  is the third-party one.
- **Concrete effect:** supply-chain path to publishing forged credential schemas on the trusted
  resolver domain, and to an OIDC token, from a single upstream tag move.
- **Rubric item(s) failed:** #5 (mutable action tag / build that can inject into a release).
- **Recommendation:** pin `astral-sh/setup-uv` to a full commit SHA (`@<sha>  # v8.3.2`). It
  resolves today (verified against `git ls-remote`), so this is purely the movable-tag risk.

### F3: `upload-artifact@v4` runs on the deprecated node20 runtime
- **Severity:** LOW · **Confidence:** CONFIRMED · **Location:** `.github/workflows/pages.yml:61`
- **Attacker:** n/a (availability/hygiene, not directly exploitable).
- **Reachable path / effect:** GitHub has deprecated the node20 action runtime;
  `actions/upload-artifact@v4` (and `@v5`) still use `using: node20` (verified via each
  `action.yml`). The Pages deploy will emit deprecation warnings and eventually break, silently
  halting publication of schema fixes. `@v6`/`@v7` are node24.
- **Rubric item(s) failed:** #5 (supply-chain currency — the Bakobo GHA-runtime standard).
- **Recommendation:** bump to `actions/upload-artifact@v6` (node24-verified). While there,
  consider bumping `actions/deploy-pages`/`configure-pages` on the same currency check.

## Lower-severity notes

- **`load_federation` / `load_registry` / `_load_json` do unbounded `json.loads` on repo files.**
  Not attacker-controlled at runtime (repo-local, CI-gated), so no DoS surface — noted only so a
  future move to ingest a *remote* federation manifest re-triggers the bound/validation question.
- **`_front_matter` truncates to 200 chars but interpolates the untruncated `title`/`notes`
  elsewhere** — the escaping fix in F1 is the real control; no separate finding.
- **`oldtools/api/serving.py`** returns `application/schema+json` from an in-memory cache keyed by
  `said` with no auth — acceptable for public schema content, but this legacy server has no size
  bounds and prints on init; if it is ever revived, give it the F1 treatment. Currently not
  built/deployed, so out of scope for a fix obligation.

## What's done well

- **Fail-closed publish.** `cmd_publish` runs `checks.run_all` and refuses to build the site if
  *any* problem is found — the effect (publication) does not land when a check can't pass. This
  is org-principle-8 behavior done right.
- **Exact-pinned crypto oracle.** `keri==1.2.13` pinned exact with an explicit rationale that a
  different keri would change every SAID; the SAID-integrity check is the keystone invariant and
  is enforced in CI.
- **Least-privilege CI.** `ci.yml` sets `permissions: contents: read`; `pages.yml` scopes writes
  to exactly `pages`/`id-token`. `copilot-review-gate.yml` reads PR title/labels via `env:` (not
  inline interpolation into the shell), avoiding the classic GH-Actions script-injection sink.
- **Negative corpus as a real test.** `check_negative_examples` treats a schema *accepting* a
  should-reject fixture as a tracked defect (fail-closed on permissiveness), not a silent pass.
- **Frozen Python installs** (`uv sync --frozen`) — lockfile-respecting, matching the infra rule.

## Residual unknowns

- Whether `schema.bakobo.com` sets a restrictive `Content-Security-Policy` at the CDN/Pages layer
  would materially change F1's real-world severity (a strict CSP with no inline script would
  neutralize the `<script>` vector, leaving only content-spoofing / `javascript:` links). GitHub
  Pages sets no CSP by default, so I graded F1 assuming none; confirm at the hosting layer.
- I did not execute the test suite (unattended, no repo modification); the checks' fail-closed
  logic was read, not run. A `uv run pytest` in `tools/py` would confirm the SAID-integrity and
  negative-corpus gates behave as read.

## Findings manifest

```yaml
findings:
  - id: SEC-F1
    persona: security-hawk
    title: Unescaped interpolation of schema / federation.json fields into published HTML+Markdown (stored injection)
    severity: MEDIUM
    confidence: LIKELY
    location: tools/py/src/schematools/publish.py:110
    dedupe_key: publish-unsafe-html
    recommended_disposition: recommend-fix
    rationale: Third-party federation PR content (name/homepage/notes) and schema title/version are f-string-interpolated into index.html and Ecosystem Markdown with no escaping, yielding stored XSS / content-spoofing on the trusted schema.bakobo.com resolver.
    revisit_condition: null
    fix_effort: small
  - id: SEC-F2
    persona: security-hawk
    title: Third-party action astral-sh/setup-uv pinned to a movable tag in the Pages-writing / OIDC job
    severity: MEDIUM
    confidence: CONFIRMED
    location: .github/workflows/pages.yml:34
    dedupe_key: github-actions-unpinned
    recommended_disposition: recommend-fix
    rationale: pages.yml (pages:write + id-token:write) runs setup-uv@v8.3.2, a movable tag on a third-party action; a moved tag executes attacker code that can publish forged schemas to the trusted domain and mint an OIDC token — the repo's own infra standard requires SHA pins for third-party actions.
    revisit_condition: null
    fix_effort: small
  - id: SEC-F3
    persona: security-hawk
    title: upload-artifact@v4 runs on the deprecated node20 runtime in the Pages deploy
    severity: LOW
    confidence: CONFIRMED
    location: .github/workflows/pages.yml:61
    dedupe_key: github-actions-stale
    recommended_disposition: recommend-fix
    rationale: actions/upload-artifact@v4 (and v5) use node20, which GitHub has deprecated; the Pages publish will warn now and eventually break, silently halting schema publication. v6/v7 are node24.
    revisit_condition: null
    fix_effort: small
```
