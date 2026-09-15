## SEDI Identity Credential (`sedi-id`)

### Purpose

`sedi-id` is the **root credential of Utah's State-Endorsed Digital Identity** (SEDI, Utah Code
Title 63A, Chapter 20, enacted by SB 275, effective 2026-05-06). It is what the State — through the
Department of Government Operations (DGO) — issues to a resident after identity proofing: a
cryptographically verifiable assertion of the resident's core civil identity, bound to an identifier
the **holder** created and controls.

SEDI's founding premise inverts the usual state-ID relationship: identity is *"innate to the
individual's existence and independent of the state… fundamental and inalienable"* (§63A-20-101(1)).
**The state endorses an identity; it does not create one.** So `sedi-id`'s issuer field names the
State, but the subject is bound by the holder's own personal digital identifier (a KERI AID) — withdraw
the endorsement and the identity persists, because the holder, not the state, holds the key.

This credential is **not** a driver's license and not a general attribute bag. The statute lets the
department verify and endorse **exactly four attributes — name, birth date, image, and Utah residence
address** (§63A-20-301(2)(f)) — and forbids collecting anything unnecessary (§302(7)). `sedi-id`
carries those four and nothing more; everything richer (age thresholds, eligibility, presentations,
guardianship) is a *separate* credential that chains to this one. See [the family](#the-sedi-family).

### Why an attribute (`a`) section — not an aggregate

`sedi-id` carries its attributes in a partially-disclosable **attribute (`a`) section**, where each
attribute is its own nested, individually-blinded block (own SAID `d` and blinding nonce `u`). A holder
discloses any subset by revealing those blocks and leaving the rest as bare block SAIDs; withheld
values never cross the wire.

An earlier draft used the aggregate (`A`) section (mDL-style). It was reversed on first-principles
grounds (see PR [WebOfTrust/keripy#1505](https://github.com/WebOfTrust/keripy/pull/1505) and
[`this.i` `@sdav5t`](../this.i)): **the only thing an aggregate buys over an attribute section is that
its top-level blocks carry no meaningful labels**, so block *position* can be arranged to not leak
information. That helps only when a field's presence/identity/position is itself sensitive, or the
field set is variable. The core identity credential is a **fixed set of heterogeneous, meaningfully-
labeled fields** — nothing benefits from hiding labels — and it is the **most-used** credential, so the
aggregate's real cost bites: you can no longer path to a field by label, so graduated-disclosure
negotiation (apply/offer path lists) would need a label→index reverse-lookup, or you put the index in
the path and defeat the very unlinkability the array was for. Labels are the right handle here; the
aggregate is [the right choice for the age credential](../sedi-age) instead.

### The attributes

The `a` section holds the issuee (`a.i` = the holder's AID) plus one nested block per attribute:

| Block | Field(s) | Statutory basis |
|---|---|---|
| Given-name | `nameGiven` | name — §301(2)(f) |
| Family-name | `nameFamily` | name — §301(2)(f) |
| Date-of-birth | `dob` (`date`) | birth date — §301(2)(f) |
| Image | `image` = `{digest, format, dim, captured}` | image — §301(2)(f) |
| Face-template | `faceTemplate` = `{digest, protocol}` | *optional*, consented dedup (not endorsed identity) |
| Residence-street | `residenceStreet` (whole line) | Utah residence address — §301(2)(f) |
| Residence-city | `residenceCity` | " |
| Residence-state | `residenceState` | " |
| Residence-postal | `residencePostal` | " |
| Residence-county | `residenceCounty` (optional) | " |

The holder AID lives at **`a.i`**, the natural issuee location for an attributive ACDC — this is what a
`sedi-id → X` chain checks (an `I2I` edge holds only when the chaining credential's issuer equals this
credential's `a.i`). Note that attribute-form partial disclosure reveals `a.i` and the `a`-section
metadata on *any* disclosure; for SEDI that is fine, because the holder binding is normally wanted.

#### Name and residence are decomposed — deliberately

Both `name` and the residence address are split into **separate nested blocks**, not carried as one
lump or a single object — and decomposed is the *sole* production shape. Because a block discloses
atomically, a single residence block would force over-disclosure on every verifier who only needs
jurisdiction, making the statute's minimization duty (§501, §701) un-satisfiable at the schema level.
**"Prove Utah resident"** (voter eligibility, in-state tuition, tax/jurisdiction, alcohol) is the most
common residence predicate, and withholding the **street line** protects exactly the Title-20A
withheld/at-risk-voter classes (DV victims, LEOs, protected persons). Not decomposing would also make
SEDI a privacy regression from the ISO 18013-5 mDL it replaces.

Grain: keep the **street line whole** (`residenceStreet`) rather than parse it (PO boxes, rural routes,
non-US formats are brittle; the useful predicates live in the clean jurisdiction fields); split only
city/state/postal/county; go no finer. Naming is **semantic interop, not field-name interop**: the
labels use Utah's statutory term *"residence"* (`residenceCity`, …), not ISO mDL's *"resident"* — align
the component *semantics* with 18013-5 so a bridge crosswalk is mechanical, but keep the statute's
vocabulary. Labels are flat and **dot-free** on purpose (a dotted key like `residence.street` signals a
nesting the model doesn't have and is a cross-tooling footgun in jq/JSONPath/JS/MongoDB).

#### Image: committed by digest, bytes holder-carried

The `image` block carries a **content digest plus minimal metadata** (`format`, `dim`, `captured`); the
actual portrait bytes are **holder-carried** and attached to a presentation under chain-link
confidentiality, verified against the digest. A **download locator was rejected** (it breaks mandatory
offline presentation §301(1)(d), is phone-home by another name §301(3)/§701, and creates an
availability chokepoint), and **inlining raw bytes** was rejected as bloat. There is **one canonical
portrait** (ISO/IEC 19794-5-grade) — no resolution ladder. The optional **`faceTemplate`** block is a
*different artifact*: a cancelable/biohashed (ISO/IEC 24745-style) template for consented 1:N dedup,
carrying a named `biometricProtocol` and disclosed only under a correlation-consent rule.

### Selective (partial) disclosure — "prove Utah residence without the street"

To prove residence at jurisdiction grain, the holder reveals the residence-city/state/postal blocks and
leaves the street, name, DOB, image, etc. as bare SAIDs. Illustratively, the disclosed `a` section
looks like:

```jsonc
"a": {
  "d": "…", "u": "…", "i": "<Alice's AID>",
  "nameGiven":       "<block SAID>",           // withheld
  "nameFamily":      "<block SAID>",            // withheld
  "dob":             "<block SAID>",            // withheld
  "image":           "<block SAID>",            // withheld
  "residenceStreet": "<block SAID>",            // withheld — the street never appears
  "residenceCity":   { "d": "…", "u": "…", "residenceCity": "Salt Lake City" },
  "residenceState":  { "d": "…", "u": "…", "residenceState": "UT" },
  "residencePostal": { "d": "…", "u": "…", "residencePostal": "84101" },
  "residenceCounty": "<block SAID>"             // withheld
}
```

The verifier hashes each disclosed block, substitutes the withheld SAIDs, and recomputes `a.d` to
confirm the disclosure is authentic. (This is shown as prose rather than a SAID-checked gallery file
because the repo's oracle does not compact nested blocks — see the [SAID note](#a-note-on-saids).)

### Schema

See [`sedi-id.schema.json`](sedi-id.schema.json). The `a` section is `oneOf(section SAID, section
detail)`; the detail requires the endorsed attributes, each a nested block that is itself `oneOf(block
SAID, block detail)` — so any subset can be disclosed as detail while the rest stay bare SAIDs.

### Worked example

[`example.json`](example.json) is the fully-disclosed issued credential (all attributes present) — a
**private** variant (top-level `u`), a **version-stamped ACDC v2 `acm`** issued by the State to the holder
Alice. The [`invalid/`](invalid) corpus rejects: a top-level extra property, a missing/`a`-section-less
credential, a missing issuee, a missing required attribute, a block with an extra property, a block
missing its blinding nonce, a non-date `dob`, an `image` missing its `digest`, and a non-string
`residenceState`.

### A note on SAIDs

`sedi-id` is an **attributive ACDC v2 `acm`** — the field-map ilk, so `u` and `e` are genuinely optional
here, unlike the fixed-field `acg` of [`sedi-age`](../sedi-age). It carries a real v2 version string and
a canonical `d`, both computed by this repo's oracle. One residual remains: the oracle does not compact
nested partial-disclosure blocks, so a partial-disclosure form's `a.d`/`d` differ from the full form's.
That is why the residence disclosure above is illustrative prose, and the machine-validated
selective-disclosure gallery lives on `sedi-age`, where the AGID is stable across disclosures. See
[`this.i` `@sdav5t` / `@lkfnoess`](../this.i).

### The SEDI family

`sedi-id` is the root; the other members chain to it: **[`sedi-age`](../sedi-age)** (the aggregate
boolean age-threshold vector), **[`sedi-present-age-portrait`](../sedi-present-age-portrait)** (the
first holder-issued presentation pattern), and — on the roadmap — `sedi-guardian` (digital-guardian
delegation) and `sedi-bridge` (foreign-credential reissuer). See [`this.i` `@sd4rkp`](../this.i).

### Governance

SEDI's duty-of-loyalty and minimization obligations (§701, §702, Parts 4–6) are carried as the
family-wide **SEDI governance framework** in [`rules.json`](rules.json) (this root credential's folder
is its home), referenced by SAID from every SEDI credential's `r`. Issuing or accepting a SEDI
credential is binding acceptance of it.

### Provenance and further reading

Design decisions live in [`this.i`](../this.i) (`@sd4rkp` and children; the attribute-vs-aggregate
reversal is `@sdav5t`). The reusable principle is distilled in
[`docs/choosing-attribute-vs-aggregate.md`](../docs/choosing-attribute-vs-aggregate.md). The full
research synthesis is in the `bakobo/sedi` repo (`sedi/artifacts/sedi-schema-synthesis.md`); the
executable reference for the disclosure + chain-link-confidentiality mechanics is keripy's
`tests/acdc/test_clc_disclosure.py`.
