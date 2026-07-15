## Generalized Cooperative Delegation (GCD) Credentials

### Purpose

These credentials document the specifics of a KERI-style cooperative delegation.

The delegation relationship itself is not embodied in a credential, but rather in a special delegate AID that's bound to the delegator's AID via an inception event on the delegate side, and an interaction event in the KEL on the delegator side. See section 2.3.4 in [version 2.6 of the KERI whitepaper](https://github.com/SmithSamuelM/Papers/blob/master/whitepapers/KERI_WP_2.x.web.pdf). This interlocking two-way binding is what gives rise to the term "cooperative delegation", and it is significantly more secure and flexible than many other delegation mechanisms.

However, the binding between AIDs only proves the state of the delegation relationship, and defines how it is controlled. It does not specify which specific actions are expected of the delegate, or what constraints govern the exercise of the authority they receive. That is the purpose of the Generalized Cooperative Delegation (GCD) credentials described here. 

![suggested gcd visual](gcd-256.png)<br>
Suggested visual: [svg](gcd.svg) | [256 px](gcd-256.png) | [64 px](gcd-64.png) | [32 px](gcd-32.png)

### Types of authority

In the physical world, authority can be exercised in many modalities, and constraints often take advantage of these modalities. For example, a king might delegate to a treasurer access to the royal vault, and this delegation might take the form of a key that unlocks a door. In such cases, there could never be risk that the treasurer could sign a treaty that sends the kingdom to war, since the door and the treaty have different affordances.

In the digital world, authority may be asserted in many ways, but it is always proved by a digital signature. A delegate always signs something, whether it be a message in the [Trust-Spanning Protocol](https://trustoverip.org/blog/2023/08/31/mid-year-progress-report-on-the-toip-trust-spanning-protocol/), an SMS message, a purchase order, an XBRL report, etc. The fact that they've signed is easily verified; the question GCD credentials answer is whether the delegate had the authority to act in behalf of the delegator when they affixed that signature.

### Schema

See [gcd.schema.json](gcd.schema.json) and also [rules.json](rules.json).

### Constraints

Delegated authority may need to be constrained in many ways. For example, the talent agent for a famous rock 'n roll diva may be able to represent her, subject to constraints like these:

* The agent cannot represent her outside the context of the music business (can't vote on the diva's behalf in an election, can't sign their will, can't make medical decisions).
* The agent may only have authority to represent the diva in a particular geography or language or market.
* The agent's authority may be contingent on the agent remaining licensed by the industry.

GCD credentials allow the issuer to express analogous constraints. As of v2.0
these live inside the **`constraints` container** in the attributes block (the
enabling "may"). Each field is optional; an absent field means that dimension is
unconstrained. For example:

* `goals` constrains the goal-driven behaviors in which the delegate can engage on behalf of the delegator (e.g., to sign SMS messages, to buy, to sell, to schedule appointments...). *(v1 `c_goal`.)*
* `effects` constrains how an act may change the world — `observe`, `create`, `modify`, `preserve`, `destroy`. This is a *separate lock* from `goals`, so a read-only delegate holds `effects: ["observe"]` and cannot mutate even inside a permitted goal.
* `stateKinds` constrains what kind of state an act may touch — `information`, `record`, `commitment`, `authority`, `resource`, `relationship`.
* `domains` names the authorization domain(s) in which the delegated authority applies.
* `physGeos` constrains the locations in which a physically present delegate can exercise their delegated authority. *(v1 `c_pgeo`.)*
* `virtGeos` constrains where a potentially remote (virtually present) delegate can be located while exercising their delegated authority. *(v1 `c_rgeo`.)*
* `jurisdictions` constrains the legal jurisdictions in which the delegate can undertake actions with their delegated authority that legally bind the delegator (e.g., to sign a contract on the delegator's behalf). *(v1 `c_jur`.)*
* `icals` constrains the days and times, and possibly the URLs, in which the delegate can exercise their delegated authority (e.g., only when, in India's timezone, it is a Saturday or Sunday between midnight and noon, and only in a particular slack channel). *(v1 `c_ical`.)*
* `monetaryLimit` creates a ceiling for the financial stakes of the delegated action; that is, the delegate can act only in contexts where a financial value < N is at stake. Value is a string that contains a number followed by a space, then units: an ISO 4217 currency symbol, a three-letter cryptocurrency abbreviation, or another brief single-token symbol with obvious meaning: "25 CHF", "0.3 BTC", "4 OZ-XAU". This field is money-locked — it is not a general "stakes" quantity. *(v1 `c_upto`.)*
* `protos` constrains protocol+role combinations in which the delegate can exercise their delegated authority (e.g., the delegate is allowed to play the `getter` role in the `vtp` protocol). *(v1 `c_proto`.)*
* `proofs` identifies schemas for proof requests in the IPEX protocol; the delegate's authority depends on their ability to prove what the schema demands (e.g., a chauffeur is allowed to drive the delegator's limousine as long as they can prove they have a valid driver's license). *This constraint should not be confused with ACDC edges (chained credentials), which justify the delegator's status in the first place, and which are the SAIDs of concrete credentials rather than identifiers of schemas which could satisfy a constraint.* *(v1 `c_prove`.)*
* `validFrom` / `validUntil` bound the validity window as single absolute floor / ceiling. *(v1 `c_after` / `c_before`.)*
* `humanReview` carries free-text instructions that force human judgment; any GCD with this field MUST NOT be verified without a human. *(v1 `c_human`.)*

Two sibling axes sit alongside `constraints` in the attributes block:

* **`terminatingEvents`** — voiding polarity: proof-shaped attested events that *end* the authority when any one fires. A GCD that carries them MUST also carry `validUntil` as a hard backstop.
* **`disclosables`** — the outbound axis: the credential schemas a delegate MAY reveal about its principal.

The **`facet`** container carries relationship metadata — `role`, `relationType` (delegation / guardianship / controllership / stewardship), `liableParty` (who answers outward if it goes wrong), `presentsAs` (the facet-AID the act is presented under), and `exerciseMode` (`act` / `authorize` / `both`). The facet is descriptive; only `constraints` gates the authorization decision.

All fields inside `constraints` share these semantic rules:

1. Enforceable constraints live only inside the `constraints` container (or in the `role` field when `gfw` is defined). **Nothing outside `constraints` constrains**, and an unrecognized key *inside* `constraints` is **fail-closed** — a verifier that does not recognize it MUST deny. (This replaces v1's `c_`-prefix convention with a firmer subtree boundary; see the `noConstraintOutsideConstraints` rule.)
2. Each field MUST identify one or more values that are allowed (e.g., with a regex or an allow list). *Within a single field*, values are effectively ORed, meaning that any match is enough to satisfy that field. If the `jurisdictions` field says that valid jurisdictions are `["FR", "DE", "IN"]`, then the delegator authorizes the delegate to take legally binding actions if they are enforceable in France OR Germany OR India.
3. *Across all fields*, matches are ANDed, meaning that all of the constraints must be satisfied. Building on the previous example of `jurisdictions`, if the `virtGeos` field also says that valid locations for the remote delegate are `["FR", "DE", "IN"]`, then the delegate's actions are valid if they are legally enforceable in one of the 3 legal jurisdictions (first field), AND if the delegate appears to be operating from one of those same 3 countries (second field).

Because of the third rule, these credentials do not support graduated disclosure. All constraints must be disclosed every time a verifier is evaluating delegated authority.

### Governance Framework

These credentials are governed by rules to enhance assurance, discourage abuse, and keep use cases crisp. The current rules are stated in [rules.json](rules.json) and are identified by SAID `ENiUyBCG2MjCHa9djlgHiogd6uZHECc09ZELmQ3fEMzR`. Five are disclaimers (`noRoleSemanticsWithoutGfw`, `issuerNotResponsibleOutsideConstraints`, `noConstraintOutsideConstraints`, `useStdIfPossible`, `onlyDelegateHeldAuthority`).

In v2.0 the rules block also carries first-class **duties** (the "must"), each named by its `bearer`. A `bearer: delegate` duty is a structured obligation `{effect, goal, cadence?, priority}`; a `bearer: issuer` duty names a governance obligation `{rule, l?, priority}`. The baseline ruleset carries `timelyReviewAndRevoke` — the issuer's standing duty to review each delegation on a cadence appropriate to its stakes and to revoke or narrow it promptly once the conditions that justified the grant no longer hold (it does not extend authority; see this.i `@k3wm7d`). Voiding of an authority by an attested event is expressed with the `terminatingEvents` axis in the attributes block (this.i `@v5nq2r`).

New governance frameworks can be written that supplement these rules; see the `gfw` field in the schema. It is also possible to modify or override these rules, by placing a different value in the `r` field. The act of issuing or receiving a GCD credential constitutes binding acceptance of the rules.

