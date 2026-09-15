## Citations

### Purpose

This type of verifiable data embodies a formal reference to non-ACDC evidence. Citations resemble affidavits more than credentials; they have no issuee, and do not prove entitlement.


![suggested citation visual](citation-256.png)<br>
Suggested visual: [svg](citation.svg) | [256 px](citation-256.png) | [64 px](citation-64.png) | [32 px](citation-32.png)

### Use cases

Citations could be used to point to:

* Digital credentials such as a [W3C VC](https://www.w3.org/TR/vc-data-model-2.0/) or an [ISO mobile driver's license](https://www.iso.org/standard/69084.html)
* Cryptographically signed data, such as an X509 cert, a Bitcoin transaction, or a DID document
* Arbitrary digital files: invoices, bills of lading, regulatory reports, the score of a symphony that a composer wants to assert as their original work...
* Digital representations of physical evidence: biometric readings, photos of a crime scene, an audio or video interview with a witness, the PDF of a physical affidavit, a genome, a medical lab report, data from sensors and scientific instruments...
* Social media posts, chat transcripts, or the text of SMS/RCS/email messages (which SHOULD be [canonicalized](https://dhh1128.github.io/canonical-quoted-text/form.html) and hashed or [SAIDified](https://dhh1128.github.io/papers/bes.pdf) before citing)
* Physically published books
* Academic publications, legal precedents, and other content types that are referenced in traditional footnotes, endnotes, or bibliographies

Citations enrich KERI's verifiable data ecosystem, allowing it to gain value from numerous high-stakes contexts where evidence already plays a vital role. Imagine an ACDC that documents the outcome of a medical malpractice lawsuit. Instead of limiting itself to a simple assertion that the plaintiff prevailed, such an ACDC could include edges that link to Citation ACDCs: one citing the formal judgment filed with the clerk, another citing videos of expert testimony, another citing X-rays ([DICOM](https://en.wikipedia.org/wiki/DICOM) files), and another citing a key legal precedent according to [Bluebook conventions](https://www.legalbluebook.com/bluebook/v21/quick-style-guide).

### Semantic precision

We commonly assume that a physical or digital signature constitutes an endorsement of the signed content. An issuer signs an ACDC to assert whatever facts the ACDC asserts. Thus, it might be tempting to assume that the issuer of a Citation ACDC is asserting whatever facts are embodied or implied by the cited content. Verifiers MUST NOT make this mistake.

In careful, non-ACDC contexts, a citation proves that the issuer *intentionally referenced* some content, but it does not always mean more. An attorney may remind a hostile witness of what they previously said under oath. A doctor may reference a lab report to raise questions about an internal inconsistency. An academic may list a peer's paper with the express purpose of disagreeing with it.

A Citation ACDC has a similarly narrow meaning. *Analyzed without context* (a crucial caveat) it embodies a cryptographically provable reference by the issuer, and nothing more. It MUST NOT be construed as an endorsement by the issuer of the content it references. This is true whether or not the issuer created that content.

In order to eliminate the caveat about context, Citation ACDCs are designed to be referenced *only* via the edge of another ACDC (a *referencing ACDC*) that clarifies the intended semantics. Much like the running text of an academic paper contextualizes a footnote, the referencing ACDC MUST make it clear what the reference intends.

For example, imagine that Alice and Bob are bitter rivals in an election for the mayor of their town. Because Alice wants to skewer Bob, she creates a new ACDC citation each time Bob makes a counterfactual statement on social media. In isolation, each ACDC citation has no self-evident purpose; an outside observer can only conclude that Alice is curating verifiable evidence. Eventually, Alice assembles a single ACDC to document Bob's foolishness. Her ACDC has a dozen edges, one for each citation, and when Alice presents it to journalists, it becomes clear that she's using the citations to dispute Bob's commitment to facts.

Suppose Alice loses the debate and the election, and goes back to her original job as a professor at the local community college. In the class she teaches on social media marketing, she can use the same citations in an ACDC that shows interesting examples of creative copywriting; context now takes factuality off the table and makes the purpose of the citations instructive rather than political.

Verifiers MUST also remember that even when a citation exists for the simple purpose of supporting an assertion that the issuer endorses, the mere existence of the citation does not prove the referenced content accomplishes its purpose. A citation may point to content that doesn't exist, or to content that exists but is untrustworthy for various reasons. The algorithm that validates ACDCs (fetching key state, verifying a signature, testing revocation, and comparing data and structure to a schema) can prove that an issuer remains committed to a citation &mdash; but only the interaction context between verifier and prover, plus governance, plus possible validation external to the world of ACDCs, can tell a verifier what proposition's veracity is associated with the citation, and whether cited evidence satisfies their standards of proof.

To guarantee that all of these assumptions remain explicit, every Citation ACDC includes a [rules](rules.json) section that binds all parties to terms and conditions based on proper assumptions. 

### Governance framework

Every citation carries four Ricardian clauses, in [`rules.json`](rules.json) and embedded in the schema's `r` block, so the assumptions above travel with each instance rather than living only on this page.

`onlyCommitToPoint` says the citation, in and of itself, commits the issuer only to pointing at content in a way that makes the issuer and the target verifiable — never that the issuer owns, endorses, or agrees with it. `useViaEdges` says a citation is not meant to be used in isolation; the intended semantics come from a referencing ACDC. `undefinedVerification` says evaluating the authenticity or veracity of the referenced content is outside standard ACDC verification and belongs to the verifier. `undefinedRevocation` says there is no defined relationship between a citation's revocation status and that of the cited data: either may be withdrawn without the other.

An issuer that wants different terms places a different ruleset SAID in `r`.

### Field names

Version 2.0.0 spells the attribute names out, per the house style in [`../docs/style.md`](../docs/style.md): `des` → `description`, `typ` → `contentType`, `lbl` → `label`, `siz` → `sizeBytes`, `loc` → `locationHint`, `sdt` → `snapshotDt`. `dt` stays, because the style's own abbreviation glossary carries it. Two of the old names had collisions rather than mere terseness (`des` reads as the cipher, `loc` as lines-of-code or locale), and three dropped a load-bearing word rather than shortening one — a content type is not a type, a size in bytes is not a size, and a location *hint* is emphatically not a location, which is the point the field's own description spends a paragraph making.

### Privacy

The `content` block has always carried a salty nonce, and 2.0.0 makes it required: `cargo` is often a digest of content the observer may already hold, so an unblinded block is confirmable by exactly the party most likely to see it. The attributes block gains its own required nonce for the same reason, and the credential may carry an optional top-level one.

`rd` is optional here, unlike most of the corpus. That is not an oversight: this credential's own `undefinedRevocation` clause declines to give a citation's revocation any defined relationship to the cited data, so requiring a registry would compel machinery whose meaning the governance deliberately refuses to fix.

### Schema

The schema is in [`citation.schema.json`](citation.schema.json), its governance framework in [`rules.json`](rules.json), a SAID-verified instance in [`example.json`](example.json), and the social-media-post case in [`examples/`](examples). The [`invalid/`](invalid) directory holds the should-reject corpus, one fixture per defect.

Version 1.0.0 is preserved at [`citation-1.0.0/`](../citation-1.0.0) and stays resolvable under its original SAID. The ruleset is unchanged across the bump, so its SAID `EM6kWxMNL9BFm0ReegqQfNJLw8OZAfn2ZxcjWs4Ceifh` still resolves for both versions.
