## Generalized Cooperative Delegation (GCD) Credentials

### Purpose

These credentials document the authorizations, constraints, and duties of **delegated authority** — what a delegate is empowered to do on behalf of a delegator, and under what limits.

The paradigmatic and strongest way to bind a delegate to a delegator is a KERI-style [9] **cooperative delegation**: a special delegate AID bound to the delegator's AID via an inception event (`dip`) on the delegate side, and an interaction event (`ixn`) in the KEL on the delegator side. See section 2.3.4 in [version 2.6 of the KERI whitepaper](https://github.com/SmithSamuelM/Papers/blob/master/whitepapers/KERI_WP_2.x.web.pdf). This interlocking two-way binding is what gives rise to the term "cooperative delegation", and it is significantly more secure and flexible than many other delegation mechanisms. It remains fully supported and is the exemplar these credentials were named for.

**But it is not a precondition.** A GCD credential is a standard targeted ACDC [10]; its authorization and constraint mechanics do not depend on the issuee being KEL-anchored to the issuer. It is usable whenever an issuer grants constrained authority to a delegate AID, whether or not that delegate is cooperatively delegated from the issuer — for example, an organization authorizing an independently-controlled role AID to act on its behalf. (This is what "**Generalized** Cooperative Delegation" implies.)

Whichever binding is used, it only proves the *state* of the delegation relationship and defines how it is controlled. It does not specify which specific actions are expected of the delegate, or what constraints govern the exercise of the authority they receive. That is the purpose of the Generalized Cooperative Delegation (GCD) credentials described here. 

![suggested gcd visual](gcd-256.png)<br>
Suggested visual: [svg](gcd.svg) | [256 px](gcd-256.png) | [64 px](gcd-64.png) | [32 px](gcd-32.png)

### Human and AI delegates

A delegate may be a person, an organization, or software, and GCD treats all three as ordinary cases. Much delegation is not a legal matter at all. A person inside an organization may let an AI assistant accept meetings in their name and expect colleagues to honor its replies; a manager may hand a colleague an approval queue for a week. GCD is meant to be comfortable for that, as well as for a power of attorney.

It offers two paths. On the light path the issuer names no `agentOfRecord`. The delegate is then either the principal's own software, for which the principal answers as it would for any tool, or a person or organization that answers for itself and accepts the delegation by admitting the credential. Nothing more is required: no extra credential and no extra check for the verifier. [exec-assistant-ai](examples/exec-assistant-ai.json), [platform-manager](examples/platform-manager.json) and [ai-deploy-agent](examples/ai-deploy-agent.json) take this path.

The heavy path applies when a third party operates the delegate, as an AI vendor operates the purchasing agent in [ai-purchasing-agent](examples/ai-purchasing-agent.json), which encodes the one-sentence grant from Greenwood's study of authorization instruments [1]. The operator is named as `agentOfRecord`, discloses its compensation and conflicts in a [gcd-disclosure](../gcd-disclosure/) before the grant, and accepts the grant afterwards in a [gcd-acceptance](../gcd-acceptance/) that verifiers require before any act. A professional acting for itself, such as a realtor, may also choose this path to put its disclosure on record. Software is never an agent in the legal sense [8], which is why the heavy path names the legal person behind it. The reasons for this split, and for the rest of 5.0.0, are in [The legal grounding of GCD](legal-grounding.md).

### Types of authority

In the physical world, authority can be exercised in many modalities, and constraints often take advantage of these modalities. For example, a king might delegate to a treasurer access to the royal vault, and this delegation might take the form of a key that unlocks a door. In such cases, there could never be risk that the treasurer could sign a treaty that sends the kingdom to war, since the door and the treaty have different affordances.

In the digital world, authority may be asserted in many ways, but it is always proved by a digital signature. A delegate always signs something, whether it be a message in the [Trust-Spanning Protocol](https://trustoverip.org/blog/2023/08/31/mid-year-progress-report-on-the-toip-trust-spanning-protocol/), an SMS message, a purchase order, an XBRL report, etc. The fact that they've signed is easily verified; the question GCD credentials answer is whether the delegate had the authority to act in behalf of the delegator when they affixed that signature.

### Schema

See [gcd.schema.json](gcd.schema.json) and also [rules.json](rules.json).

Version 5.0 grounds the credential in agency law (this.i `@3w3rkmt3` and its children, including `@2fgsylgz` on the light path). The facet names roles instead of liability: `liableParty` is gone, `principal` names the party bound by the delegate's authorized acts (the issuer by default) and `agentOfRecord` names a legal person who acts through the delegate. The facet also gains `durable` and `grantText`, the latter a cqt3.17 digest of the words the principal approved, and it is now closed. A `reservedPowers` constraint confers dangerous powers only by name, and `reviewers` names who may sign a human-review approval. Two companion credentials, [gcd-disclosure](../gcd-disclosure/) and [gcd-acceptance](../gcd-acceptance/), carry an agent of record's disclosure before the grant and its acceptance after it. New optional edges are `parent` (sub-delegation), `disclosure` and `execution` (evidence of how the grant was made). The rules block was rewritten and is now complete: it supersedes every earlier clause, and one clause, `machineGate`, lists everything a verifier checks. These changes went through three rounds of adversarial review; see [The legal grounding of GCD](legal-grounding.md). Version 4.0.0 remains published at [gcd-4.0.0](../gcd-4.0.0/gcd-4.0.0.schema.json).

Version 4.0 added **`targets`** to the `constraints` container (this.i `@yivcussv`): the objects a delegate may act on, or whose designation of them the delegate may act on. It closes the confused-deputy gap, where a stranger chooses where the delegate's authority lands. `acts` and `targets` are one constraint, so a credential that carries `acts` must also carry `targets`, which is why this is a MAJOR version. See [Targets and the confused deputy](#targets-and-the-confused-deputy) below.

Version 3.1 admits **custom keys** inside the `constraints` container and inside
a duty (this.i `@vy7qoj`), so an issuer can express a constraint or an obligation
the standard fields do not cover. The fail-closed rule on an unrecognized
constraint key is unchanged in substance — it is now an obligation on the
verifier rather than something schema validation enforces. See
[Constraints](#constraints) below.

Version 3.0 adopts the **ACDC v2 envelope** (this.i `@enr3eg`): credentials are
`acm`/JSON messages whose top-level fields appear in the order
`[v, t, d, u, i, rd, s, a, e, r]`, with SAIDs computed by the v2
most-compact-form algorithm. `rd` (the SAID of the issuer's credential-status
registry inception) replaces v1's `ri` and is **required** — the ACDC spec makes
`rd` optional for correlation minimization, but a GCD is authority evidence, so
secure discovery of its revocation registry wins here. `t` is optional (a JSON
ACDC without it is of type `acm`), and the attribute block's `d` is optional
(the reference v2 builder emits none; a `d`-less attribute section simply cannot
be compacted). Earlier versions remain published and resolvable by their
original SAIDs: [gcd-4.0.0](../gcd-4.0.0/gcd-4.0.0.schema.json) (4.0 before the legal-grounding refresh), [gcd-3.1.0](../gcd-3.1.0/gcd-3.1.0.schema.json) (3.1 without `targets`), [gcd-2.0.1](../gcd-2.0.1/gcd-2.0.1.schema.json) (the same
semantic content on the v1 envelope) and
[gcd-1.0.0](../gcd-1.0.0/gcd-1.0.0.schema.json) (the pre-SDA `c_*` model).

### Constraints

Delegated authority may need to be constrained in many ways. For example, the talent agent for a famous rock 'n roll diva may be able to represent her, subject to constraints like these:

* The agent cannot represent her outside the context of the music business (can't vote on the diva's behalf in an election, can't sign their will, can't make medical decisions).
* The agent may only have authority to represent the diva in a particular geography or language or market.
* The agent's authority may be contingent on the agent remaining licensed by the industry.

GCD credentials allow the issuer to express analogous constraints. These
live inside the **`constraints` container** in the attributes block (the
enabling "may"). Each field is optional; an absent field means that dimension is
unconstrained. For example:

* `goals` constrains the goal-driven behaviors in which the delegate can engage on behalf of the delegator (e.g., to sign SMS messages, to buy, to sell, to schedule appointments...).
* `acts` names the **(effect, state-kind) points** the delegate may act on — the enabling "may" over the act grid. An act is located by its *effect* (`observe`, `create`, `modify`, `preserve`, `destroy`) over a *kind of state* (`info`, `record`, `commitment`, `authority`, `resource`, `relationship`); these are the two axes of one coordinate, and **neither is meaningful alone** — "create" is create *what*, "commitment" is do *what* to it. Each entry is a point written `effect state-kind` (e.g. `create commitment`), or a one-sided brace enumeration — `observe {info, record}` (one effect, several kinds) or `{create, modify} record` (several effects, one kind). An act is authorized only if **every** point it occupies is covered (filing a return is `create record` *and* `create commitment` in one move). The **gate** an act must clear (auto / rule / human) is *derived* per act from its points and its target via the governance framework (`gfw`) — not enumerated here. A pure delegator (`exerciseMode: authorize`) omits `acts` entirely, having an empty act surface. A credential that carries `acts` must also carry `targets`.
* `targets` names the **objects** acts may land on: specific accounts, identifiers or documents chosen by the principal, or the parties whose choice of target the delegate may act on. It is the third coordinate of an act, alongside effect and state-kind. See [Targets and the confused deputy](#targets-and-the-confused-deputy).
* `domains` names the authorization domain(s) in which the delegated authority applies.
* `physGeos` constrains the locations in which a physically present delegate can exercise their delegated authority.
* `virtGeos` constrains where a potentially remote (virtually present) delegate can be located while exercising their delegated authority.
* `jurisdictions` constrains the legal jurisdictions in which the delegate can undertake actions with their delegated authority that legally bind the delegator (e.g., to sign a contract on the delegator's behalf).
* `icals` constrains the days and times, and possibly the URLs, in which the delegate can exercise their delegated authority (e.g., only when, in India's timezone, it is a Saturday or Sunday between midnight and noon, and only in a particular slack channel).
* `monetaryLimit` creates a ceiling for the financial stakes of the delegated action; that is, the delegate can act only in contexts where a financial value < N is at stake. Value is a string that contains a number followed by a space, then units: an ISO 4217 currency symbol, a three-letter cryptocurrency abbreviation, or another brief single-token symbol with obvious meaning: "25 CHF", "0.3 BTC", "4 OZ-XAU". This field is money-locked — it is not a general "stakes" quantity.
* `protos` constrains protocol+role combinations in which the delegate can exercise their delegated authority (e.g., the delegate is allowed to play the `getter` role in the `vtp` protocol).
* `proofs` identifies schemas for proof requests in the IPEX protocol; the delegate's authority depends on their ability to prove what the schema demands (e.g., a chauffeur is allowed to drive the delegator's limousine as long as they can prove they have a valid driver's license). *This constraint should not be confused with ACDC edges (chained credentials), which justify the delegator's status in the first place, and which are the SAIDs of concrete credentials rather than identifiers of schemas which could satisfy a constraint.*
* `validFrom` / `validUntil` bound the validity window as single absolute floor / ceiling.
* `humanReview` carries free-text instructions for acts that need human judgment. It requires `reviewers`, and an act passes only with an approval that identifies it and is signed by a reviewer that field names or qualifies. What makes the review real (authority to refuse, access to the evidence, time to consider) is a duty, not something a verifier can check.
* `reviewers` names who may sign those approvals: specific AIDs, or anyone who satisfies a proof request.
* `reservedPowers` lists the reserved powers this grant confers, from a closed vocabulary: `substitute`, `redirectNotice`, `selfDeal`, `gift`, `trust`, `survivorship`, `beneficiary`, `waiveAnnuity`, `fiduciaryPowers`, `disclaim`. A reserved power is never implied by the breadth of a grant, a role, a governance framework, an approval, or a missing field, so absent this field none is granted. Eight codes follow the hot powers of the Uniform Power of Attorney Act §201(a); the principal narrowing or revoking its own grant is never one.

Two sibling axes sit alongside `constraints` in the attributes block:

* **`terminatingEvents`** — voiding polarity: proof-shaped attested events that *end* the authority when any one fires. A GCD that carries them MUST also carry `validUntil` as a hard backstop.
* **`disclosables`** — the outbound axis: the credential schemas a delegate MAY reveal about its principal.

The `facet` container carries relationship metadata: `role`; `relationType` (delegation, guardianship, controllership or stewardship [6]); `principal`, the party bound by the delegate's authorized acts and on whose account they are taken, set only when it differs from the issuer; `agentOfRecord`, the legal person the principal appoints and who acts through the delegate, absent on the light path; `presentsAs`, the facet-AID the act is presented under [5]; `exerciseMode` (act, authorize or both); `durable`, the principal's stated intent that the authority survive its incapacity, whose effect is for the governing law; and `grantText`, a cqt3.17 digest of the words the principal approved, with who drafted them. The model behind the facet and the act grid is described in [2], drawing on [3] and [4]. The facet names roles and leaves liability to the law, which is why 4.0's `liableParty` is gone. It is closed, and except where `agentOfRecord` brings acceptance into play, it does not gate.

All fields inside `constraints` share these semantic rules:

1. The `constraints` container is the machine gate, together with the few conditions the `machineGate` rule lists (acceptance, ancestors, human-review approvals, terminating events). An unrecognized key *inside* `constraints` is **fail-closed**: a verifier that does not recognize it MUST deny. Other rules may limit authority in law, but they add nothing a verifier checks. (See the `machineGate` rule.)
2. Each field MUST identify one or more values that are allowed (e.g., with a regex or an allow list). *Within a single field*, values are effectively ORed, meaning that any match is enough to satisfy that field. If the `jurisdictions` field says that valid jurisdictions are `["FR", "DE", "IN"]`, then the delegator authorizes the delegate to take legally binding actions if they are enforceable in France OR Germany OR India.
3. *Across all fields*, matches are ANDed, meaning that all of the constraints must be satisfied. Building on the previous example of `jurisdictions`, if the `virtGeos` field also says that valid locations for the remote delegate are `["FR", "DE", "IN"]`, then the delegate's actions are valid if they are legally enforceable in one of the 3 legal jurisdictions (first field), AND if the delegate appears to be operating from one of those same 3 countries (second field).

Because of the third rule, these credentials do not support graduated disclosure. All constraints must be disclosed every time a verifier is evaluating delegated authority.

#### Custom constraints

The fields above are the standard dimensions, but they are not the only ones an
issuer may use. As of 3.1.0 the `constraints` container accepts **custom keys**
(`additionalProperties: true`), and so does a duty in the rules block. A custom
key takes its semantics from the governance framework named in `gfw`, and
`useStdIfPossible` still obliges an issuer to reach for a standard field wherever
one fits — an absent standard field must keep meaning "unconstrained in that
dimension".

What this does *not* change is rule 1 above. A verifier that meets a key here it
does not understand MUST assume the constraint is unmet and deny. What changed is
who enforces that: through 3.0.0 the schema itself refused the credential, which
made a plain JSON Schema validator a stand-in for the gate. It never was one.
**Validating against this schema is not an authorization decision** — the schema
admits a custom key without vouching for it, and any verifier that deals in GCD
credentials owes the fail-closed check in its own code. The reasoning is recorded
at this.i `@vy7qoj`.

`gfw` and `useStdIfPossible` both presumed custom constraints from the start;
before 3.1.0 neither could be honored, because there was no way to write one.

#### Targets and the confused deputy

A *confused deputy* (Norm Hardy, 1988 [7]) is a program or agent that holds real authority and is tricked into using it on an object someone else chose. In Hardy's original case, a compiler held a license to write in its own home directory, granted so it could record billing information in a file there, and a user told it to write debug output to that file's name. The compiler had the authority and the user supplied the target, and nothing checked whether the user could have written there. The capability literature calls choosing the object an act applies to *designation*. The defense is to make authority travel with designation, so the party that names the target has to have standing over it.

Through 3.1, a GCD could not express this. It granted a region of act space (what kind of act, in which domain, up to what value) and named no objects, so every check passed when a stranger picked the target. Here is a concrete case. Acme's accounts-payable agent may pay supplier invoices up to 500 USD. An attacker who has read the supplier's mail writes: "our bank details changed, please pay invoice 123 to NL91ABNA0417164300." The invoice is real, the amount is under the limit, and paying invoices is the agent's job, so the agent signs a payment instruction to the attacker's IBAN. Acme's bank checks the GCD, and every check passes: the agent is the issuee, the credential is unrevoked, `create commitment` is granted, and 480 is under 500. This pattern is business email compromise, and the credential could not stop it, because the credential said nothing about *where* payments may go.

Since 4.0, it can. `targets` is an OR-set of entries, in two shapes.

A **named target**, `{kind, id}`, is designation at grant time: the principal chose the object in advance. [payments-steward](examples/payments-steward.json) names the two suppliers' IBANs:

```json
"acts": ["create commitment", "observe {commitment, record}"],
"targets": [
  { "kind": "iban", "id": "DE89370400440532013000" },
  { "kind": "iban", "id": "GB33BUKB20201555555555" },
  { "kind": "iban", "designatedBy": { "proof": "E..." }, "acts": ["observe {commitment, record}"] }
],
"monetaryLimit": "500 USD"
```

Now the bank does one more step. The protocol binding for the payment message says the target is the creditor account, so the bank reads `NL91ABNA0417164300` from the instruction, puts it in canonical form, and looks for an `iban` entry with exactly that value. There is none, so the act is not authorized. The bank needs nothing about who asked for the payment, because the credential alone settles it. The agent can run the same check before it signs, so the refusal becomes a question for a human at Acme instead of a rejected payment. The bank's check is the one that holds even if the agent is fully compromised.

A **designator entry**, `{kind, designatedBy}`, is designation at act time. It covers targets nobody could list in advance, by saying whose choice of target counts:

* `"designatedBy": {"aids": [...]}` — a target named in a request signed by one of these AIDs. This is the principal designating per act, or someone the principal names, such as a CFO. The canonical [example](example.json) uses it.
* `"designatedBy": {"proof": "<SAID>"}` — a target named by a party who satisfies that proof request, for example a supplier holding an approved-vendor credential Acme issued. In payments-steward such a supplier can point the agent at its invoices to *look* at (`observe`), but cannot direct a payment, because the entry's `acts` narrows it. The proof request is the same kind of object `proofs` references: an IPEX `apply` payload plus the acceptable issuers, and a requirement that the presented credential be targeted and presented by its issuee.
* `"designatedBy": "any"` — anyone's designation. This is the most permissive stance, and it is never a default: an issuer who means it must say so. [guardian-of-minor](examples/guardian-of-minor.json) does, because a guardian acts on targets that schools and doctors name, under `humanReview`.

For a designator entry, the act must carry the signed request that named the target, so the verifier learns who designated it. That disclosure is the price of designation at act time, and an issuer who uses only named targets never pays it. The designator must have signed the request itself; a designation relayed through someone else does not count.

The rules that make this hold:

1. `acts` and `targets` are **one constraint**, act space located by effect, state-kind and target. With neither present, act space is unconstrained, as with any absent field. With `targets` alone, any act is allowed, but only on those targets. `acts` without `targets` is invalid, so an issuer who limits what kind of act may be done must also say on what.
2. An entry's own `acts` only **narrows**. An act on that entry's targets must be covered by the entry's `acts`, and also by the top-level `acts` when that is present. With no top-level `acts`, the entry's `acts` narrows an act space that is otherwise unconstrained.
3. Matching is **exact over a canonical form** defined per kind. A loose comparison (case folding, stray spaces, look-alike characters) is a bypass. The standard kinds are `aid` and `said` (a qb64 identifier, by equality) and `iban` (ISO 13616 electronic format, by equality; the verifier also checks the check digits, which a schema cannot). A governance framework may define more, as [ai-deploy-agent](examples/ai-deploy-agent.json) does with `acme.deploy-service`. `url` and `path` are deliberately absent, because their containment is prefix-shaped and canonicalizing them is where bypasses live.
4. It **fails closed**. A target whose kind no entry names matches nothing. An entry whose kind the verifier does not know matches nothing. A verifier that finds no entry containing the act's target MUST deny. A wildcard kind (`"*"`) is allowed only on a designator entry, so it can never stand in for a named object.
5. An act whose target the grant itself fixes, such as a duty to publish a weekly newsletter, has no designated target. It passes only where the governance framework or the protocol binding says that kind of act carries no target. Otherwise the verifier finds nothing to check, and denies.

What `targets` does not stop: an attacker who gets the agent to pay a fake invoice to a supplier's *real* account. That attacks the payload (what is paid, and why), not the target, and other constraints have to own it. It also does not make a qualifying designator honest; it narrows who may designate, not whether a designation is truthful. And a named target has a cost: when a supplier really does change banks, the principal must reissue the credential. For bank-detail fraud that cost is the point. The standard defense is to confirm a changed bank detail through a separate channel, and reissuance forces that confirmation through the one party with standing to make it.

Every verifier sees the whole target list, because constraints are disclosed together (see the third rule above). An issuer who would rather not reveal its full list of suppliers to every bank should weigh designator entries against named ones.

### Governance Framework

The rules block is a Ricardian contract: terms carried inside the credential and identified by SAID. The baseline is [rules.json](rules.json). In 5.0.0 it is complete and supersedes every earlier version, so no 4.0 clause survives into a 5.0 credential. It separates three jobs that earlier versions mixed together.

The machine gate is one clause, `machineGate`, which lists every condition a verifier checks and says the list is exhaustive. Binding follows signatures: the issuer is bound by issuing, an agent of record by its acceptance, a delegate that is a person or organization by admitting the credential, and anyone who controls the delegate with notice of the rules by that conduct. A relying party is bound only by an agreement it makes separately; for everyone else, the clauses about reliance state conditions, not obligations. Within its constraints, the credential is the issuer's representation, made for the principal, of the delegate's authority; outside them it is no evidence of authority.

The other clauses cover reserved powers, sub-delegation (a child's authority is the intersection of its ancestors', and the parent must grant `substitute`), acceptance and disclosure, termination (deferred to the governing law, with `terminatingEvents`, revocation and `validUntil` as what a verifier sees), human review, the status of the grant text, an optional governing law that never displaces mandatory protections, a savings clause for mandatory law, what the delegate warrants, and how conflicting duties resolve.

Duties are the "must". A `bearer: issuer` duty names a governance obligation `{rule, l, priority}`; a `bearer: delegate` duty is either structured `{effect, goal, cadence?, priority}` or, since 5.0.0, a prose legal duty `{rule, l, priority}`. The baseline carries the issuer's `timelyReviewAndRevoke` and six delegate duties: `actWithinScope`, `loyalty`, `care`, `confidentiality`, `keepRecords` and `escalate`. Delegate duties are owed by the agent of record, or on the light path by a delegate that is a legal person; software owes nothing, and when the principal deploys its own software, the principal answers for it. A conflict that involves loyalty, confidentiality or escalate is referred to the principal, never resolved by priority. Since 3.1.0 a duty may carry custom keys defined by the framework named in `gfw`.

A governance framework named in `gfw` may give `role` meaning and define custom constraints, but it may only narrow the authority the constraints grant, never widen it. [The legal grounding of GCD](legal-grounding.md) explains each clause and its sources.

### Companion credentials

[gcd-disclosure](../gcd-disclosure/) is issued by a would-be agent of record to the principal before the grant. It states the compensation the agent expects from anyone and its material conflicts, and the GCD references it in its `disclosure` edge, so issuing the grant is evidence of consent to exactly that disclosure. [gcd-acceptance](../gcd-acceptance/) is issued by the agent of record after the grant. It names the GCD exactly and accepts it without qualification, and a verifier requires it before any act whenever `agentOfRecord` is present. Neither is needed on the light path.

### Worked examples

The canonical [`example.json`](example.json) is a minimal valid instance. The [`examples/`](examples/) gallery covers the feature set across eleven scenarios, from in-house delegation to a durable power of attorney. Each is a full, SAID-minted credential that the conformance linter validates (schema validity, `s` against `$id`, and SAID self-consistency), so none can drift silently.

| Example | Path | relationType / exerciseMode | Highlights |
|---|---|---|---|
| [exec-assistant-ai](examples/exec-assistant-ai.json) | light | delegation / act | a person's own AI assistant, honored by colleagues: `presentsAs` the person's office, targets designated by holders of an employee credential, no agent of record |
| [platform-manager](examples/platform-manager.json) | light | stewardship / authorize | the pure delegator, an employee: no `goals` or `acts`, `domains`, and `reservedPowers: ["substitute"]` so it can sub-delegate |
| [sub-delegated-assistant](examples/sub-delegated-assistant.json) | light | delegation / act | a `parent` edge to platform-manager's grant, with constraints inside it |
| [ai-deploy-agent](examples/ai-deploy-agent.json) | light | delegation / act | the organization's own software: no-`destroy` acts, a kill-switch `terminatingEvent`, `humanReview` with `reviewers` for production, and the custom constraint `maxDeploysPerDay` |
| [payments-steward](examples/payments-steward.json) | light | delegation / act | the confused-deputy defense: named `iban` targets, plus a `proof` designator narrowed to `observe` |
| [tax-information-reader](examples/tax-information-reader.json) | light | delegation / act | information only, the analogue of IRS Form 8821: every act is an `observe` point |
| [guardian-of-minor](examples/guardian-of-minor.json) | light | guardianship / both | a court-appointed guardian: `principal` names the person under guardianship, an `execution` edge, `terminatingEvents` with a `validUntil` backstop, `disclosables` |
| [ai-purchasing-agent](examples/ai-purchasing-agent.json) | heavy | delegation / act | Greenwood's one-sentence grant: an AI vendor as `agentOfRecord`, a `grantText` digest, one named merchant, `monetaryLimit: "400 USD"`, a completion `terminatingEvent`, a `disclosure` edge; its acceptance is [gcd-acceptance/example.json](../gcd-acceptance/example.json) |
| [real-estate-agent](examples/real-estate-agent.json) | heavy | delegation / act | a realtor naming itself as agent of record: `jurisdictions`, `physGeos`, a license `proof`, properties designated by the seller |
| [iot-fleet-controller](examples/iot-fleet-controller.json) | heavy | controllership / both | a vendor operating devices: `icals` maintenance windows, `virtGeos`, `protos`, the devices as `aid` targets |
| [durable-financial-poa](examples/durable-financial-poa.json) | heavy | delegation / act | `durable: true`, an `execution` edge to a notarization, a death `terminatingEvent`, a governing law, and `reservedPowers: ["substitute"]` granted by name |

The [`invalid/`](invalid/) corpus holds the should-reject fixtures, each the canonical example one mutation away from valid. 5.0.0 added fixtures for a `liableParty` in the closed facet, a 4.0 rule key, a missing baseline duty, a delegate duty with both `effect` and `rule` or a prose duty without `l`, `agentOfRecord` without a `disclosure` edge, `humanReview` without `reviewers`, an unknown reserved-power code, a `parent` edge with the wrong operator, a non-boolean `durable`, a `grantText` with the wrong canonicalization or a malformed digest, and an unknown governing-law code. The older fixtures were re-pointed at the new schema so each still fails for its own defect and no other.

### References

[1] Dazza Greenwood. 2026. Written Agent Authorizations: 25 Instruments, Dissected for AI-Agent Design. Version 0.3.4. GitHub repository dazzaji/agent4whom, commit 8df8730. https://github.com/dazzaji/agent4whom/tree/8df8730

[2] Daniel Hardman. 2026. The Shape of Delegated Authority. Version 1.3. Codecraft Papers. https://dhh1128.github.io/papers/sda.html

[3] Daniel Hardman. 2025. Intent and Boundaries: A Framework for Digital Agency. Version 1.1. Codecraft Papers. DOI: https://doi.org/10.2139/ssrn.5909382

[4] Daniel Hardman. 2025. Syntelos: A Hierarchical Taxonomy of Intent in Digital Interactions. Version 1.1. Codecraft Papers. https://dhh1128.github.io/papers/syntelos.html

[5] Daniel Hardman. 2026. Identity Facets. Version 0.11. Codecraft Papers. https://dhh1128.github.io/papers/if.html

[6] Hyperledger Aries. RFC 0103: Indirect Identity Control. https://identity.foundation/aries-rfcs/latest/concepts/0103-indirect-identity-control/

[7] Norm Hardy. 1988. The Confused Deputy (or why capabilities might have been invented). ACM SIGOPS Operating Systems Review 22, 4 (Oct. 1988), 36–38. DOI: https://doi.org/10.1145/54289.871709

[8] Deborah A. DeMott. 2026. When Agentic AI Met the Common Law of Agency. Harvard Journal of Law & Technology (forthcoming). DOI: https://doi.org/10.2139/ssrn.6838660

[9] Samuel M. Smith. Key Event Receipt Infrastructure (KERI). Trust over IP Foundation. https://trustoverip.github.io/kswg-keri-specification/

[10] Samuel M. Smith. Authentic Chained Data Containers (ACDC). Trust over IP Foundation. https://trustoverip.github.io/kswg-acdc-specification/

The legal and regulatory sources behind 5.0.0 are cited in [The legal grounding of GCD](legal-grounding.md).
