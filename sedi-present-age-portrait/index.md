## SEDI Age-and-Portrait Presentation (`sedi-present-age-portrait`)

### Purpose

`sedi-present-age-portrait` is a **holder-issued presentation** for the most common SEDI verification
pattern: *prove you are over 21 and show your state-endorsed photo* — venue/alcohol admittance and the
like (Utah Code 63A-20-204(2)(a)). It is the response a holder like Alice hands a verifier like a club.

Unlike the source credentials it draws on, the **holder is the issuer** here (the Discloser) and the
**verifier is the issuee** (the Disclosee). The presentation does not copy any identity data; it
**references** the holder's two source credentials by SAID through `I2I` edges — the
[`sedi-id`](../sedi-id) identity root (the state-endorsed portrait is reached by selectively disclosing
just that block) and a [`sedi-age`](../sedi-age) attestation (the over-21 boolean) — and binds the
verifier to the [SEDI governance framework](../sedi-id/rules.json) referenced in `r`.

It is deliberately **not registry-bound** (no `rd`): a one-time presentation is not logged, which is
what keeps the state (and anyone else) from correlating where and when the holder presents.

### Why this exists as a named pattern, not a "bespoke" credential

"Bespoke" describes an *issuance pattern* (a holder self-issues a disclosure-specific ACDC), not a
credential *type* — so there is no useful generic "bespoke" schema to publish. What *is* reusable is a
**named verification pattern**: "age + portrait for admittance" recurs across every bar, club, and
event in the state. So this schema is named by its pattern, and the verifier's *request* for it stays a
query (an IPEX `apply`), not a separate schema. The club's accepted shape and the holder's issued
presentation are one schema viewed from two sides. A general `presentation-base` (that this and future
patterns would specialize) is intentionally deferred until a second pattern exists to prove the shared
shape — see `this.i` `@sdp3wk`.

### What the schema enforces (the teeth)

The schema is not just descriptive; it rejects malformed presentations:

- **`I2I` on every edge** — each edge operator `o` is pinned to `const "I2I"`. I2I ("issuer-to-issuee")
  holds only when the issuer of this presentation is the issuee of the credential the edge points to.
  Since Alice issues the presentation and is the issuee of both source credentials, this is exactly the
  same-holder binding — it is what distinguishes "Alice presenting *her own* credentials" from "two
  credentials that merely share an AID," which anyone could assemble. A non-`I2I` operator is rejected.
- **`r` is required** — a presentation with no governance-framework reference is rejected; the verifier
  must have terms to accept.
- **`rd` is disallowed** (`additionalProperties: false`) — a registry-bound presentation is rejected,
  enforcing the "one-time, not logged" intent.

### Structure

| Section | Contents |
|---|---|
| `i` | issuer = the holder (Discloser) |
| `a` | `i` = the verifier (Disclosee), `ageOver21`, and the interaction facts `venue` / `occurredAt` |
| `e` | `identity` (I2I → `sedi-id`) and `age` (I2I → `sedi-age`) edges, each naming the far node SAID (`n`) and its schema SAID (`s`) |
| `r` | SAID of the SEDI governance framework ([`sedi-id/rules.json`](../sedi-id/rules.json)) |

The `ageOver21` attribute is the holder's asserted summary; its authority comes from the `age` edge to
the `sedi-age` credential, not from the holder's say-so.

### Presentation flow

In use, this runs as a gated IPEX exchange (`apply → offer → agree → grant → admit`): the verifier
accepts the governance terms (a signed `agree` referencing the presentation's SAID) **before** any PII
— the state-endorsed photo — crosses the wire, and a decline never opens the gate. The photo itself is
delivered as a partial disclosure of just the `image` block of `sedi-id` (an attributive credential),
verified against that credential's committed `a` section, while the over-21 flag is a selective
disclosure of just the `ageOver21` block of the aggregate `sedi-age`. The executable reference is keripy's
`tests/acdc/test_clc_disclosure.py`.

### Schema and example

See [`sedi-present-age-portrait.schema.json`](sedi-present-age-portrait.schema.json). The
[`example.json`](example.json) is Alice's presentation to the club: `i` = Alice, `a.i` = the club,
`ageOver21` true, `venue`/`occurredAt` set, `identity`/`age` I2I edges to the real `sedi-id` and
`sedi-age` example credentials, and `r` the SEDI governance framework SAID. The [`invalid/`](invalid)
corpus rejects a registry-bound (`rd`) presentation, a missing `r`, a non-`I2I` edge operator, a
missing edge block, a missing/`non-boolean` `ageOver21`, an edge missing its far-node SAID, and a
malformed `occurredAt`.

### Governance

The chain-link-confidentiality and duty-of-loyalty terms live in the SEDI governance framework
([`sedi-id/rules.json`](../sedi-id/rules.json)), referenced by SAID from `r` — not authored per
presentation. Accepting the presentation is binding acceptance of those terms.
