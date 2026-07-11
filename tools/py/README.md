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
