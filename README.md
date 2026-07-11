# schema

Bakobo's home for **general-purpose [ACDC](https://trustoverip.github.io/tswg-acdc-specification/draft-ssmith-acdc.html)
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

## Status — captured, not yet evolved

> This is a fresh capture. The schemas are **as inherited** from public-schema;
> they have not yet been re-validated or re-SAIDified here.
>
> **Known issue (task #1):** `gcd/gcd.schema.json` is not valid JSON as inherited
> (an extra closing brace in/after the `c_upto` block). It must be repaired and
> re-SAIDified before use. See [`this.i` `@b6xh4m`](this.i).
>
> **GCD needs evolving** to the model in *The Shape of Delegated Authority*:
> it currently lacks `c_effect`, state-kind, target modulators, the
> relation/obligation facet, the may/must split, and `c_disc`. GCD is imbu's
> keystone delegation credential; evolving it is the near-term work.

## Tooling — provisional, to be decided

`tools/` holds the Python machinery from public-schema (SAIDification, registry
build, a small serving API) as a **reference to replicate in concept, not the
committed toolchain**. Whether this repo lands on browser-compatible TypeScript
(to enable browser-based schema-design and client-side validation tools) or
stays Python is an **open decision** — see [`this.i` `@p4zc7n`](this.i). The
Provenant deployment infra (Dockerfile / docker-compose / schema-registry
deployment) was intentionally not carried over.

## Working here

Read [`AGENTS.md`](AGENTS.md) and [`docs/methodology.md`](docs/methodology.md)
first — this repo is developed intent-first (decisions recorded in `this.i`
before the code they justify). Task tracking is via `tick` (run `tick init`
once to connect this clone to the ledger).

## License

[Apache-2.0](LICENSE). Derived from provenant-dev/public-schema; see
[`NOTICE`](NOTICE).
