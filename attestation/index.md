## Data Attestation Credential

### Purpose

A data attestation credential lets an issuer make a verifiable statement about data — a file, a JSON document, raw text, anything — by committing to its cryptographic digest rather than to the content itself. The content never travels with the credential, so an attestation can be published about material that is large, private, or both.

An attestation is **untargeted**: it names no issuee. The issuer is attesting a fact about content, not a relationship with a party, so there is nobody for the credential to be *about*. That is why the attributes block carries no `i`.

### What it does and does not assert

The credential commits to a digest and to nothing else. A verifier that has not recomputed the digest over content it holds has verified nothing about that content, however well the credential itself verifies — the signature proves who said it, not that what they said is true.

The issuer asserts only that the digest was computed over content the issuer observed at the stated time. It does not assert that the content is true, lawful, complete, authored by anyone in particular, or fit for any purpose. Both statements are carried as Ricardian clauses in the credential's rules section (`digestOnly`, `noContentAssertion`), so they travel with every instance rather than living only in this page.

### Privacy

Both nonces are load-bearing rather than decorative. An issuer that anchors into a public registry publishes the credential's SAID in the clear, so an observer who already holds the content — which is the ordinary case for an attestation — could otherwise confirm that this credential is about that content by recomputing the SAID. The top-level `u` blinds the credential's identity and is optional; the attributes-block `u` blinds the block and is **required**, because a block whose entire content is a digest and a datetime is guessable by anyone holding the digest.

### Lifetime

`validUntil` is optional. Its absence means the issuer set no horizon — never that the attestation is valid forever. Revocation is the registry's job, not the schema's: an attestation issued into a TEL can be revoked there, and `rd` names that registry. `rd` is optional so that a short-lived attestation can be issued registry-free, in which case `validUntil` is the whole of its lifetime story.

### Schema

The schema is in [`attestation.schema.json`](attestation.schema.json), its governance framework in [`rules.json`](rules.json), and a SAID-verified instance in [`example.json`](example.json). The [`invalid/`](invalid) directory holds the should-reject corpus, one fixture per defect.

Version 2.0.0 adopts the ACDC v2 envelope: `rd` replaces v1's `ri`, the top-level order follows the v2 spec, and the attributes, edges and rules sections each offer a compact SAID-string form first. Version 1.0.0 is preserved at [`attestation-1.0.0/`](../attestation-1.0.0) and stays resolvable under its original SAID.
