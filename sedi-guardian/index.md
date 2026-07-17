## SEDI Digital Guardian (`sedi-guardian`)

### Purpose

`sedi-guardian` attests that a **guardian holds recognized legal authority to act on behalf of a ward**
under Utah's State-Endorsed Digital Identity law (Utah Code §63A-20-201(3); acceptance mandated by
Parts 4–6). It is the credential a wallet, verifier, or relying party evaluates to decide whether to let
someone present or act with another person's SEDI — a parent for a child, a court-appointed guardian for
an incapacitated adult, a health-care agent under an advance directive.

Guardianship is one of the four *delegated-authority relationship types* (with delegation, controllership,
stewardship): a guardian acts **generally, in the dependent's best interest, for someone who cannot be
fully sovereign** — categorically different from a delegate acting for a still-sovereign principal. The
model here follows the established prior art — the Sovrin *Guardianship in SSI V2* whitepaper and
Aries **RFC 0103 "Indirect Identity Control"** — and Utah's Title 75 Chapter 5 guardianship statutes.

### The load-bearing invariant: holder ≠ subject

The single most important rule, from both the prior art and the law, is that **the guardian holds the
credential and the ward is named only by edge**. The issuee (`a.i`) is the *guardian*; the ward is the
`subject` edge to the ward's [`sedi-id`](../sedi-id). This is what keeps guardianship *transparent*
representation, never impersonation — a verifier can always tell that *a guardian* is acting for a ward,
not that the ward is acting. Collapsing the two (guardian-as-subject) is the classic
impersonation/commingling failure the whole field warns against.

### The four statutory bases

Utah recognizes four bases, and they have genuinely different shapes — which is why `basis` is a
first-class, machine-checkable field rather than governance-framework prose:

| `basis` | Authority arises from | Evidence | Notes |
|---|---|---|---|
| `courtGuardianIncapacitated` (§75-5-301) | probate court, after an incapacity finding | Letters + order/case number | Utah prefers **limited**; enumerate powers |
| `courtGuardianMinor` (§75-5-202) | probate court (or accepted testamentary appointment) | Letters + order/case number | parent keeps `residualParentalRights`; expires at 18 |
| `custodialParent` | **inherent parental right — no court** | birth certificate | `authorityType: inherentParental`; expires at 18/emancipation |
| `designatedRepresentative` | the **individual** (self-executed) | POA or advance directive | `subtype`: `financialPOA` / `healthCareAgent`; a health-care agent is `capacityConditioned` |

**Scope must be explicit.** Utah's strong limited-guardianship preference means most guardianships are
*limited*, so `powers` (`plenary` or an explicit set — `healthCare`, `residence`, `education`, …) is
required, and a verifier MUST check the *specific* action against it (a medical-only guardian is not
authority for a financial act).

**Note on scope:** SEDI's guardian is of the **person** (care, residence, medical), not a *conservator*
of property — a separate Utah appointment not among the four bases. And a **supported-decision-making
supporter** (2025 Part 7) is deliberately *excluded*: a supporter cannot decide *for* the principal, so
they are not "authorized to act on behalf of" and are not a digital guardian (see `this.i` `@sdlg3n`).

### The legal-recognition layer, and composition with GCD

`sedi-guardian` carries only what Utah law makes **relationship- and jurisdiction-specific**: the
`basis`, the `powers` scope, and a clustered **`recognition`** block (appointing court/case/order or
self-executed instrument, `appointingState`, and cross-state `registrationStatus` — `native` /
`registeredForeign` / `transferred` under UAGPPJA, Title 75 Ch. 5b). It is **registry-bound** (`ri`):
guardianship terminates dynamically (majority, restored capacity, death, court order), so a verifier MUST
check current status, not just the signature and dates.

The **generic** delegated-authority machinery — the act grid, fine-grained constraints, duties, and
terminating events — is **not re-implemented here**. It lives in [GCD](../gcd)
(`relationType: guardianship`), reachable through the optional `scope` edge. So a simple guardianship
stands on `sedi-guardian` alone (with a `powers` list); one needing rich, gated act-constraints edges to
a GCD. This is the deliberate two-layer factoring: **GCD for the generic relationship, `sedi-guardian`
for the legal specifics.**

This is the **first of a likely `sedi-legal-authority` family** — conservatorship and POA-agency share
most of the `recognition` layer. Per this repo's extract-at-the-second-pattern discipline, a shared base
is extracted when that second instance is actually researched, not guessed now; and person-fiduciary
authority (guardian/conservator) stays distinct from thing-controllership (a drone has no interest to
protect), which remains GCD's territory. See `this.i` `@sdlg3n`.

### Schema and examples

See [`sedi-guardian.schema.json`](sedi-guardian.schema.json) — a v1 attribute+edges+rules ACDC. Like
GCD, an authority credential is disclosed **whole** (a verifier needs basis + scope + validity together),
so the attribute section is flat, not selectively disclosable. Edges: `subject` (→ ward's `sedi-id`;
`I2I` when a principal self-designates, else `NI2I`), `authorization` (→ the court order / Letters /
instrument, often FAA-wrapped), and the optional `scope` (→ a GCD).

The gallery covers all four bases:

| Example | basis | highlights |
|---|---|---|
| [`example.json`](example.json) | `courtGuardianIncapacitated` | limited `healthCare`+`residence`, court `recognition`, `reviewDueDate`, GCD `scope` edge |
| [`court-guardian-minor`](examples/court-guardian-minor.json) | `courtGuardianMinor` | `plenary`, `residualParentalRights`, `expiryDate` at majority |
| [`custodial-parent`](examples/custodial-parent.json) | `custodialParent` | `inherentParental` (no court/case), birth-certificate authorization |
| [`designated-representative-healthcare`](examples/designated-representative-healthcare.json) | `designatedRepresentative` | `healthCareAgent`, `selfExecuted`, `capacityConditioned`, `substitutedJudgment`, `subject` edge is `I2I` |

The [`invalid/`](invalid) corpus rejects a missing/mistyped `basis`, empty or bad `powers`, a
`recognition` missing a required field or with a bad `authorityType`, a bad edge operator, a malformed
date, and the structural omissions.

### Governance

The fiduciary and safeguard rules live in the **SEDI guardianship governance framework**
([`rules.json`](rules.json)), referenced from `r`: best-interest fiduciary duty, the holder≠subject
transparency rule, scope-enforcement, dynamic-revocation-checking, second-guardian authorization for
high-risk acts, auditability, appeal/oversight, requalification cadence, least-restrictive / evolving-
capacity (the ward's right to reclaim sovereignty), no bulk-load without consent, issuer-authority per
basis, and the supported-decision-making exclusion.

### Provenance

Design decisions and the generalization hypothesis are in [`this.i`](../this.i) (`@sdlg3n`). Sources:
Utah Code Title 75 Ch. 5 (guardianship) and Ch. 5b (UAGPPJA); the Sovrin *Guardianship in SSI V2*
whitepaper; Aries RFC 0103/0104; and the delegated-authority model in `papers/sda.md`.
