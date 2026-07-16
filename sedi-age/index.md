## SEDI Age Attestation (`sedi-age`)

### Purpose

`sedi-age` is a **derived, state-endorsed age-threshold attestation** in Utah's State-Endorsed Digital
Identity family (Utah Code Title 63A, Chapter 20). It exists to satisfy one specific statutory
requirement directly: a holder must be able to **"prove a minimum age without disclosing age or birth
date"** (§63A-20-301(1)(e)). Rather than reveal the `dob` block of the [`sedi-id`](../sedi-id) root,
the holder presents this small credential, which asserts a single boolean over a named threshold.

The headline use case is alcohol/tobacco age verification (§63A-20-204(2)(a)): the vendor learns only
"21 and over: true" — not the birth date, not the exact age, not the name or address.

### Model

One schema serves every threshold via the `ageThreshold` field (18, 21, …), mirroring the ISO 18013-5
mDL `age_over_NN` element rather than minting a separate credential type per age. The attribute block
carries:

| Field | Meaning |
|---|---|
| `i` | Issuee — the holder's AID |
| `ageThreshold` | the threshold in years being attested (e.g. 21) |
| `ageOver` | true iff, as of `asOf`, the holder is at or above the threshold |
| `asOf` | the date the comparison was evaluated |

`asOf` reflects the statute's **point-in-time** posture (§63A-20-303: endorsement reflects verification
at a point in time and does not require continuous monitoring). It is the analogue of the mDL rule that
`age_over_NN` is computed at the MSO's `validFrom`.

This is a plain attribute (`acm`) ACDC, **not** an aggregate credential like `sedi-id`. It is
issued by the State to the holder and is registry-bound (`ri`) so it can be revoked.

### Why there is no edge to `sedi-id`

An `I2I` ("issuer-to-issuee") edge from `sedi-age` to `sedi-id` would hold only if the issuer of
`sedi-age` equalled the issuee of `sedi-id` — i.e. only if the *holder* self-issued the age
attestation, which would carry no state endorsement. So `sedi-age` carries **no** edge to the root.
The same-holder binding — proving that this age attestation and the identity root belong to one person
— is established at **presentation** time by a holder-issued bespoke presentation credential whose
`I2I` edges point at *both* source credentials (the holder is the issuer there, and the issuee of
both). See the `sedi-bespoke` roadmap entry in [`sedi-id/index.md`](../sedi-id/index.md).

This is not a limitation but a genuine zero-knowledge alternative to a predicate proof: a pre-derived
boolean (the plan-of-record default) keeps the birth date out of the transaction entirely, with no
special cryptography.

### Schema and example

See [`sedi-age.schema.json`](sedi-age.schema.json). The [`example.json`](example.json) is an
"over-21: true" attestation issued by the State to the holder Alice, as of a fixed date. The
[`invalid/`](invalid) corpus rejects: a top-level extra property, a missing attribute block, a
non-boolean `ageOver`, a non-integer or below-minimum `ageThreshold`, a malformed `asOf`, an attribute
block missing its issuee, and an attribute block with an extra property.

### Governance

As with the rest of the family, the duty-of-loyalty / minimization obligations travel as the shared
**SEDI governance framework** ([`sedi-id/rules.json`](../sedi-id/rules.json)), referenced by SAID from
`r`. Issuing or accepting this credential is binding acceptance of that framework.
