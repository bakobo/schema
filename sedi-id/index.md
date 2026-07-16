## SEDI Identity Credential (`sedi-id`)

### Purpose

`sedi-id` is the **root credential of Utah's State-Endorsed Digital Identity** (SEDI, Utah Code
Title 63A, Chapter 20, enacted by SB 275, effective 2026-05-06). It is what the State — through the
Department of Government Operations (DGO) — issues to a resident after identity proofing: a
cryptographically verifiable assertion of the resident's core civil identity, bound to an identifier
the **holder** created and controls.

SEDI's founding premise is inversion of the usual state-ID relationship: identity is *"innate to the
individual's existence and independent of the state… fundamental and inalienable"* (§63A-20-101(1)).
**The state endorses an identity; it does not create one.** So `sedi-id`'s issuer field names the
State, but the subject is bound by the holder's own [personal digital identifier](#the-holder-binding)
(a KERI AID) — withdraw the endorsement and the identity persists, because the holder, not the state,
holds the key.

This credential is **not** a driver's license and not a general attribute bag. The statute lets the
department verify and endorse **exactly four attributes — name, birth date, image, and Utah residence
address** (§63A-20-301(2)(f)) — and forbids collecting anything unnecessary (§302(7)). `sedi-id`
carries those four and nothing more; everything richer (age thresholds, eligibility, presentations,
guardianship) is a *separate* credential that chains to this one. See [the family](#the-sedi-family).

### Why an Aggregate (`A`) credential

The statute *mandates* selective disclosure and "prove a minimum age without disclosing age or birth
date" (§301(1)(e)), bans state tracking of presentations (§301(3)), and requires offline presentation
(§301(1)(d)). Those requirements are why `sedi-id` uses the ACDC 2.0 **Aggregate section** rather than
an ordinary attribute section.

The `A` section is an ordered list of **individually-blinded blocks**. Each block has its own SAID
(`d`) and a high-entropy blinding nonce (`u`), plus its attribute field(s). Element 0 of the list is
the **AGID** (Aggregate ID), a digest committing to every block's SAID. To present, the holder reveals
a chosen subset of blocks *in full* and leaves the rest as **bare SAIDs**; the verifier recomputes the
AGID and confirms it matches the State's committed value. Because each withheld block is blinded by its
own nonce, a bare SAID leaks nothing about a low-entropy value like a birthdate — no rainbow-table
attack. This is structurally cognate to the ISO 18013-5 mDL's MSO/per-element digest mechanism, which
makes the [foreign-credential bridge](#the-sedi-family) clean.

The governing constraint on schema design is the **atomicity rule**: all fields in one block disclose
together (ACDC spec, *Aggregate Section*). So **block granularity = disclosure granularity** — the
single most important lever in this schema.

### The blocks

Element 0 is the AGID; the remaining blocks (each independently disclosable) are:

| Block | Field(s) | Statutory basis |
|---|---|---|
| Issuee | `i` (holder AID) | — (binds the credential to the holder) |
| Given-name | `nameGiven` | name — §301(2)(f) |
| Family-name | `nameFamily` | name — §301(2)(f) |
| Date-of-birth | `dob` (`date`) | birth date — §301(2)(f) |
| Image | `image` = `{digest, format, dim, captured}` | image — §301(2)(f) |
| Face-template | `faceTemplate` = `{digest, protocol}` | *optional*, for consented dedup (not endorsed identity) |
| Residence-street | `residenceStreet` (whole line) | Utah residence address — §301(2)(f) |
| Residence-city | `residenceCity` | " |
| Residence-state | `residenceState` | " |
| Residence-postal | `residencePostal` | " |
| Residence-county | `residenceCounty` | " |

#### The holder binding

An aggregate ACDC has no top-level attribute-section issuee, so the holder AID is carried in its **own
Issuee block** (`{d, u, i}`). This is what a `sedi-id → X` chain checks: an edge with the I2I
("issuer-to-issuee") operator holds only when the issuer of the chaining credential equals this
credential's issuee. Because the Issuee block is disclosable on its own, the holder can prove the
binding alongside any single attribute without revealing the others.

#### Name and residence are decomposed — deliberately

Both `name` and the residence address are split into **sibling blocks**, not carried as one lump or as
one nested object. This is a considered production decision, not a convenience:

- **Minimization is a statutory duty, not a nicety.** §501 binds verifiers to "the minimum attributes
  for a relying-party-defined purpose"; §701 is a duty of loyalty. If the smallest residence unit were
  the whole address, that mandate would be *un-satisfiable at the schema level* for the most common
  residence predicate — **"prove Utah resident"** (voter eligibility, in-state tuition,
  tax/jurisdiction, alcohol regulation). Decomposition lets the holder disclose `residenceState` (or
  `residenceCity`/`residencePostal`) while the **street line stays a bare SAID**.
- **The safety case is strongest for the people Utah law already protects** — the Title 20A
  withheld/at-risk-voter classes (domestic-violence victims, law-enforcement officers, protected
  persons). Street address is the component whose disclosure gets people hurt.
- **Not decomposing would make SEDI a privacy regression from the mDL it replaces** (ISO 18013-5
  already splits `resident_address`/`resident_city`/`resident_state`/`resident_postal_code`).

Decomposed strictly dominates: a holder can always disclose every component to reconstruct the coarse
view, so a single-block form buys nothing. Two grain choices are deliberate: **the street line is kept
whole** (`residenceStreet`) rather than parsed into number/street/unit — address parsing is brittle
across PO boxes, rural routes, and non-US formats, and the useful predicates live in the clean
jurisdiction fields; and we do **not** go finer than postal components (no `streetNumber` vs
`streetName`).

**Naming: semantic interop, not field-name interop.** The labels use Utah's statutory term
*"residence"* (`residenceCity`, `residenceState`, …), not ISO mDL's *"resident."* We align the
component *semantics* with 18013-5 so the bridge crosswalk is mechanical, but keep the statute's
vocabulary — what must map cleanly is meaning, not spelling. Labels are flat and **dot-free** on
purpose: a dotted key like `residence.street` would signal a nesting the data model deliberately
doesn't have (these are independent sibling blocks) and is a cross-tooling footgun (jq/JSONPath read a
dot as a path separator; `obj.residence.street` traverses in JS; MongoDB reinterprets dots in keys).

#### Image: committed by digest, bytes carried by the holder

The `image` block does **not** inline the portrait bytes and does **not** point at a download URL. It
carries a **content digest plus minimal metadata** (`format`, `dim`, `captured`); the actual bytes are
a holder-carried object addressed by that digest, attached to a presentation under chain-link
confidentiality and verified against the digest. The State still "endorses the image" — it signs a
credential committing to the digest of the specific bytes it captured, so disclosing bytes + proving
digest-match ≡ proving state endorsement of *this* photo.

A **download locator was rejected** because it fails three statutory tests at once: it breaks mandatory
offline presentation (§301(1)(d)); it is phone-home by another name — whoever hosts or observes the
fetch learns presentation events (§301(3), §701); and it makes an availability/denial chokepoint
incompatible with a self-sovereign credential. **Inlining raw bytes** was rejected as bloat (a
registry-anchored credential re-hashing tens of KB on every block-SAID computation).

There is **one canonical portrait** (ISO/IEC 19794-5-grade, matching DMV/mDL practice) — no resolution
ladder, which would only multiply correlation surfaces. The optional **`faceTemplate`** block is a
*different artifact*, not a resolution: a cancelable/biohashed, ISO/IEC 24745-style template
(irreversible, revocable, distance-preserving) for consented 1:N dedup, since a plain photo hash is
useless for matching. It carries a named `biometricProtocol` so templates are comparable across
credentials — which makes it a cross-credential linkage key, so it is disclosed **only** when
uniqueness is the explicit purpose and under a correlation-consent rule. `image` = human/visual match;
`faceTemplate` = consented machine dedup.

### Schema

See [`sedi-id.schema.json`](sedi-id.schema.json). `A` is `oneOf(AGID string, uncompacted array)`; the
array is `items`+`anyOf` over the block types, and each block is `oneOf(block SAID string, block
detail)`. That is what lets any subset be disclosed as detail while the rest stay bare SAIDs, without
fixing count or order.

### Worked examples

- [`example.json`](example.json) — the fully-disclosed issued aggregate (all eleven blocks in detail),
  a **private** variant (top-level `u`) issued by the State to the holder Alice.
- [`examples/prove-utah-residence.json`](examples/prove-utah-residence.json) — the headline selective
  disclosure: the holder reveals the Issuee binding + `residenceCity`/`residenceState`/`residencePostal`
  and leaves the **street line, name, date of birth, image, county, and face-template as bare SAIDs**.
  The disclosure still verifies against the committed AGID, and the street value never appears on the
  wire. This is "prove where I live, at jurisdiction grain, without my street address."

The [`invalid/`](invalid) corpus holds should-reject fixtures: a top-level extra property, a missing
`A`, a mistyped `A`, a block with an extra property, a block missing its blinding nonce, a non-date
`dob`, an `image` missing its `digest`, and a non-string `residenceState`.

The **AGID and per-block SAIDs in the examples are authentic** — computed with the v2 keri `Aggor`
(the same primitive exercised by keripy's `tests/acdc/test_clc_disclosure.py`, which runs the full
selective-disclosure + chain-link-confidentiality exchange for this exact credential shape).

### A note on version stamping and SAIDs (v1 oracle limitation)

This repo's SAID oracle is pinned to **keri 1.2.13**, which predates the ACDC v2 Aggregate section.
Two consequences are recorded here and in [`this.i`](../this.i):

1. A production `sedi-id` carries a v2 **version string** in `v`; the v1 oracle cannot stamp or verify
   one, so `v` is *optional* in this schema and the illustrative examples omit it.
2. A v2 credential's top-level SAID is computed over the **compact** form (`A` = AGID) and is therefore
   **disclosure-invariant**. The v1 oracle computes `d` over literal content, so each example here is a
   SAID fixed point over its own expanded form and the two examples do **not** share one `d`. Under a
   v2 stack they would. AGID authenticity is verified by the keripy test, not by this repo's linter
   (which checks top-level SAID consistency, schema validity, and the negative corpus).

### The SEDI family

`sedi-id` is the root of a credential family; the other members chain to it and are on the roadmap
(tracked in `this.i` / `tick`):

- **`sedi-age`** — derived boolean age attestations (over-18, over-21) satisfying prove-age-without-
  birthdate for the alcohol/tobacco use case (§204(2)(a)); mirrors the mDL `age_over_NN` element.
- **`sedi-bespoke`** — a holder-issued, unregistered, one-time **presentation** credential with I2I
  edges to source credentials and a Rules section carrying the chain-link-confidentiality terms
  (Purpose / anti-assimilation / statutory safe-harbor citing §701/§801), presented through a gated
  IPEX exchange so the verifier accepts the terms before any PII crosses the wire.
- **`sedi-guardian`** — a GCD-style delegation for the statutory **digital guardian** (§201(3)),
  letting a parent/legal-guardian/designated representative hold and present on a ward's behalf.
- **`sedi-bridge`** — a reissuer / foreign-artifact wrapper that re-anchors an ephemeral foreign
  credential (EUDI wallet, another state's mDL, a DHS W3C VC) into a durable, holder-controlled,
  KERI-anchored ACDC for Olympic-scale interop.

### Governance

SEDI's duty-of-loyalty and processing-minimization obligations (§701, §702, Parts 4–6) are carried as
the **SEDI governance framework** in [`rules.json`](rules.json) — the family-wide framework (this root
credential's folder is its home), referenced by SAID from every SEDI credential's `r` field
(`sedi-id`, `sedi-age`, and the presentation patterns). Its clauses ground chain-link confidentiality,
data minimization, duty of loyalty, anti-surveillance, guardian acceptance, no device surrender,
consent/notice, revocation respect, and the §63A-20-701 safe harbor in the statute. Issuing or accepting
a SEDI credential is binding acceptance of the framework referenced in `r`.

### Provenance and further reading

The design decisions above are recorded in the intent tree ([`this.i`](../this.i), node `@sd4rkp` and
children). The full research synthesis behind this family — Utah's ISO mDL data elements, the
DLD/voter-registration record schemas, the SEDI statute, the "Utah population database," and the
attribute crosswalk — lives in the Bakobo `sedi` knowledge repo at
`sedi/artifacts/sedi-schema-synthesis.md`. The executable reference for the aggregate + chain-link
confidentiality mechanics is keripy's `tests/acdc/test_clc_disclosure.py`.
