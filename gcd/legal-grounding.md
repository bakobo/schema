# The legal grounding of GCD

GCD 5.0.0 was reshaped by two bodies of legal research and a hostile review. This page explains what the law asks of a delegation, how each part of the credential answers it, and where the credential has to stop and let the law decide. The field-by-field reference is in [index.md](index.md); the decisions behind it are in the repository's `this.i` under `@3w3rkmt3`.

The two sources are Dazza Greenwood's study of 25 everyday authorization instruments [1], which he presented at IETF 127 [2], and the model acts that Michael G. Leahy publishes at fiduciarycommons.com [3, 4, 5]. Leahy's acts are model legislation and have not been enacted anywhere, so they are cited here as a careful drafter's proposals, not as law.

## One sentence of delegation

Greenwood reduces a grant to AI-mediated purchasing to one sentence [2]:

> Harbor Workshop, Inc., acting by its COO, appoints Northstar Purchasing LLC to place one order with Alder Supply for one Model R filter, at a total of no more than USD 400, before November 13. Northstar accepts.

Each clause of that sentence is a legal fact, and the rest of this page follows them in turn. The [ai-purchasing-agent](examples/ai-purchasing-agent.json) example encodes the whole sentence, and every clause but one has a field. The clause that doesn't is the last one, and it is the subject of the section on acceptance.

The question isn't academic. In August 2026 the Ninth Circuit held, on the record before it, that "It is the user who 'accesses' Amazon's computers, with the help of the Assistant," and declined to decide "whether in other contexts, including tort claims, Perplexity can avoid liability for the Assistant's actions" [6]. Who answers for what an AI agent does is now a question courts are asking, and the answer depends on facts a credential can either carry or leave out.

## Not every delegation is a legal one

Much delegation never meets a lawyer. A person inside an organization lets an AI assistant accept meetings in their name and expects colleagues to treat its replies as theirs. A manager hands a colleague the approval queue for a week. A family member lets a relative read their tax transcripts. GCD has to be comfortable in all of these, and it is designed to be.

It does that with two paths. On the light path, the issuer names no agent of record. The delegate is then either the principal's own software, for which the principal answers as it would for any tool, or a person who answers for themselves and accepts the delegation simply by admitting the credential into their wallet. There is no extra paperwork and no extra check for a verifier. The [exec-assistant-ai](examples/exec-assistant-ai.json) and [platform-manager](examples/platform-manager.json) examples take this path.

The heavy path applies when a third party operates the delegate, as Northstar operates the purchasing bot. Then the operator is named as agent of record, discloses its interests before the grant, and accepts after it, and a verifier checks the acceptance. A professional who acts for itself, such as a realtor, may choose the heavy path to put its disclosure on record.

The rules travel with every GCD, compacted to a single identifier, and they cost nothing where no legal question arises. Inside an organization they still do useful work, because they say what a colleague may rely on and what the assistant's owner has taken responsibility for.

## Who is who

A delegation has more parties than a grant names. In Greenwood's sentence there are at least four: Harbor, which is bound; its COO, who signs; Northstar, which acts; and Northstar's software, which does the clicking. GCD 4.0.0 had one field for all of this outside the issuer and the issuee, `liableParty`, and in four of its seven examples that field simply repeated the issuer.

The Restatement (Third) of Agency defines agency as "the fiduciary relationship that arises when one person (a 'principal') manifests assent to another person (an 'agent') that the agent shall act on the principal's behalf and subject to the principal's control, and the agent manifests assent or otherwise consents so to act" [7, §1.01]. That definition puts responsibility on two parties, not one. The principal is bound by the agent's authorized acts [7, §§6.01, 7.03]. The agent answers for its own conduct, and warrants to the people it deals with that it has the authority it claims [7, §§6.10, 7.01].

Software can occupy neither seat. Deborah DeMott, who was the Reporter for that Restatement, concludes that "an agentic AI system lacks capacity to be an 'agent' in a common law agency relationship with any person or entity deemed to be its 'principal.' The system is an instrumentality created by its developer and deployed by its user, and not the common law agent of either" [8]. Greenwood reaches the same conclusion from the forms: "the AI agent itself is not the entity that acts as the legal agent" [1, README].

So GCD 5.0.0 names roles and lets the law work out liability, which is a conclusion a court reaches from facts and not a fact an issuer can state. The facet carries `principal`, the party bound by the delegate's authorized acts and on whose account they are taken, which defaults to the issuer and is set only when the two differ. It carries `agentOfRecord`, the legal person the principal appoints and who acts through the delegate. Northstar is an agent because Harbor appointed it and it agreed, which is ordinary agency, not because it stands behind software. When the principal deploys its own software, nobody is an agent, and the principal answers for its tool as its own, including by apparent authority [8]. Tribunals have already treated it that way: in Moffatt v. Air Canada, a British Columbia tribunal held an airline responsible for what its website chatbot told a customer [25].

Guardianship needs a caution. A court-appointed guardian's power comes from a court order, not from the assent of the person under guardianship, so the guardian isn't that person's agent in the §1.01 sense. The `principal` field still names the person for whom the guardian acts, in the sense of the party bound and on whose account, and the docs for that case point to the guardianship statute instead [9]. That statute, the Uniform Guardianship, Conservatorship, and Other Protective Arrangements Act, also retires the word "ward" [9], and this page follows it. The UN Convention on the Rights of Persons with Disabilities asks for "access by persons with disabilities to the support they may require in exercising their legal capacity" [10, Art. 12(3)], which is why the human-review rule prefers the principal's own supported decision to a third party's veto wherever the principal can take part.

[SUGGESTED DIAGRAM: Parties and credentials — the principal (issuer), the agent of record, and the delegate's software, with arrows in time order for the disclosure (agent of record to principal), the GCD (issuer to delegate), the acceptance (agent of record to principal), the act (delegate to a counterparty), and the counterparty's receipt.]

## What may be done, and on what

The paper instruments separate kinds of authority that a single OAuth scope runs together. The IRS uses one form, 8821, for authority to receive tax information [11] and another, 2848, for authority to represent [12]. GCD expresses the same split in `acts`, which locates each act by its effect and the kind of state it touches, so an information-only grant is a credential whose acts are all `observe` points. The [tax-information-reader](examples/tax-information-reader.json) example is the 8821 analogue.

Authority also has to say what it may act on. Brokerage custody rules have handled this for years: under the SEC staff's conditions for a standing letter of authorization, the client names the payee in a signed instruction to the custodian, and "the investment adviser has no authority or ability to designate or change the identity of the third party" [13]. Computer science found the same defect from the other side. Norm Hardy's compiler held a license to write in its own home directory, granted so it could write a billing file, and a user tricked it into overwriting that file with debug output; "the compiler runs with authority stemming from two sources" [14]. GCD's `targets` field, added in 4.0.0, is the payee list the agent can't edit, and the [payments-steward](examples/payments-steward.json) example shows it stopping a business-email-compromise payment that every other check would pass.

### Reserved powers

Some powers are too dangerous to be implied by the breadth of a grant. The Uniform Power of Attorney Act lists acts an agent may do "only if the power of attorney expressly grants the agent the authority": creating or changing a trust, making a gift, changing rights of survivorship or a beneficiary designation, delegating authority, waiving a survivor annuity, exercising delegable fiduciary powers, and disclaiming property [15, §201(a)]. The IRS makes substituting a representative a separate election on Form 2848 [12, line 5a], and the VA makes changing a claimant's address a separate box on its appointment form [16, item 21]. SEC Rule 14a-4(d) goes further and lists things a proxy can never confer at all [17].

In GCD 4.0.0, a credential with no `acts` field authorized every kind of act, including those. GCD 5.0.0 adds a `reservedPowers` constraint with a closed vocabulary. Eight of its ten codes follow UPOAA §201(a). The other two come from elsewhere: `redirectNotice`, which covers changing the channels through which the principal hears about its own affairs, follows the VA form and the IRS's refusal to let a representative redirect refund checks at all [12, line 5b], and has no counterpart in UPOAA; `selfDeal` follows the common-law duty against acting for oneself or for an adverse party [7, §8.03], which German law states as a flat bar on a representative transacting with itself [18]. Absent the field, no reserved power is granted, and a rule makes clear that no role, governance framework or approval can supply one.

The principal narrowing or revoking its own grant is never a reserved power. Protective acts have to stay cheap, or the safeguard becomes a trap for the person it protects.

## Disclosure first, acceptance second

The last clause of Greenwood's sentence is "Northstar accepts." Agency rests on mutual assent [7, §1.01], and an agent may deal in conflict with its principal only after the principal consents with knowledge of all material facts [7, §8.06]. The loyalty these rules require is the old one: "Not honesty alone, but the punctilio of an honor the most sensitive, is then the standard of behavior" [19, at 464].

A first draft of 5.0.0 had the agent disclose its interests in the same document in which it accepted, after the grant was issued. That ordering asked the principal to consent before seeing what it consented to. The design that shipped puts two credentials on either side of the grant. A `gcd-disclosure`, issued by the would-be agent of record to the principal before the grant, states the compensation it expects from anyone and its material conflicts, and the GCD references it by edge, so issuing the grant is evidence of consent to exactly that disclosure and nothing else. A `gcd-acceptance`, issued by the agent of record after the grant, names the credential exactly and accepts without qualification. When `agentOfRecord` is present, a verifier denies any act until it is shown a matching acceptance whose signature verifies.

The disclosure is addressed to the principal and may travel compacted, because publishing who pays an agent to every verifier is a privacy harm, not a safeguard.

## Three jobs for one rules block

The rules section of an ACDC is a Ricardian contract: terms carried by hash inside the credential. The first draft of the 5.0.0 rules asked that one block to do three jobs at once, gating machines, binding the parties who signed, and telling strangers what to do, and nine reviewers took it apart wherever those jobs collided. Software can't accept a contract. A verifier can't be bound by terms it never agreed to. And a verifier can't gate on incapacity, on whether an act benefits the agent, or on whether a human review was careful, because it can't observe any of those things.

The rules that shipped separate the jobs. One clause, `machineGate`, lists every condition a verifier checks, and says the list is exhaustive. The other clauses may limit authority in law but add nothing a verifier checks. Binding follows signatures: the issuer by issuing, the agent of record by accepting, a delegate that is a person by admitting the credential, and anyone who controls the delegate with notice of the rules by an undertaking implied from that conduct. A relying party is bound only by an agreement it signs separately. Leahy's model acts take the same line, holding that "silence, failure to opt out ... or acceptance of unrelated terms does not establish authorization" [3, §20(h)], and civil-law reviewers added that standard terms a party never saw aren't incorporated at all.

Toward a bank or a colleague, the rules state conditions of reliance instead of obligations. Within its constraints, the credential is the issuer's representation, made for the principal, that the delegate has the authority it describes; outside them, it is no evidence of authority. Termination of actual authority doesn't by itself end apparent authority [7, §3.11], so the credential says what someone who saw it may assume and leaves the rest to the law.

A savings clause says that nothing in the rules waives a right or duty the law makes mandatory, and an optional `governingLaw` names the law that governs the relationship among those who signed, without displacing protections that mandatory law gives a consumer, an employee or a person under guardianship.

## When authority ends

Agency law ends actual authority on the principal's death, and on loss of capacity unless a written instrument provides otherwise, and in each case only once the agent, or a third party, has notice [7, §§3.07, 3.08]. The Uniform Power of Attorney Act makes a statutory power durable by default [15, §104] and protects a person who acts in good faith without actual knowledge that the power has ended [15, §110(d)–(e)]. German law, by contrast, lets a power of attorney survive incapacity by default. A credential that defined these defaults would be wrong somewhere.

So the rules defer. As between the parties, authority ends as the governing law provides, including on death, loss of capacity or dissolution, and the `durable` field records the principal's intent and has whatever effect that law gives it. The rules don't define incapacity; the human-rights reviewer pointed out that a defined trigger becomes an automatic kill switch on a person's own arrangements. Toward verifiers, the credential is honest about what it can do. A `terminatingEvents` entry ends authority for a verifier only when it is shown to that verifier, so the issuer's duty to revoke, checked through KERI revocation status on every act, and the `validUntil` ceiling remain the backstops. Revocation is prospective and undoes nothing completed while authority existed.

## The principal's own words

In law, authority is created by what the principal communicates. Greenwood's crosswalk of the IETF drafts found that the person's words are usually "context, with no effect" [2]. Mission-Bound Authorization forbids a server to gate on them [20, §5.2], Bounded Work says its description "does not itself restrict anything" [21, §4.1.1], and AAuth binds its mission text by digest while calling it "intentionally not a machine-evaluable policy language" [22, App. C.3.5].

GCD binds the words the principal approved by digest, in `grantText`. The digest is computed over CQT 3.17, a canonicalization that survives copy and paste, and the field names the identifier `cqt3.17` because the CQT specification requires a protocol to "bind the exact ASCII identifier `cqt3.17` in whatever it signs" [23]. The field also records who drafted the text, because ambiguous terms are read against their author and agents often draft what principals approve. A rule says what the digest is: evidence of the words, which never widens the machine constraints but may show that the principal granted less.

## What only the law can decide

Some questions no credential can settle, and the docs are better for saying so. They fall into four groups.

The first is conclusions only a court reaches: liability itself; whether a counterparty must honor a valid grant, which some statutes enforce with a court order and attorney's fees, not damages [15, §120(c); 24, §4406]; whether a principal later ratified an act; and apparent authority arising from conduct outside the credential.

The second is facts about minds and ceremonies. A signature proves that a key acted, not that a person understood or consented freely, and not that the screen they approved on was out of the agent's reach. GCD's `execution` edge points to a witness's attestation, such as a notary's, for the grants where that matters, but the attestation is the witness's word, not proof of a state of mind.

The third is facts an open-loop verifier can't see. A cumulative budget, single use, exclusivity and rate limits all depend on other acts, and a stranger checking one act sees only that act. A credential can state such limits; the delegate has to enforce them, and they are audited afterwards through the records the rules require. The verifier also can't prove that an issuer without a `parent` edge held its authority in its own right, and can't stop an operator that routes its work through an asset-free company; those are questions for the law of agency by conduct and veil-piercing.

The fourth comes from Leahy's distinction between authority a legal source granted and authority that is legitimate, meaning necessary and proportionate [3, 4]. A GCD can prove the first. It can never settle the second.

## How this was checked

The two bodies of research were read against GCD 4.0.0 in November 2026 [1, 2, 3, 4, 5]. Every source cited here was checked against its primary text where that text could be reached. Most Restatement sections could not be: every site hosting the text refused automated access, so §1.01 rests on DeMott's verbatim quotation as the Restatement's Reporter, §§3.11 and 8.12 on the Uniform Law Commission's official comments to the UPOAA, and the remaining sections on secondary quotation. The rules language went through three rounds of adversarial review by personas including an agency lawyer, a civil-law jurist, a consumer advocate, a human-rights advocate, a litigator, a bank's counsel, a data-protection lawyer, a verifier engineer, and hostile counsel for an AI operator, each played by a model from a different lab. The limits named in the previous section are the findings those rounds recorded and did not resolve.

## References

[1] Dazza Greenwood. 2026. Written Agent Authorizations: 25 Instruments, Dissected for AI-Agent Design. Version 0.3.4 (Nov. 14, 2026), with the README research overview v0.3.2. GitHub repository dazzaji/agent4whom, commit 8df8730. Retrieved November 19, 2026 from https://github.com/dazzaji/agent4whom/tree/8df8730

[2] Dazza Greenwood. 2026. On Behalf Of Whom? What the Law Asks of Agent Protocols. Invited talk, IAB Open, IETF 127, San Francisco, Nov. 20, 2026. Slides at GitHub repository dazzaji/agent4whom, commit 8df8730. Retrieved November 19, 2026 from https://github.com/dazzaji/agent4whom/blob/8df8730/slides/VibeDeck-for-Historical-and-Histerical-Archive/4whom.md

[3] Michael G. Leahy. 2026. Personal Data Trusteeship Act, Version 2.2, Clean Restated Legislative Candidate (Sept. 13, 2026). Model legislation, not enacted. Fiduciary Commons. Retrieved November 19, 2026 from https://fiduciarycommons.com/documents/acts/pdta-v2-2.pdf

[4] Michael G. Leahy. 2026. Government Algorithmic Accountability and AI Fiduciary Act, Version 2.2, Clean Restated Legislative Candidate (Sept. 13, 2026). Model legislation, not enacted. Fiduciary Commons. Retrieved November 19, 2026 from https://fiduciarycommons.com/documents/acts/gaafa-v2-2.pdf

[5] Michael G. Leahy. 2026. Verifiable Identity and Digital Autonomy Act, Version 2.2, Clean Restated Legislative Candidate (Sept. 2026). Model legislation, not enacted. Fiduciary Commons. Retrieved November 19, 2026 from https://fiduciarycommons.com/documents/acts/vida-v2-2.pdf

[6] Amazon.com Services, LLC v. Perplexity AI, Inc., No. 26-1444, slip op. at 7, 15, 17 (9th Cir. Aug. 4, 2026). Retrieved November 19, 2026 from https://cdn.ca9.uscourts.gov/datastore/opinions/2026/08/04/26-1444.pdf

[7] American Law Institute. 2006. Restatement of the Law Third, Agency. 2 vols. American Law Institute Publishers, St. Paul, MN. Deborah A. DeMott, Reporter. https://www.ali.org/publications/restatement-law-third/agency. Sections cited from secondary quotation; see "How this was checked".

[8] Deborah A. DeMott. 2026. When Agentic AI Met the Common Law of Agency. Harvard Journal of Law & Technology (forthcoming). SSRN preprint. DOI: https://doi.org/10.2139/ssrn.6838660. Quoted from the abstract.

[9] Uniform Law Commission. 2017. The Uniform Guardianship, Conservatorship, and Other Protective Arrangements Act: A Summary. Retrieved November 19, 2026 from https://www.aging.senate.gov/download/ulc_-the-guardianship-conservatorship-and-other-protective-arrangements-act?download=1

[10] United Nations. 2006. Convention on the Rights of Persons with Disabilities. Adopted by the General Assembly Dec. 13, 2006. Retrieved November 19, 2026 from https://www.un.org/disabilities/documents/convention/convoptprot-e.pdf

[11] Internal Revenue Service. 2021. Form 8821: Tax Information Authorization (Rev. January 2021), and Instructions for Form 8821 (Rev. September 2021). U.S. Department of the Treasury. Retrieved November 19, 2026 from https://www.irs.gov/pub/irs-pdf/f8821.pdf and https://www.irs.gov/instructions/i8821

[12] Internal Revenue Service. 2021. Form 2848: Power of Attorney and Declaration of Representative (Rev. January 2021), and Instructions for Form 2848 (Rev. September 2021). U.S. Department of the Treasury. Retrieved November 19, 2026 from https://www.irs.gov/pub/irs-pdf/f2848.pdf and https://www.irs.gov/instructions/i2848

[13] Aaron T. Gilbride. 2017. Investment Adviser Association, SEC Staff No-Action Letter (Feb. 21, 2017), Advisers Act Rule 206(4)-2, conditions 1, 4 and 5. U.S. Securities and Exchange Commission, Division of Investment Management. Retrieved November 19, 2026 from https://www.sec.gov/divisions/investment/noaction/2017/investment-adviser-association-022117-206-4.htm

[14] Norm Hardy. 1988. The Confused Deputy (or why capabilities might have been invented). ACM SIGOPS Operating Systems Review 22, 4 (Oct. 1988), 36–38. DOI: https://doi.org/10.1145/54289.871709

[15] National Conference of Commissioners on Uniform State Laws. 2006. Uniform Power of Attorney Act, with Prefatory Note and Comments. Retrieved November 19, 2026 from https://www.sos.ms.gov/content/documents/pol_res/power%20of%20attorney/5upoaa_final_may08.pdf

[16] U.S. Department of Veterans Affairs. 2023. VA Form 21-22: Appointment of Veterans Service Organization as Claimant's Representative (JUL 2023). Retrieved November 19, 2026 from https://www.vba.va.gov/pubs/forms/VBA-21-22-ARE.pdf

[17] U.S. Securities and Exchange Commission. 17 CFR §240.14a-4, Requirements as to proxy (Exchange Act Rule 14a-4). Electronic Code of Federal Regulations. Retrieved November 19, 2026 from https://www.ecfr.gov/current/title-17/section-240.14a-4

[18] Bürgerliches Gesetzbuch (German Civil Code), §181, Insichgeschäft. Retrieved November 19, 2026 from https://dejure.org/gesetze/BGB/181.html

[19] Meinhard v. Salmon, 249 N.Y. 458, 164 N.E. 545 (N.Y. 1928) (Cardozo, C.J.). Retrieved November 19, 2026 from https://static.case.law/ny/249/cases/0458-01.json

[20] Karl McGuinness. 2026. Mission-Bound Authorization for OAuth 2.0. Internet-Draft draft-mcguinness-oauth-mission-02 (Nov. 2, 2026). Work in progress. Retrieved November 19, 2026 from https://datatracker.ietf.org/doc/draft-mcguinness-oauth-mission/02/

[21] Dapeng Liu and Karl McGuinness. 2026. OAuth 2.0 Bounded Work Authorization. Internet-Draft draft-liu-mcguinness-oauth-bounded-work-00 (Oct. 17, 2026). Work in progress. Retrieved November 19, 2026 from https://datatracker.ietf.org/doc/draft-liu-mcguinness-oauth-bounded-work/00/

[22] Dick Hardt. 2026. AAuth Protocol. Internet-Draft draft-hardt-oauth-aauth-protocol-11 (Sept. 25, 2026). Work in progress. Retrieved November 19, 2026 from https://datatracker.ietf.org/doc/draft-hardt-oauth-aauth-protocol/11/

[23] Daniel Hardman. 2026. Canonical Quoted Text (CQT) 3.17. GitHub repository dhh1128/canonical-quoted-text. Retrieved November 19, 2026 from https://github.com/dhh1128/canonical-quoted-text

[24] California Probate Code §4406. Retrieved November 19, 2026 from https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=PROB&sectionNum=4406 (read through https://codes.findlaw.com/ca/probate-code/prob-sect-4406/).

[25] Moffatt v. Air Canada, 2024 BCCRT 149, para. 27 (B.C. Civil Resolution Tribunal, Feb. 14, 2024). Retrieved November 19, 2026 from https://canlii.ca/t/k2spq
