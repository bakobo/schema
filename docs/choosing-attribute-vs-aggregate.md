# Choosing an ACDC section: attribute (`a`) vs aggregate (`A`)

A distilled, reusable design principle for authoring ACDC schemas in this repo. It generalizes a
decision made for the SEDI credential family; the repo-specific record is in
[`this.i`](../this.i) (`@sdav5t`), and the discussion that produced it is
[WebOfTrust/keripy#1505](https://github.com/WebOfTrust/keripy/pull/1505).

> **Derived doc.** Per the repo methodology, `this.i` is the source of truth for decisions; this page
> distills the reusable *principle* so future authors (human or AI) don't re-derive it.

## The two graduated-disclosure mechanisms

Both let a holder reveal some fields and withhold others, each withheld field blinded by a per-block
nonce so its value can't be brute-forced from its SAID. They differ in **what the top-level blocks look
like**:

- **Attribute section (`a`)** — a **labeled field map**. Each attribute is a nested block under a
  meaningful key (`a.dob`, `a.residenceState`). Partial disclosure: reveal a nested block, others
  collapse to their SAID. Field labels are public (they're in the schema).
- **Aggregate section (`A`)** — an **ordered array of unlabeled blinded blocks**, committed by a
  zeroth-element AGID. Selective disclosure: reveal chosen array elements, the rest travel as bare
  SAIDs. The block labels live *inside* each block, so they're blinded; array position is arbitrary.

## The deciding question

> **Does hiding the field *labels* or *positions* buy you anything?**

The **only** thing the aggregate provides over the attribute section is that its blocks carry no
outward labels, so their number and position can be arranged so as **not to leak information**. That is
valuable in exactly two situations:

1. The **presence or identity of a field is itself sensitive** — e.g. "does this credential even carry
   attribute X?" is something you must not leak.
2. The **field set is variable or homogeneous** — the fields are interchangeable members of a set (an
   indexed series, a bag of flags), so a meaningful label per position would be noise, and position
   could otherwise leak which members are present.

If neither holds, the aggregate is **pure cost**, because you lose **label-based pathing**. Graduated-
disclosure negotiation (apply/offer path lists, e.g. via keri's `Pather`) wants to name a field as
`a/residenceState`. In an aggregate you can't — you'd need a label→index reverse-lookup table, and if
you put the index in the path you defeat the unlinkability the array was for. For the most-used
credentials, that complexity is not worth paying.

## The rule of thumb

| If the fields are… | use | because |
|---|---|---|
| a **fixed set of heterogeneous, meaningfully-labeled** attributes | **attribute `a`** | labels are the natural handle; hiding them helps nothing and costs pathing |
| a **homogeneous vector you disclose a subset of** (flags, an indexed series) | **aggregate `A`** | treat as an unordered blinded set; matches mDL, upgrades to a sparse Merkle tree |
| a set where **which fields are present is itself secret** | **aggregate `A`** | label/position blinding hides the shape |

## The worked case (SEDI)

- **[`sedi-id`](../sedi-id)** — the core identity credential: name, birth date, image, residence
  components. A fixed, heterogeneous, labeled set → **attribute `a`**, each attribute a nested
  partially-disclosable block. Bonus: as a plain v1 ACDC it version-stamps and SAIDs cleanly under this
  repo's pinned oracle.
- **[`sedi-age`](../sedi-age)** — age-threshold flags `ageOver13/16/18/21/55/65`. A homogeneous boolean
  vector you disclose a subset of → **aggregate `A`**, matching the ISO mDL `age_over_NN` element.

## Caveats worth remembering

- For a homogeneous vector where **all** members are always present, an attribute form wouldn't leak
  much either; the aggregate's real wins are **parity with mDL**, natural fit, and forward-compatibility
  (position-randomization/decoys and the sparse-Merkle upgrade). Don't over-claim a correlation delta.
- **Attribute-form partial disclosure forces the issuee (`a.i`) and the `a`-section metadata to be
  revealed** on any disclosure; an aggregate can disclose one element with no issuee. Usually the holder
  binding is wanted anyway, but note it when unbound disclosure matters.
- Under this repo's pinned **keri 1.2.13** oracle: a v2 **aggregate** credential can't be version-
  stamped (examples are unversioned; the AGID is computed by the v2 `Aggor`, not the linter), and
  **nested blocks aren't compacted** (a partial-disclosure form's `a.d`/`d` differ from the full form's).
  See [`this.i` `@sd2qfw`](../this.i). This is an oracle limitation, not a spec one.
