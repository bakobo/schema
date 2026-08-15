# Intent & Spec Conformance Review: bakobo/schema

**Date / Effort / Commit:** 2026-07-15 / deep / `877e9f0` (main) · run_label `gcd-v2.0` · mode unattended

## Intent surface audited

- **`this.i`** in full (797 lines): the GCD-v2.0 evolution subtree (`@b6xh4m` → `@h4tqm7` →
  `@k7wd3m`/`@x4nq6t`/`@v3rk5p`; `@r5dnk2` → `@m6tq4w`; `@r5vk3n`), the house-style node `@p6mwk4`,
  the tooling nodes (`@tq5wnh`, `@n7xk4r`, `@n6dqw2`, `@d7km4v`/`@p3rk6d`, `@f4mt6k`, `@xv4m7d`,
  `@m4vd7s`, `@w3kp6m`, `@c5tj3p`), the publication nodes (`@pv6k3d`, `@o6bw3k`, `@z5nc4d`,
  `@f7dr3k`, `@s6eqk4`, `@m5tqw3`, `@c5nq7d`), and the SDA-theory nodes (`@tj6vq4`, `@v5nq2r`,
  `@g7rkn4` + children).
- **Code surfaces:** `gcd/gcd.schema.json` (the v2.0 schema — `a.facet`, `a.constraints`,
  `a.terminatingEvents`, `a.disclosables`, `r.duties`, the `if/then` `validUntil` backstop),
  `gcd/example.json`, `gcd/rules.json`, `gcd/invalid/*` (10-fixture negative corpus),
  `gcd-1.0.0/` archive, `registry.json`, `spec/acdc-schema-registry.schema.json`, `federation.json`,
  the `schematools` CLI surface, `docs/style.md`, `gcd/index.md`, `README.md`, `KNOWLEDGE_TRANSFER.md`.
- **Spot-checks run:** `git log --follow` on `gcd/gcd.schema.json` and `gcd/example.json` vs
  `git log -- this.i`; SAID recomputation of `gcd` and `gcd-1.0.0` against the keripy oracle
  (both MATCH); `example.s` == registry gcd SAID (match); `jsonschema` exercise of the `if/then`
  backstop (fires correctly) and the `exerciseMode`/`goals` coupling; full `uv run pytest`
  (175 passed, 100% branch) and `schematools check` (0 problems, 12 schemas).

## Executive summary

The GCD v2.0 code is **substantively faithful** to a richly recorded intent tree: every consequential
surface (the named containers, the fail-closed `constraints` gate, the voiding/disclosure siblings,
first-class `duties`, the 1.0.0 archive, the meta-schema, the federation layer) has a matching
`this.i` node, and the field-level decision nodes were committed **before** the schema code
(`f1bd941`/`ffc041c` precede `35641b7`). The two real conformance gaps are **metadata staleness, not
model divergence**: (1) every v2.0 GCD intent node still reads `stage-status: planned`/`in-progress`
while the work is shipped and declared DONE — an auditor reading the tree is told this is unbuilt; and
(2) the house-style node `@p6mwk4` records `juris` as the chosen abbreviation, but the code and its own
derived `docs/style.md` shipped `jurisdictions` and the doc silently reversed the node without updating
it. The most urgent fix is the stage-status sweep, because it makes the *entire* v2.0 subtree misleading
about whether it reflects reality.

## Conformance assessment

1. **Code ↔ intent agreement — strong.** The v2.0 schema matches its nodes field-for-field:
   `constraints` is `additionalProperties:false` with closed `effects`/`stateKinds` enums (`@k7wd3m`);
   `facet` is permissive (`@k7wd3m`); `exerciseMode` is the `act|authorize|both` enum (`@x4nq6t`);
   `terminatingEvents`/`disclosables` are a-block siblings with the `validUntil` `if/then` backstop
   (`@v3rk5p` — verified to fire); `duties` is the bearer-discriminated `oneOf` array in `r`, with
   `timelyReviewAndRevoke` as the baseline issuer duty and `noConstraintSansPrefix` renamed to
   `noConstraintOutsideConstraints` (`@m6tq4w`, `@r5dnk2`); 1.0.0 is preserved as a registered
   directory (`@r5vk3n`). No unrecorded §3-trigger surface found. **One divergence** in the house-style
   node (F2).
2. **Commit order — clean.** `f1bd941` (records `@k7wd3m @x4nq6t @v3rk5p @m6tq4w @r5vk3n`) and
   `ffc041c` (records `@h4tqm7 @r5dnk2`) both land **before** `35641b7` (authors the schema/example/
   corpus). The intent-before-code discipline holds for the v2.0 evolution. One minor bundling note:
   `bb591be` committed `docs/style.md` (a derived doc) together with its `@p6mwk4` node — acceptable,
   since style.md is derived narrative, not code, but see F2 for the consequence.
3. **`why` quality — excellent.** The v2.0 `why` fields are among the strongest in the tree: each
   names rejected alternatives (free-string enums, fail-closed facet, a paired second credential,
   boolean `canAct`/`canAuthorize`, archived-in-place vs versioned directory) with explicit tradeoffs.
   Meets the rebuttal-surface standard throughout.
4. **Deviations — consistent.** No new standard-gap was introduced without a node; `@d7km4v`/`@p3rk6d`
   handle the inherited schema defects as an approved re-mint, and `@f4mt6k` records the format-assertion
   posture with `cesr` left explicitly unchecked. 100% branch coverage holds with no `deviation:` needed.
5. **Tensions — honored.** `@r5dnk2` resolves the may/must open (`@d5tqm6`, org `@ot4puqrj`) by placing
   duties in `r`, and the code implements exactly that — no silent re-resolution. `@d7km4v` is
   `partially-resolved` and its child `@p3rk6d` records the fix, matching the shipped schemas.
6. **Spec MUSTs — n/a as a governing external spec**, but the schema's own normative claims were
   checked: the `constraints` "unrecognized key → fail closed" MUST is enforced
   (`constraints-unknown-key` fixture rejected) and the "terminatingEvents ⇒ validUntil" MUST is
   enforced by the `if/then` (verified). SAID integrity (the ecosystem's real MUST) holds for both
   versions.

## Top findings

### F1: Every shipped GCD v2.0 intent node still reads `planned`/`in-progress` — the tree misrepresents completed work as unbuilt — HIGH / CONFIRMED / `this.i` @b6xh4m, @h4tqm7, @k7wd3m, @x4nq6t, @v3rk5p, @r5dnk2, @m6tq4w, @r5vk3n

- **What the intent says:** `@b6xh4m` and `@h4tqm7` carry `stage-status: planned`; `@k7wd3m`,
  `@x4nq6t`, `@v3rk5p`, `@m6tq4w`, `@r5vk3n` carry `stage-status: in-progress`. Zero v2.0 nodes read
  `done`. Methodology §1 cold-start stance #1: *"A node may describe planned work; the `stage-status:`
  field says which. Read it before assuming a node reflects code that exists."*
- **What the code does:** The work is complete and declared so. `README.md` §Status and
  `KNOWLEDGE_TRANSFER.md` both state "Task 2 — evolve GCD to the full model — **DONE (v2.0)**"; the
  schema is authored and SAID-minted (`EIqGVj_…`, verified), `gcd-1.0.0/` is archived and registered,
  175 tests pass at 100% branch, `schematools check` is clean. `@r5vk3n` (in-progress) literally
  describes "gcd/ becomes 2.0.0" and 1.0.0 preservation — both *done*.
- **The gap:** An auditor or future contributor reading `this.i` alone is told the flagship evolution is
  planned/underway, contradicting the shipped artifact and the derived docs. This inverts the intent
  layer's job (the tree is supposed to be the trustworthy account of reality). The `check_intent_yaml`
  guard validates YAML but not stage-status accuracy, so nothing catches it.
- **Recommendation:** Sweep the eight nodes to `stage-status: done` (or remove the field where "done" is
  the tree's default), as part of closing the gate for this phase. Do not edit `this.i` from this review.

### F2: House-style node `@p6mwk4` records `juris`, but code + derived doc shipped `jurisdictions`; the derived doc reversed the node without updating it — MEDIUM / CONFIRMED / `this.i` @p6mwk4 vs docs/style.md:21 & gcd/gcd.schema.json

- **What the intent says:** `@p6mwk4`'s `why` names **`juris`** three times as the chosen abbreviation —
  "(so juris / phys / virt / val / proto pass)", the plural list "…virtGeos, **juris**)", and
  "constraints.**juris** needs no legalJurisdiction". The node presents `juris` as a settled, passing
  choice and even models the intended field name.
- **What the code does:** The schema field is **`jurisdictions`** (full word), and the derived
  `docs/style.md` rule 4 explicitly *reverses* the node: "`jurisdiction` stays `jurisdictions`, **never
  `juris`** (a bare `juris` does not read as a plural)." Code and derived doc agree with each other; only
  the source-of-truth node disagrees with both.
- **The gap:** This is a silent re-resolution in the *derived* layer — exactly the inversion methodology
  §0 forbids ("`docs/` never introduces a decision that isn't in `this.i`"; when they disagree, the tree
  is authoritative or must be updated deliberately). Here the tree is now *wrong* relative to the shipped
  contract, and a future author citing `@p6mwk4` would reintroduce `juris`.
- **Recommendation:** Update `@p6mwk4`'s `why` to record the reversal — that plural-legibility overrode
  the abbreviation for `jurisdiction`, so `juris` was rejected in favor of `jurisdictions` — matching
  style.md rule 4. (Recording the *why* of the reversal is the point, not just swapping the token.)

### F3: `README.md` and `KNOWLEDGE_TRANSFER.md` point readers at `docs/methodology.md`, which does not exist — MEDIUM / CONFIRMED / README.md:79, KNOWLEDGE_TRANSFER.md:123,136

- **What the intent/docs say:** `README.md` §Working here: "Read `AGENTS.md` and
  [`docs/methodology.md`](docs/methodology.md) first". `KNOWLEDGE_TRANSFER.md` cites `docs/methodology.md`
  §5 and lists it among "First moves" reading. The `this.i` header comment (line 4) also says
  "(docs/methodology.md)".
- **What the code does:** `docs/` contains only `style.md`. `git log` shows `docs/methodology.md` was
  deliberately removed in `9f9f931` ("Reference bakobo/dev for methodology; vendor Tier-1 standards
  block") — the canonical methodology now lives in the sibling `bakobo/dev` repo, and `AGENTS.md`
  correctly points at `../dev/methodology.md`.
- **The gap:** Three high-traffic onboarding references dangle to a deleted file. A first-time reader
  (human or AI, and KNOWLEDGE_TRANSFER.md is explicitly the AI bootstrap prompt) following "First moves"
  hits a 404. This is derived-narrative drift left behind a deliberate `this.i`-honored move.
- **Recommendation:** Repoint the three references to `../dev/methodology.md` (as `AGENTS.md` already
  does), or to the intent methodology as summarized in `AGENTS.md`. The `this.i` header comment is a
  comment on the source-of-truth file — leave that to the maintainer; do not edit `this.i`.

### F4: `example.json` reuses the edge `issuer.n`/`issuer.s` SAIDs for `terminatingEvents`/`disclosables`, blurring three semantically distinct axes — LOW / LIKELY / gcd/example.json:57-62

- **What the intent says:** `@v3rk5p` — `terminatingEvents` items are proof-request SAIDs for *attested
  voiding events*; `disclosables` items are *credential-schema* SAIDs the delegate may reveal. `@b6xh4m`
  keeps the `e.issuer` I2I edge as the issuer-identity chain. These are three different referents.
- **What the code does:** In the example, `a.terminatingEvents[0]` == `e.issuer.n` and
  `a.disclosables[0]` == `e.issuer.s` — the voiding-event and outbound-disclosure axes point at the same
  SAIDs as the issuer edge's node and schema.
- **The gap:** The instance is valid and this is not a schema violation, but as the canonical worked
  example it makes the three axes look coupled to the issuer edge, undercutting the pedagogy of
  `@v3rk5p`'s deliberate separation of polarities. `example.json` is intent-adjacent documentation
  (methodology §0: tests/examples are the contemporaneous evidence of understanding).
- **Recommendation:** Give `terminatingEvents` and `disclosables` distinct illustrative SAIDs in the
  example so the three axes read as independent. Re-SAIDify the example after the edit (block `d`s / `v`).

## What's done well

- **Intent-before-code order is genuinely honored** for the whole v2.0 evolution — the field-level
  nodes and the container-restructure nodes both predate the schema commit, verifiably in `git log`.
- **`why` quality is exemplary** across the v2.0 subtree: every node offers a concrete rebuttal surface
  (named rejected alternatives + accepted tradeoffs), including the harder calls (duties-in-`r` vs a
  second credential, versioned-directory vs archive-in-place, closed-enum vs free-string).
- **The fail-closed intent is actually enforced and tested:** `constraints.additionalProperties:false`,
  closed `effects`/`stateKinds` enums, and the `terminatingEvents ⇒ validUntil` `if/then` all fire, and
  the negative corpus exercises each — the intent's fail-closed claim is not aspirational.
- **SAID discipline is airtight:** both `gcd` and `gcd-1.0.0` recompute byte-identical to their embedded
  `$id` against the pinned keripy oracle, `example.s` matches the registry, and 1.0.0 stays resolvable
  exactly as `@r5vk3n` requires.
- **No unrecorded surfaces:** every external contract (CLI commands, the meta-schema, the federation
  layer, the publish/build-docs pipeline) traces to a node.

## Residual unknowns

- Whether the maintainer intends `stage-status: done` to be *written* or to be the tree's implicit
  default (some repos omit the field once complete). F1's fix should follow whichever convention
  `bakobo/dev` prescribes; the finding stands either way, because the current `planned`/`in-progress`
  values are affirmatively wrong, not merely absent.
- The cross-repo `~44oc` obligation (propagating the `c_*` → container rename and `delegated-only` →
  `authorize` into imbu/org/pap) is out of this repo's scope and not audited here; within `bakobo/schema`
  the rename is complete and consistent.
- `docs/style.md`'s abbreviation glossary (line 41 `val`, etc.) lists abbreviations no shipped field yet
  uses; not a defect, but a `check_naming` lint (promised in `@p6mwk4`/`@n7xk4r`) does not yet exist to
  keep the glossary and field names in sync — a future tooling gap, not a current divergence.

## Findings manifest

```yaml
findings:
  - id: CON-F1
    persona: intent-conformance
    title: All shipped GCD v2.0 intent nodes still read planned/in-progress; tree misrepresents completed work
    severity: HIGH
    confidence: CONFIRMED
    location: this.i@b6xh4m
    dedupe_key: this-i-stale-stage-status
    recommended_disposition: recommend-fix
    rationale: Eight v2.0 nodes carry stage-status planned/in-progress while README/KT declare Task 2 DONE and the schema is shipped, minted, tested; an auditor reading the tree is told the flagship work is unbuilt.
    revisit_condition: null
    fix_effort: small
  - id: CON-F2
    persona: intent-conformance
    title: House-style node @p6mwk4 records juris but code + derived doc shipped jurisdictions; doc reversed node silently
    severity: MEDIUM
    confidence: CONFIRMED
    location: this.i@p6mwk4
    dedupe_key: house-style-divergent-juris
    recommended_disposition: recommend-fix
    rationale: The source-of-truth node names juris three times as the chosen abbreviation, but the schema field and docs/style.md rule 4 shipped jurisdictions and explicitly reject juris; the derived doc re-resolved without updating the node it derives from.
    revisit_condition: null
    fix_effort: small
  - id: CON-F3
    persona: intent-conformance
    title: README and KNOWLEDGE_TRANSFER point at docs/methodology.md, which was deliberately deleted
    severity: MEDIUM
    confidence: CONFIRMED
    location: README.md:79
    dedupe_key: readme-stale-methodology-ref
    recommended_disposition: recommend-fix
    rationale: docs/methodology.md was removed in 9f9f931 when methodology moved to the sibling dev repo, but three onboarding references (incl. the AI bootstrap prompt's First moves) still dangle to it; AGENTS.md already points at ../dev/methodology.md.
    revisit_condition: null
    fix_effort: small
  - id: CON-F4
    persona: intent-conformance
    title: Canonical example reuses edge issuer SAIDs for terminatingEvents/disclosables, blurring three distinct axes
    severity: LOW
    confidence: LIKELY
    location: gcd/example.json:57
    dedupe_key: gcd-example-coupled-said-reuse
    recommended_disposition: recommend-defer
    rationale: The worked example points the voiding and outbound-disclosure axes at the same SAIDs as the e.issuer edge; valid instance but undercuts @v3rk5p's deliberate separation of polarities in the reference example.
    revisit_condition: When the example is next re-SAIDified for any reason, give the two axes distinct illustrative SAIDs.
    fix_effort: small
```
