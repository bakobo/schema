## GCD Disclosure

A would-be agent of record tells the principal, before any [GCD](../gcd/) exists, all the compensation it expects from any party and every material conflict of interest it has in acting for the principal. A GCD that names an `agentOfRecord` must point at that agent's disclosure through its `disclosure` edge, and issuing the GCD is evidence of the principal's consent to exactly what the disclosure states and to nothing else (`this.i` @8tpzdyl5). A conflict or compensation that arises later is not consented to until the agent discloses it and the principal approves, and the disclosure's one rule commits the agent to disclose any change before acting on it. A principal can consent to a conflict only after it has been disclosed (Restatement (Third) of Agency §8.06), which is why the disclosure comes before the grant and is a credential of its own rather than part of the acceptance that follows it.

### Issuer and issuee

The issuer `i` is the party that will be named as `agentOfRecord` in the GCD; a delegate that is a legal person acting for itself discloses too when it chooses to name itself as its own agent of record, and otherwise issues no disclosure (this.i @2fgsylgz). The issuee `a.i` is the principal. That is the GCD's issuer unless the GCD sets `principal`, as when a court appoints a guardian, so the GCD's `disclosure` edge uses the operator `NI2I` and a verifier checks both parties against the GCD's facet.

### What it says

| attribute | meaning |
|---|---|
| `dt` | when the disclosure was made; the GCD that references it is issued later |
| `compensation` | each payment or benefit the issuer expects, as `{payer, basis}`: who pays (an AID where the payer has one, otherwise a name) and what is paid, in plain words |
| `conflicts` | each material conflict of interest, one per entry, in plain words |

Either list may be absent, which says the issuer expects no compensation or has no conflict, but not both: a disclosure that states nothing is not one. The single rule, `completeDisclosure`, makes the issuer answer for completeness and for disclosing any change.

### Why it uses selective disclosure

A disclosure is not a constraint credential. No verifier gates an act on it, and it is addressed to the principal. Who pays an agent, and how much, is the principal's business and the agent's, and publishing it to every verifier who checks a GCD would be a privacy harm. So the attribute section carries a required salty nonce (`a.u`, at least a CESR 128-bit salt) and can travel compacted to its SAID. A verifier that follows a GCD's `disclosure` edge learns that a disclosure was made and can confirm it was this one, without seeing what it says. The principal can show the expanded form to anyone it chooses.

It is an attribute section rather than an aggregate, following [Choosing attribute vs aggregate](../docs/choosing-attribute-vs-aggregate.md): the fields are a fixed, heterogeneous set whose labels leak nothing.

### Schema

The schema is in [`gcd-disclosure.schema.json`](gcd-disclosure.schema.json), its rules in [`rules.json`](rules.json), an instance in [`example.json`](example.json) (the disclosure behind the GCD gallery's `ai-purchasing-agent`), the disclosures behind the other GCD examples that name an agent of record in [`examples/`](examples), and one fixture per defect in [`invalid/`](invalid).
