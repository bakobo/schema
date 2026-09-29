# IDEA: GCD 'designators' constraint -- whose designation of an act's TARGET the delegate may act on (principal only / holders of a credential of schema S / anyone); a credential-form defense against the confused deputy. Adopt only after tefa's designation-provenance work shows the rule is simple enough to standardize.
kind: idea
created: 2026-09-29T18:31Z

- 2026-09-29T18:32Z THE PROBLEM. A confused deputy uses its own authority on a target someone else chose (Hardy 1988: a compiler with write access to a billing file is told by a user to put debug output there, and overwrites it). 'Designation' is the capability-literature word for choosing which object an action applies to. A GCD grants a region of act-space (acts, domains, monetaryLimit, ...) and names no objects, so every GCD check passes when a stranger picks the target. Example: a steward may pay invoices up to 500 USD; an email says 'pay invoice 123 to account Y'. If the principal sent it, fine. If a supplier named its own account, that is business-email compromise, and the GCD still verifies. ZCAP avoids this by construction, because a zcap names its invocationTarget, but ZCAP verification is closed-loop (the root is synthesized by the target) and a GCD must stay open-loop.

THE IDEA. A new constraint, 'designators' (name coined here, not established), stating whose designations the delegate may act on: 'principal' (targets must come from the delegator itself), a list of schema SAIDs (the requester must hold a credential of that schema, for example an approved-vendor credential the principal issued), or 'any'. It mirrors 'proofs' from the other side: 'proofs' says what the DELEGATE must be able to prove; 'designators' says what the REQUESTER who named the target must be able to prove. For a stranger to check it, the signed act must carry evidence: an edge or reference to the signed request that named the target, plus the requester's qualifying credential. The counterparty (the bank, in the example) then confirms the requester satisfies the constraint.

PROS.
- It is the ocap move (authority travels with designation) in credential form, and it stays open-loop and stranger-verifiable, which ZCAP cannot be.
- It lets the delegator bound the most common real-world agent fraud (a legitimate action aimed at an attacker-chosen target) without enumerating targets in the grant, so there is no reissuance churn when targets change.
- It composes with existing fields and with proofs; the credential-of-schema-S form reuses machinery that already exists.
- Absence keeps today's meaning (unconstrained), so existing GCDs are unaffected.

CONS.
- Evidence weight and privacy: every act carries the designating request, so the requester's identity and the request itself leak to the counterparty. This fights the minimization the rest of the ACDC stack cares about.
- Uneven meaning: crisp for acts with a target named by someone else (payee, recipient, file) and vacuous for duty-driven acts whose target is fixed by the grant (publish the Friday newsletter). 'Target' is not yet defined over the effect x state-kind act grid, and it would have to be.
- Fail-closed cost: any verifier that does not know the key MUST deny, so issuing it breaks every existing verifier for that credential until they upgrade. That is correct behaviour but makes adoption expensive.
- Designation chains: when the requester was itself relaying someone else's designation, the evidence becomes a chain, and the verifier needs a rule for how deep to follow it. That is unsolved.
- It can be satisfied by a colluding designator who holds the credential; it narrows who may designate, not whether their designation is honest.

WHERE IT CAME FROM. Comparison of GCD with W3C CCG ZCAP (Harrison Tang, 'Agentic Identity & Access Management', CCG call 2026-09-29, slides 17-20), in a bakobo/tefa session. tefa is building the internal version first (designation provenance checked by the executive and the mint); this tick should be revisited with what that work learns about whether the rule is simple and uniform enough to standardize.
