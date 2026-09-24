## Foreign Evidence Credentials

A reissuer's record that it verified a credential Bakobo did not produce, by that credential's own rules. The reissuer issues it to the holder who presented the foreign credential. The first use is the SEDI Summit's inbound act (plan M9): the European Commission reference issuer's test PID, as an SD-JWT VC, verified against the Commission's published test CA (`this.i` @vho4mibp).

### What it records

- `format` and `credentialType`: the foreign credential's declared media type and its type, e.g. `dc+sd-jwt` and `urn:eudi:pid:1`.
- `foreignIssuer`: its `iss`, when it has one.
- `issuerChain` and `trustAnchor`: every certificate it carried and the anchor the chain was validated against, each by subject and SHA-256 of the DER.
- `checks`: every check in a closed vocabulary, in a fixed order, each with its outcome: `passed` (it ran and held) or `not-performed` (it did not run, and `caveats` says why). Each name is one piece of the verifier, so a record cannot claim a check no implementation performs. There is no `failed`: a failed check refuses the credential, and a refused credential yields no record.
- `caveats`: the checks that could not run, as Bakobo warning codes (`w.…`).
- `verifiedAt`: the moment the checks were made against.

| check | what ran |
|---|---|
| `size-bound` | the token was bounded before it was parsed |
| `framing` | the SD-JWT's `~` framing |
| `typ` | the header's media type is an SD-JWT VC's |
| `x5t-thumbprint` | `x5t#S256` matched the leaf, when the header carried one |
| `chain` | each link, each issuer's entitlement, path length, name constraints and validity windows, to a supplied anchor |
| `certificate-revocation` | each certificate against the CRL it names |
| `signature` | the issuer signature under the leaf |
| `time-window` | `iat`, `nbf` and `exp` |
| `issuer-binding` | the leaf's subjectAltName names `iss` |
| `disclosure-digests` | every disclosure is vouched for by a digest |
| `key-binding` | a key-binding JWT proved possession of `cnf` |
| `status-list` | the credential's status list entry |

### What it does not record

No claim value from the foreign credential, and no digest of it. A PID carries a name, a birth date and a nationality, and repeating them here would be a second copy of personal data under a signature that is not the issuing State's. A token digest would let anyone holding the PID link it to this record. The binding the demo needs comes from the issuee instead.

It is also not an endorsement. The rules say so: the reissuer records what it checked and when, not that the foreign issuer's claims are true, and a check describes the credential as it stood at `verifiedAt`.

### Schema

The schema is in [`foreign-evidence.schema.json`](foreign-evidence.schema.json), its rules in [`rules.json`](rules.json), and an instance issued by heti for the Commission's test PID, verified with its CRL, in [`example.json`](example.json). The [`invalid/`](invalid) directory holds one fixture per defect.
