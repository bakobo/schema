# Knowledge transfer — bootstrap prompt for an AI working on this repo

Point an assistant at this file (or paste it) at the start of a session in
`bakobo/schema`. It transfers the *why* and the mission. Then read
[`AGENTS.md`](AGENTS.md) (how to work here) and [`this.i`](this.i) (the
authoritative decisions).

---

## You are picking up `bakobo/schema`. Here is what you need.

### What this repo is

Bakobo's home for **general-purpose ACDC credential schemas**, chief among them
**GCD** — the **Generalized Cooperative Delegation** credential. The repo is a
**hard-fork of `provenant-dev/public-schema`** (captured at commit `8db57eb`,
Apache-2.0). We kept the general-purpose schemas Bakobo authored, removed
everything telco- and vLEI-specific, and now evolve them here independently. The
founding decisions and their rationale are in [`this.i`](this.i) (`@q3nv6t` and
children). Provenance is in [`NOTICE`](NOTICE).

**GCD is the point of this repo.** It is the delegation credential that Bakobo's
authority engine (imbu, a separate repo) enforces at runtime: a delegator issues
a GCD credential to a delegate, and a verifier checks a proposed act against the
credential's constraints. Everything else here is secondary.

### Mission status — Task 1 and Task 2 are DONE

**Task 1 — repair GCD's JSON and re-SAIDify — DONE.** The inherited
`gcd/gcd.schema.json` was **not-valid-JSON** (an extra closing brace in/after the
`c_upto` block). It was captured byte-for-byte for provenance, then repaired and
re-SAIDified with the committed tooling (never hand-editing the `$id`), and
`registry.json` brought back into sync.

**Task 2 — evolve GCD to the full delegated-authority model — DONE (v2.0).** GCD
was grown to carry the whole model from *The Shape of Delegated Authority* (on
this machine typically `../../papers/sda.md`) as a **new version keeping the old**:
`gcd/gcd.schema.json` is now `2.0.0`, and `1.0.0` is preserved intact and
registered under `gcd-1.0.0/`. The field-level decisions are in [`this.i`](this.i)
under `@h4tqm7` (`@k7wd3m`, `@x4nq6t`, `@v3rk5p`), `@r5dnk2` (`@m6tq4w`), and
`@b6xh4m` (`@r5vk3n`).

#### The v2.0 shape (what to know)

The attributes block (`a`) drops the flat `c_` prefix for **named containers**:

- **`facet`** — the relationship facet: `role`, `relationType` (delegation /
  guardianship / controllership / stewardship — whose interest governs),
  `liableParty` (who answers outward if it goes wrong; renamed from the paper's
  `obligationBearer`), `presentsAs` (the facet-AID the act is presented under),
  and `exerciseMode` (`act` / `authorize` / `both` — authority-to-act vs
  authority-to-authorize as independent axes; a pure delegator is `authorize`
  with empty goals). Permissive/safe-ignore: only `constraints` gates.
- **`constraints`** — the enabling "may", **fail-closed**
  (`additionalProperties: false`): `goals`, `effects`
  (observe/create/modify/preserve/destroy — a *separate lock* from goals, so a
  read-only delegate holds `effects: ["observe"]`), `stateKinds`
  (information/record/commitment/authority/resource/relationship), `domains`,
  `jurisdictions`, `physGeos`/`virtGeos`, `icals`, `monetaryLimit` (money-locked),
  `protos`, `proofs`, `validFrom`/`validUntil`, `humanReview`.
- **`terminatingEvents`** — sibling of `constraints`: the voiding polarity —
  proof-shaped attested events that end the authority; requires a `validUntil`
  backstop.
- **`disclosables`** — sibling of `constraints`: the *outbound* axis — the
  credential schemas a delegate may reveal about its principal.

The rules block (`r`) keeps the five disclaimers (with the third renamed from
`noConstraintSansPrefix` to `noConstraintOutsideConstraints`) and adds a
first-class **`duties`** array (the "must"), keyed by `bearer`: a delegate duty
`{bearer, effect, goal, cadence?, priority}` and an issuer duty
`{bearer, rule, l?, priority}`. `timelyReviewAndRevoke` ships as the baseline
issuer duty. The reciprocal-record "must" is the GCD's own `r` block, not a
second credential (`@r5dnk2`).

Reserved but **not** in v2.0 (recorded in intent, pulled when a real need
appears): finer disclosure vocabulary (`{schema, to, linkable}`), a live
`untilObserved` predicate, a redress pointer, and counterparty qualification.

New design still follows **intent-first**: record each decision in `this.i` in
its **own commit before** the schema change, with a `why` that meets the
rebuttal-surface standard (see [`AGENTS.md`](AGENTS.md) → `dev/methodology.md`).

### Hard facts about ACDC schemas (respect these)

1. **`$id` is a SAID.** It is derived from the saidified schema content. Edit
   content → the SAID changes → `registry.json` and any credential referencing the
   old SAID must be updated. Never invent or hand-patch a SAID.
2. **`registry.json`** is the crawl-free index of released schemas (`SAID →
   path`). Keep it in sync when you add/re-SAIDify.
3. **The compact/expanded `oneOf` pattern.** Each block (`a`, `e`, `r`) is either a
   SAID string (compact) or the full object (expanded). Preserve both arms.
4. **`e` (edges).** GCD's `$comment` says GCD credentials need no chaining, but it
   carries an optional `issuer` edge with the `I2I` operator. Understand it before
   touching it.

### Tooling

The committed toolchain is the **Python** package [`tools/py`](tools/py)
(`schematools`: SAID computation, the conformance linter, registry maintenance,
`publish`/`build-docs`), driven by uv + pytest at 100% branch coverage; keri is
the pinned SAID oracle (`@xv4m7d`, `@m4vd7s`). The inherited public-schema
scripts are kept for reference under [`oldtools`](oldtools). A `tools/ts` sibling
is *reserved* for a possible future browser/TypeScript layer — whether that layer
gets built, and whether it is TypeScript or stays Python, is still the **open
decision the human owns** (`@p4zc7n`); the near-term work stays Python
(`@s6bq2w`). The Provenant Docker/registry-deployment infra was intentionally not
carried over.

### Decisions you must NOT make silently — surface to the human

- **TypeScript vs Python** for a future browser schema-design / client-side
  validation layer (`@p4zc7n`) — still open.
- **Two borderline strips** to reconsider (re-import from public-schema if wanted):
  `brand-owner` (non-OVC sibling of the telco branded-calling pair) and
  `aegis-std-vetting` (telco-vendor vetting) — see `@k5wd2r`.
- The **root of the delegation chain** (leaning: a threshold of owners via joint
  issuance) — open in the theory. (The `may`/`must` split is **resolved**: the
  "must" is the GCD's own `r`-block duties, not a second credential — `@r5dnk2`.)

### House rules (from the Bakobo environment)

- **Intent-first:** record decisions in `this.i` in their **own commit, before**
  the code/schema commit they justify (`../dev/methodology.md` §5). A decision not in
  `this.i` is not yet made.
- **DCO:** sign every commit — `git commit -s`.
- **`tick`** for task/tech-debt tracking — `tick ls` / `tick grep` to see open
  work (e.g. `~44oc`, the cross-repo reconcile of imbu/org to the v2.0 container
  names).
- **GitHub Actions:** pin node24-runtime action versions (avoid node20).
- If you add tooling/tests, follow strict TDD (100% branch coverage) — CI runs
  `uv run pytest` and a fail-closed Pages deploy.

### First moves

1. Read `this.i` (`@q3nv6t`, `@k5wd2r`, `@b6xh4m` and its children, `@tq5wnh`,
   `@p4zc7n`), `AGENTS.md`, `../dev/methodology.md`, and `gcd/index.md`; read
   `../../papers/sda.md` if present.
2. `cd tools/py && uv sync && uv run pytest` to confirm a green baseline, and
   `uv run schematools check` to lint the corpus.
3. Pick up open work from `tick ls` (the v2.0 schema itself is done). The largest
   is `~44oc`: propagate the `c_*` → container rename into imbu (`@v2kd7m`,
   `@nf5rx7`) and org (`@dwx5twwyh`, `@ot4puqrj`) plus the upstream `pap`
   `policy-schema.md`.
4. For any new design, run the speculative interview, record intent in `this.i`
   **before** the code, then implement test-first.
