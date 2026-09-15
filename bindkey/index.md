## BindKey Credentials

These credentials let the controller of an identifier make a formal, public, portable declaration that they use another cryptographic key (besides the one controlling their identifier) for a particular purpose.

![suggested bindkey visual](bindkey-256.png)<br>
Suggested visual: [svg](bindkey.svg) | [256 px](bindkey-256.png) | [128 px](bindkey-128.png) | [64 px](bindkey-64.png) | [32 px](bindkey-32.png)

Normally, we expect key control to be expressed in the [KEL](https://weboftrust.github.io/WOT-terms/docs/terms/glossary/key-event-log?level=3) or a DID doc. However, there exist use cases where such things must be externalized. For example, the email security standards [SPF, DKIM, and DMARC](https://www.cloudflare.com/learning/email-security/dmarc-dkim-spf/) deal with how a company can force all email from their domain to meet a higher standard of proof (to eliminate phishing and other spoofing). These standards want a company to use RSA keys. We don't really want identifiers to be controlled by RSA crypto, but it could be useful for orgs to announce to the world that they are using an RSA key for these email security standards.

### How the key is encoded

That use case is the reason `pubkey` is not CESR-only. CESR has no RSA code — the pinned fork's codex carries Ed25519 and ECDSA 256k1/256r1 and nothing else — so a schema that accepted only CESR primitives could not express the very case this credential was designed around. `pubkey` is therefore a plain string and a required `keyFormat` says how to read it:

| `keyFormat` | `pubkey` holds |
|---|---|
| `cesr` | a CESR primitive, the KERI-native form |
| `spki-der-b64` | base64 of the DER SubjectPublicKeyInfo — what DKIM publishes in the DNS `p=` tag |
| `pem` | the same SPKI, PEM-armored |
| `openssh` | an OpenSSH public-key line, as in `authorized_keys` |
| `jwk` | a serialized JSON Web Key |

`keyFormat` is **required**, not defaulted. A JSON Schema `default` is an annotation that nothing applies, so an absent `keyFormat` would leave two readers free to parse the same key differently — and a key parsed under the wrong assumption is worse than a key not parsed at all. For the same reason the schema asserts no pattern on `pubkey`: the encodings it admits are the parser's business, and a verifier that does not recognize a `keyFormat` MUST refuse the key rather than guess, which the `unknownFormatFailsClosed` rule says in the credential itself.

[`examples/dkim-rsa.json`](examples/dkim-rsa.json) is the motivating case end to end: a real 2048-bit RSA public key, `spki-der-b64`, declared for `spf`, `dkim` and `dmarc`.

### Public on purpose

A bindkey is an announcement, so it carries no privacy nonce in either slot and offers no compact form. Both are deliberate departures from the corpus default. A nonce exists to stop an observer confirming a guess about a credential's contents; here, being confirmable by anyone who knows the issuer and the key is the entire function. And a form of this credential with the key withheld would say nothing worth presenting, so the attributes block is uncompactable by design.

That means a bindkey is correlatable, and is meant to be. Do not use this schema for a key binding you would rather nobody noticed.

### Revocable

`rd` is required. A key binding that cannot be withdrawn is a claim that outlives the facts, and revocability is half of what this credential exists to provide — a compromised or retired key needs a public retraction as much as it needed a public declaration.

`validFrom` and `validUntil` bound the issuer's intent. An absent `validFrom` means the binding starts on issuance; an absent `validUntil` means the issuer set no horizon, so the binding stops only on revocation — never that it is perpetual. A verifier has to check the registry either way, which the `bindingEndsOnHorizonOrRevocation` rule says in the credential itself.

### What it does not assert

The issuer declares that it uses this key. It does not assert that the key is uncompromised, well managed, generated soundly, or held only by the issuer. The `uses` strings say what the issuer intends the key for and confer no authority: a verifier that treats a declared use as permission has granted that permission itself. Both statements travel with every instance as Ricardian clauses rather than living only on this page.

### Schema

The schema is in [`bindkey.schema.json`](bindkey.schema.json), its governance framework in [`rules.json`](rules.json), a SAID-verified instance in [`example.json`](example.json), and a gallery in [`examples/`](examples). The [`invalid/`](invalid) directory holds the should-reject corpus, one fixture per defect.

Version 2.0.0 adopts the ACDC v2 envelope: `rd` replaces v1's `ri`, the top-level order follows the v2 spec, `startDate`/`stopDate` become `validFrom`/`validUntil` so the corpus spells one concept one way, and `pubkey` gains the `keyFormat` discriminator that makes non-CESR keys expressible. Version 1.0.0 is preserved at [`bindkey-1.0.0/`](../bindkey-1.0.0) and stays resolvable under its original SAID.
