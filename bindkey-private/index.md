## Private BindKey Credentials

A holder declares, privately, a P-256 key it controls outside its KEL, so that a reissuer can bind a credential derived from the holder's credential to that key: the SD-JWT VC `cnf`, and later the mDoc `deviceKey`. The key may live in a phone's secure hardware, which is why it cannot simply be one of the AID's own signing keys. The holder issues this credential to itself (issuer and issuee are the same AID) into its own presentation registry, and shows it only to the reissuer, which verifies it before deriving. Derived from SEDI bulk copy k, a derivative binds to the key copy k's holder AID declares here (sedi-summit plan, decision D5; `this.i` @kakslwv3).

### How it differs from `bindkey`

[`bindkey`](../bindkey/) is a public announcement, correlatable on purpose: no nonce, no issuee, no compact form, because being confirmable by anyone is its function. This schema inverts each of those choices for the opposite reason:

| | `bindkey` | `bindkey-private` |
|---|---|---|
| Audience | anyone | the reissuer only (`privateToTheReissuer`) |
| Nonce | none | top-level `u` and attribute `u`, each at least 24 characters (a CESR 128-bit salt), so a guessed key cannot be confirmed by recomputing a SAID |
| Issuee | none | the holder itself |
| Compact form | none | `a` and `r` compact to their SAIDs |
| Key | any format, including RSA | P-256 only, as a `jwk` object (kty `EC`, crv `P-256`, no private `d`) or a CESR `1AAJ`/`1AAI` string |
| Purpose | free `uses` strings | the constant `holderBindingForDerivation` |
| Lifetime | `validUntil` optional | `validUntil` required; every derivative must fall inside the binding's window |

Do not use `bindkey` for a holder binding. A public binding would let every relying party that sees a derivative join it to the holder AID, which undoes the uncorrelatable bulk copies it was derived from.

### What a verifier must still check

The schema cannot check that issuer and issuee are the same AID, that the AID is the issuee of the credential being derived from, that the registry state is live, or that `validUntil` has not passed. Times are RFC 3339 date-times with an offset or `Z` (JSON Schema `date-time`). When `validFrom` is absent, the binding starts at its issuance as recorded in the holder's registry, not at `dt`, which is only the holder's own word. No maximum lifetime is enforced. The reissuer checks all four before deriving, and the `bindingEndsOnHorizonOrRevocation` rule says so in the credential.

### Schema

The schema is in [`bindkey-private.schema.json`](bindkey-private.schema.json), its rules in [`rules.json`](rules.json), and a heti-issued instance in [`example.json`](example.json). The [`invalid/`](invalid) directory holds one fixture per defect.
