## SEDI Age Attestation (`sedi-age`)

### Purpose

`sedi-age` is a **derived, state-endorsed age attestation** in Utah's State-Endorsed Digital Identity
family (Utah Code Title 63A, Chapter 20). It satisfies one specific statutory requirement directly: a
holder must be able to **"prove a minimum age without disclosing age or birth date"**
(§63A-20-301(1)(e)). Rather than reveal the `dob` block of the [`sedi-id`](../sedi-id) root, the holder
presents this credential and discloses just the age threshold(s) a verifier needs.

The headline use case is alcohol/tobacco age verification (§63A-20-204(2)(a)): the vendor learns only
"21 and over: true" — not the birth date, not the exact age, not the name or address.

### Why an aggregate (`A`) section — a boolean threshold vector

`sedi-age` carries a selectively disclosable **aggregate (`A`) section**: an array of individually-
blinded blocks — the issuee, an as-of date, and one **boolean flag per age threshold**
(`ageOver13`, `ageOver16`, `ageOver18`, `ageOver21`, `ageOver55`, `ageOver65`). Element 0 is the
**AGID**, a digest committing to every block's SAID. The holder reveals only the block(s) needed (e.g.
`ageOver21` for a bar) and leaves the rest as bare, per-block-blinded SAIDs; the verifier recomputes the
AGID to confirm authenticity.

This is the *right* use of an aggregate — and the mirror image of [`sedi-id`](../sedi-id), which is
attributive (see PR [WebOfTrust/keripy#1505](https://github.com/WebOfTrust/keripy/pull/1505) and
[`this.i` `@sdav5t`](../this.i)). The age thresholds are a **homogeneous boolean vector**: they are
really an indexed numeric series, not a set of meaningfully-distinct labeled fields. Treating them as an
unordered, blinded set is exactly the ISO mDL **`age_over_NN`** model, and it leaves room for the
planned upgrade to a sparse Merkle tree with no schema change — "a poor man's sparse Merkle tree." Here
the aggregate's blinding of block labels/positions is a genuine (if modest) fit, whereas for the labeled
identity fields it would only cost pathing clarity.

One schema serves every threshold; the set here (13, 16, 18, 21, 55, 65) covers the common minimum-age
and senior thresholds and is easy to extend. `asOf` records the **point-in-time** posture of the
attestation (§63A-20-303: verification at a point in time, no continuous monitoring) — the analogue of
the mDL rule that `age_over_NN` is computed at the MSO's `validFrom`.

### Why there is no edge to `sedi-id`

An `I2I` edge from `sedi-age` to `sedi-id` would hold only if the issuer of `sedi-age` equalled the
issuee of `sedi-id` — i.e. only if the *holder* self-issued the age attestation, which would carry no
state endorsement. So `sedi-age` carries **no** edge to the root. The same-holder binding is established
at **presentation** time by a holder-issued presentation whose `I2I` edges point at *both* source
credentials (the holder is the issuer there, and the issuee of both) — see
[`sedi-present-age-portrait`](../sedi-present-age-portrait).

This pre-derived boolean is a genuine zero-knowledge alternative to a predicate proof: it keeps the
birth date out of the transaction entirely, with no special cryptography. A ZK-predicate variant is a
possible future profile the statute permits.

### Schema and examples

See [`sedi-age.schema.json`](sedi-age.schema.json). `A` is `oneOf(AGID string, uncompacted array)`; the
array is `items`+`anyOf` over the block types (issuee, as-of, and one per threshold), each `oneOf(block
SAID, block detail)`.

- [`example.json`](example.json) — the fully-disclosed issued credential (all six thresholds), issued by
  the State to the holder Alice as of a fixed date. Alice (born 2000) is over 13/16/18/21 and not over
  55/65.
- [`examples/prove-over-21.json`](examples/prove-over-21.json) — the headline selective disclosure: the
  holder reveals **only** issuee + `asOf` + `ageOver21`, leaving every other threshold (including the
  `false` ones) as a bare, blinded SAID. The verifier learns "over 21: true" and nothing about the
  holder's exact age band. The disclosure verifies against the committed AGID.

The [`invalid/`](invalid) corpus rejects: a top-level extra property, a missing `A`, a mistyped `A`, a
block with an extra property, a block missing its blinding nonce, a non-boolean `ageOver21`, and a
malformed `asOf`.

The AGID and per-block SAIDs are **authentic**, computed with the v2 keri `Aggor` (the same primitive in
keripy's `tests/acdc/test_clc_disclosure.py`). Because it is a v2 aggregate credential, the repo's pinned
keri 1.2.13 oracle cannot version-stamp it, so the examples are unversioned and the linter checks
top-level SAID consistency and schema validity rather than recomputing the AGID (see
[`this.i` `@sd2qfw`](../this.i)). The attributive [`sedi-id`](../sedi-id) does not have this limitation.

### Governance

As with the rest of the family, the duty-of-loyalty / minimization obligations travel as the shared
**SEDI governance framework** ([`sedi-id/rules.json`](../sedi-id/rules.json)), referenced by SAID from
`r`. Issuing or accepting this credential is binding acceptance of that framework.
