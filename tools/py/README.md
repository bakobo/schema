# schematools (Python)

The Python tooling for this schema repo: SAID computation, a repo-wide
conformance linter, and registry maintenance. It is the **committed** toolchain
that replaces the inherited reference scripts now in [`../../oldtools`](../../oldtools).

- **keri is the SAID oracle** (`this.i` `@xv4m7d`), pinned exactly to `1.2.13`
  (`@m4vd7s`). Any change to that pin must re-verify SAID identity.
- **Generic in shape** (`@c5tj3p`): everything is driven by the
  `registry.json` + `<folder>/<folder>.schema.json` convention, so this tooling
  serves any issuer's schema repo, not just this one.
- The reserved sibling [`../ts`](../ts) is where a future browser/TypeScript
  layer would live (`@w3kp6m`); it does not exist yet.

## Setup

```bash
cd tools/py
uv sync
```

## Use

```bash
uv run schematools check                 # run all conformance checks over the repo
uv run schematools saidify -f ../../gcd/gcd.schema.json      # (re)SAID a schema file
uv run schematools saidify-sad -f ../../gcd/example.json     # (re)SAID an ACDC instance
uv run schematools registry              # rebuild ../../registry.json from disk
```

`check` auto-detects the repo root by walking up to the nearest `registry.json`.

## Tests

```bash
uv run pytest
```

Two suites:

- **`tests/unit/`** — proves *the tooling* works, using synthetic schema repos
  built in temp dirs (no dependency on the real corpus).
- **`tests/conformance/`** — runs the checks against the *real* schemas in this
  repo and asserts each is clean. Known pre-existing defects are
  `xfail(strict=True)` with a tracking `tick` id, so a fix flips them to XPASS
  and forces the marker's removal.

## Checks (the linter — `this.i` `@n7xk4r`)

| Check | Invariant |
|---|---|
| `structure` | valid JSON + valid Draft 2020-12 schema |
| `said` | recomputed SAID == embedded `$id` (the keystone) |
| `registry` | `registry.json` ⇔ disk agree; indexed once; no orphans/dangling |
| `example` | `<folder>/example.json` validates against its schema |
| `example_ref` | an example's `s` equals its schema's `$id` (referential integrity) |
| `example_said` | an example instance is internally SAID-consistent (a re-saidify fixed point) |
| `negative` | every `<folder>/invalid/*.json` is REJECTED by its schema |
| `envelope` | the ACDC v2 envelope (`this.i` `@jruwvxnt`): `rd` not `ri`, `t` declared, canonical top-level order, no v1-era inner `$id`, compact string arm first in every `oneOf` |
| `intent_yaml` | `this.i` at the repo root parses as YAML |

`check` runs all of them. **`publish` gates on all of them except `envelope`** —
`@r5vk3n` keeps superseded v1 schemas (`gcd-1.0.0`, `gcd-2.0.1`,
`proof-of-control-1.1.0`) published byte-identical and forever so their SAIDs
stay resolvable, so a v1 envelope is not a defect in a published artifact; it
says which issuer can mint against it, which is a maintainer's question. The
`envelope` check skips archived `<family>-<semver>/` directories and any schema
that is not a credential (no `d`, no `a`/`A`).
