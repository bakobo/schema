## Org Vet Credentials

### Purpose

This credential asserts with an explicit level of assurance the existence and attributes of an organization. It is issued to a cryptographic identifier controlled by the org, allowing the org to authenticate itself on the basis of the credential. (The [LE vLEI](https://docs.origincloud.net/start/concepts/creds/vleis) is essentially an org vet credential at LoA 3, but its schema varies slightly to express some GLEIF governance requirements.)

![suggested org vet visual](org-vet-256.png)<br>
Suggested visual: [svg](org-vet.svg) | [256 px](org-vet-256.png) | [128 px](org-vet-128.png) | [64 px](org-vet-64.png) | [32 px](org-vet-32.png)

### Levels of assurance

Levels of assurance (LoAs) are well known and often referenced for individual identity; they are less adopted in organizational identity. In the United States, the FBCA [defines](https://www.idmanagement.gov/docs/fbca-cp.pdf) *basic*, *medium*, and *high* assurance for certificates issued to federal agencies, but these LoAs are not typically referenced in other contexts. In the EU, eIDAS ([EU regulation 910/2014](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32014R0910), article 28) defines "nonqualified" and "qualified/QSeal" assurance for certificate issuance &mdash; but its rollout is young, and its application for non-certificate-based technologies is unclear.

Org vet credentials convey a level of assurance with a positive number, where larger numbers map to higher levels of assurance (1 &lt; 2 &lt; 3). Normally, these numbers are expected to be integers, but nuances within a given integer can be modeled by using a floating point value instead (2.1 &lt; 2.2). This allows verifiers to decide what level of assurance will satisfy them, and accept any credential having an LoA >= their threshhold. The meaning of the integer values are defined as follows:

LoA | intended meaning | verification procedures | mappings
--- | --- | --- | ---
1 aka "bronze"| basic proof of control + authorization of requester; no claim about legalities, tools, governance, tools, or competence | <ol><li>Prove that a non-cryptographic identifier (e.g., an LEI) references an org that exists and is not defunct.</li><li>Prove org owns domain.</li><li>Prove requester is human and has email in domain.</li><li>Prove requester has modified a DNS record for the domain to claim the issue's cryptographic identifier (AID).</li></ol> | Similar to FBAC "basic" or eIDAS "nonqual".
2 aka "silver"| cryptographic proof of control + authz, legal accountability, tools; no claim about governance or competence | <ol><li>Satisfy requirements for LoA 1.</li><li>Prove the legal identity of the requester via a digital credential having eIDAS *substantial* assurance, or use a physical credential that meets ISO/IEC 2915 LoA2 or NIST IAL2 requirements.</li><li>Prove cryptographically (e.g., using a [GCD credential](../gcd/index.md) and/or a KERI delegated AID) that the requester was authorized by the org to request a credential for it.</li><li>Use at least 1 witness for the org's AID.</li></ol> | Similar to FBAC "medium", X509 extended verification, or eIDAS nonqual with deep vet. However, not a perfect analog; we are proving that the org has the tools to maintain their identity for a long time.
3 aka "gold" | <ol><li>Satisfy requirements for LoA 2.</li><li>Prove that the requester has legal signing authority for the org.</li></li>Prove that the org has a multisig signing committee to manage risk and human turnover.</li><li>Issue the credential in a ceremony where it is proved that there is no MITM between any two members of the signing committee, and between each member of the signing committee and at least one external observer.</li><li>Require that the AID of the org use enough witnesses to reliably detect and recover from duplicity.</li></ol> | This approximates FBAC "high" and eIDAS "QSeal", but goes slightly beyond. It maps directly to the LE vLEI defined by GLEIF.
4 aka "platinum" | TBD, but could require use of hardware security and/or proof of specialized org attributes such as a security clearance. | none




### Governance framework

These credentials carry four Ricardian clauses, in [`rules.json`](rules.json) and embedded in the schema's `r` block, so they travel with every instance rather than living only on this page.

`loaIsTheIssuersProcedure` says the level of assurance states which procedures the issuer carried out — not a guarantee about the organization, and no transfer of risk beyond having carried them out. `noClaimBeyondTheTier` says each tier asserts only what its own procedures establish, so a credential below the tier that checks a thing says nothing about the organization's legal standing, signing authority, governance, tooling, solvency or competence. `lidsAreReferencesNotAssertions` says the linked identifiers are what the vetter was able to use, not a claim that each registry entry is current or exclusively controlled by this organization. `assuranceIsPointInTime` says the vetting speaks as of its datetime, obliges the issuer to revoke promptly once the tier no longer holds, and requires a verifier to check the registry rather than treat an unexpired credential as current.

An issuer that wants different terms places a different ruleset SAID in `r`.

### Schema

The schema is in [`org-vet.schema.json`](org-vet.schema.json), its governance framework in [`rules.json`](rules.json), and a SAID-verified instance in [`example.json`](example.json). The [`invalid/`](invalid) directory holds the should-reject corpus, one fixture per defect.

Version 2.0.0 adopts the ACDC v2 envelope — `rd` replaces v1's `ri` and the top-level order follows the v2 spec — and makes the credential say what this page always said it did. `a.i` is now present and required, so the credential is genuinely issued *to* the organization's AID; `loa` and `lids` are required, because a vet with no assurance level and no references is not a vet; `loa` is bounded to the 1–4 the table above defines; and both `additionalProperties` gates are closed. Version 1.0.0 is preserved at [`org-vet-1.0.0/`](../org-vet-1.0.0) and stays resolvable under its original SAID.

