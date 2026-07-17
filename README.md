# schema

[![CI](https://github.com/bakobo/schema/actions/workflows/ci.yml/badge.svg)](https://github.com/bakobo/schema/actions/workflows/ci.yml)

Bakobo's home for **general-purpose [ACDC](https://trustoverip.github.io/kswg-acdc-specification/)
credential schemas** — chief among them **GCD**, the Generalized Cooperative
Delegation credential.

This repo is a **hard-fork of [provenant-dev/public-schema](https://github.com/provenant-dev/public-schema)**
(captured at commit `8db57eb`, Apache-2.0 — see [`NOTICE`](NOTICE)). We took the
general-purpose schemas we authored, removed everything telco- or vLEI-specific,
and now evolve them here at Bakobo, independently of Provenant's roadmap. The
*why* — and the decisions that follow — live in [`this.i`](this.i) (the intent
tree, `@q3nv6t`); this README is a derived summary.

## What's here

Each schema lives in its own directory (`<name>/<name>.schema.json`, plus an
`index.md`, examples, and icons). All released schemas are enumerated in
[`registry.json`](registry.json) so they are discoverable without crawling.

| Schema | What it asserts |
|---|---|
| **[gcd](gcd/)** | **Generalized Cooperative Delegation** — the authorizations, duties, and constraints of a delegate |
| [ai-coder](ai-coder/) | a developer is committed to and capable of using AI coding tools responsibly |
| [ai-user-coca](ai-user-coca/) | commitment to a code of conduct for AI use |
| [attestation](attestation/) | verifiable attestation of a data digest |
| [award](award/) | conferral of an award on a person or group |
| [bindkey](bindkey/) | issuer uses a key not directly managed by its KEL |
| [citation](citation/) | a formal reference to non-ACDC content |
| [dossier-base](dossier-base/) | base schema for verifiable dossiers (issuer-curated evidence) |
| [faa](faa/) | a tamper-evident cryptographic identity for arbitrary binary data |
| [face-to-face](face-to-face/) | issuer knows the issuee to be a human, from in-person contact |
| [org-vet](org-vet/) | authenticate an org at an explicit level of assurance |
| [proof-of-control](proof-of-control/) | issuee demonstrated control of a digital resource |
| [sedi-id](sedi-id/) | Utah State-Endorsed Digital Identity root (name, birth date, image, residence) as a partially-disclosable attribute section |
| [sedi-age](sedi-age/) | derived state-endorsed aggregate age-threshold vector (ageOver13/16/18/21/55/65; prove over-21 without the birth date) |
| [sedi-present-age-portrait](sedi-present-age-portrait/) | holder-issued SEDI presentation: prove over-21 and show the state-endorsed photo (I2I edges to sedi-id + sedi-age) |
| [sedi-guardian](sedi-guardian/) | SEDI digital guardian: recognized legal authority to act for a ward (four statutory bases; composes with GCD) |

## Status

GCD's inherited JSON was **repaired and re-SAIDified** (Task 1), and GCD has now
been **evolved to v2.0** (Task 2). The attributes block is organized into named
containers — a `facet` (`relationType`, `liableParty`, `presentsAs`,
`exerciseMode`) and a fail-closed `constraints` gate (`goals`, `effects`,
`stateKinds`, `domains`, `jurisdictions`, `physGeos`/`virtGeos`, `icals`,
`monetaryLimit`, `protos`, `proofs`, `validFrom`/`validUntil`, `humanReview`) —
with sibling `terminatingEvents` (voiding) and `disclosables` (outbound) axes,
and first-class `duties` in the rules block. Version `1.0.0` is preserved intact
under [`gcd-1.0.0/`](gcd-1.0.0/). The whole corpus is validated in CI — SAID
integrity, registry consistency, JSON-Schema validity, example validation,
referential + example SAID integrity, and a should-reject negative corpus. See
[`this.i` `@b6xh4m`](this.i) and [`@tq5wnh`](this.i).

## Tooling

The committed toolchain is the Python package in [`tools/py`](tools/py): SAID
computation (for schemas and ACDC instances), a repo-wide conformance linter,
and registry maintenance, driven by uv + pytest. keri is the SAID oracle, pinned
exactly. The inherited public-schema scripts are kept for reference in
[`oldtools`](oldtools); a `tools/ts` sibling is reserved for a possible future
browser/TypeScript layer. Whether that layer gets built — and the Provenant
deployment infra that was intentionally not carried over — are recorded in
[`this.i`](this.i) (`@w3kp6m`, `@p4zc7n`).

## Development

From a fresh clone:

```bash
cd tools/py
uv sync
uv run pytest        # tooling unit tests + the corpus conformance suite
```

`uv run schematools check` runs the conformance linter over the whole repo; see
[`tools/py/README.md`](tools/py/README.md) for the full command set. Every push
and PR runs the suite in CI (badge above) behind a 100%-branch-coverage gate.

## Working here

Read [`AGENTS.md`](AGENTS.md) and [`dev/methodology.md`](../dev/methodology.md)
first — this repo is developed intent-first (decisions recorded in `this.i`
before the code they justify). Task tracking is via `tick` (run `tick init`
once to connect this clone to the ledger).

## License

[Apache-2.0](LICENSE). Derived from provenant-dev/public-schema; see
[`NOTICE`](NOTICE).
