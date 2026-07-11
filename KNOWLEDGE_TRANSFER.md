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

### Your mission, in priority order

**Task 1 — repair GCD's JSON and re-SAIDify.** `gcd/gcd.schema.json` was
inherited **not-valid-JSON**: there is an extra closing brace in/after the
`c_upto` block (~line 180). It was captured byte-for-byte on purpose (faithful
provenance), and fixing it is the first job. Because the schema's `$id` is a
**SAID** (a self-addressing hash over the saidified content), any byte change
invalidates it — so repair the JSON *and* regenerate the SAID (and the
`registry.json` entry) with proper tooling; do not just hand-edit the `$id`.

**Task 2 — evolve GCD to the full delegated-authority model.** The captured GCD
(`version 1.0.0`) predates the model in *The Shape of Delegated Authority* (the
canonical theory; on this machine it is typically at `../../papers/sda.md` — read
it if present). Grow GCD to carry the whole model, as a **new version that keeps
the old one intact** (don't mutate `1.0.0` in place beyond the Task-1 repair).

#### What GCD already has (keep it)

`c_goal` (Aries goal codes, wildcard-matched), `c_jur` (jurisdictions),
`c_pgeo`/`c_rgeo` (physical/remote geo), `c_ical` (time/URL windows via
iCalendar), `c_upto` (financial stakes ceiling), `c_proto` (protocol+roles),
`c_prove` (inbound IPEX proof requests), `c_human` (human-judgment-required),
`c_after`/`c_before` (validity window), `role` + `gfw` (a governance-framework
SAID that gives `role` and custom fields their semantics), and a `rules` block of
disclaimers (`noRoleSemanticsWithoutGfw`, `issuerNotResponsibleOutsideConstraints`,
`noConstraintSansPrefix`, `useStdIfPossible`, `onlyDelegateHeldAuthority`). The
convention that *all constraints live in `c_`-prefixed fields* (or in `role` when
`gfw` is defined) is load-bearing — preserve it.

#### What GCD is missing (the evolution)

From *The Shape of Delegated Authority*, GCD needs these added, each as a distinct
constraint or facet — MECE and independently matchable, absence = no constraint:

- **`c_effect`** — the effect axis: `observe` / `create` / `modify` / `preserve` /
  `destroy`. A *separate lock* from `c_goal` (telos), so a read-only delegate holds
  `c_effect: [observe]` and cannot mutate even inside a permitted goal. This is the
  single most important addition.
- **state-kind + target modulators** — an act is located over a *named kind of
  state* (`information` / `record` / `commitment` / `authority` / `resource` /
  `relationship`), and the gate turns on *target* attributes (externality,
  reversibility, value, shared-ness). Decide how GCD carries these (on the
  credential, or as evaluation inputs the credential scopes).
- **the relation/obligation facet** — `relationType` (delegation / guardianship /
  controllership / stewardship — whose interest governs), `obligationBearer` (who
  answers if it goes wrong), `presentsAs` (the identity the act is presented
  under), and **authority-to-act vs authority-to-authorize** as independent axes
  (a pure delegator has broad authority-to-authorize and an empty act surface).
- **may vs must** — today GCD is all `may` (permissions). `must` (duties: obligatory
  `(effect, goal)` pairings, optionally with a cadence) belongs on the delegator-
  signed **reciprocal record**. Decide the split between the delegation credential
  and the reciprocal record — this is genuinely open (the paper flags it).
- **`c_disc`** — the *outbound* mirror of `c_prove`: what a delegate may reveal
  about its principal, to whom, unlinkably. Reserve the axis; vocabulary is open.

Do the design **intent-first**: record each of these as a decision in `this.i`
(children of `@b6xh4m`) *before* you change the schema, with a `why` that meets the
rebuttal-surface standard (see `docs/methodology.md`).

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

### Tooling is PROVISIONAL — do not assume it

`tools/` is public-schema's **Python** machinery (saidify, registry build, check,
a serving api), copied as a **reference to replicate in concept, not the committed
toolchain** (`this.i` `@p4zc7n`). Whether this repo lands on **browser-compatible
TypeScript** (to enable browser-based schema-design and client-side
SAIDification/validation tools) or **stays Python** is an **open decision the human
owns** — surface it, don't silently pick. If you need to SAIDify for Task 1/2, use
the reference tools *or* propose an approach and get agreement first. The Provenant
Docker/registry-deployment infra was intentionally not carried over.

### Decisions you must NOT make silently — surface to the human

- **TypeScript vs Python** for the toolchain, and whether to build browser-based
  schema-design tools (`@p4zc7n`).
- **Two borderline strips** to reconsider (re-import from public-schema if wanted):
  `brand-owner` (non-OVC sibling of the telco branded-calling pair) and
  `aegis-std-vetting` (telco-vendor vetting) — see `@k5wd2r`.
- The **delegation-record vs reciprocal-record split** for `may`/`must`, and the
  **root of the delegation chain** (leaning: a threshold of owners via joint
  issuance) — both are open in the theory.

### House rules (from the Bakobo environment)

- **Intent-first:** record decisions in `this.i` in their **own commit, before**
  the code/schema commit they justify (`docs/methodology.md` §5). A decision not in
  `this.i` is not yet made.
- **DCO:** sign every commit — `git commit -s`.
- **`tick`** for task/tech-debt tracking — run `tick init` once to connect this
  clone (Task 1's JSON repair is a natural first `tick`).
- **GitHub Actions:** pin node24-runtime action versions (avoid node20).
- If you add tooling/tests, follow strict TDD and propose CI (the template
  `AGENTS.md` instructions self-retire as you do).

### First moves

1. Read `this.i` (`@q3nv6t`, `@k5wd2r`, `@b6xh4m`, `@p4zc7n`), `AGENTS.md`,
   `docs/methodology.md`, and `gcd/index.md`; read `../../papers/sda.md` if present.
2. `tick init`, then `tick add` the GCD JSON repair.
3. Do **Task 1** (repair + re-SAIDify GCD, fix `registry.json`) as a clean,
   test-or-validation-backed change — that alone gets the repo to a valid baseline.
4. Open the **Task 2** speculative interview with the human (the `may`/`must` split
   and how state-kind/target are carried are the questions that collapse the most
   forks), record intent in `this.i`, *then* evolve the schema.
