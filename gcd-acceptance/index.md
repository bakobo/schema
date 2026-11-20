## GCD Acceptance

A legal person accepts appointment under a [GCD](../gcd/), without qualification, and takes on the duties whose bearer is the delegate (`this.i` @8tpzdyl5). Agency is a relationship of mutual assent (Restatement (Third) of Agency §1.01). A GCD records only the principal's side of it, so this credential records the other side.

### Who issues it, and when

The acceptance is issued after the GCD by the GCD's `agentOfRecord`. A delegate that is a legal person acting for itself may name itself as its own agent of record, as a paid professional may, and then it accepts too; one that does not accepts by admitting the GCD and issues no acceptance (this.i @2fgsylgz). Its issuee `a.i` is the GCD's issuer, and its `gcd` edge names the GCD it accepts by its exact SAID, with the GCD 5.0.0 schema SAID pinned. `capacity` says which case applies: `agentOfRecord` for an agent that acts through a delegate other than itself, such as the operator of an AI delegate, and `delegate` for a delegate that chose to name itself as its own agent of record.

Under the GCD's `acceptance` rule, when the GCD names an agent of record, no act is authorized until that agent has issued an acceptance, and a verifier must deny an act for which none is shown. The agent's assent is therefore a precondition that a stranger can check open-loop. When a principal uses its own software as the delegate and names no agent of record, no acceptance is needed, because there is no agent to assent.

### Why it is a separate credential

An IPEX `admit` authenticates a key. It does not show a legal person's intent to be bound, and the key that admits a GCD may belong to software. Folding the acceptance into a combined offer credential would have the agent assent to terms before the principal had fixed the scope, so the acceptance comes after the grant and assents to the scope actually granted.

### What is deliberately absent

There is no field for conditions, reservations or a counter-offer, and the attribute section is closed. A qualified acceptance is no acceptance, so the schema gives one nowhere to go. The single rule, `unqualifiedAcceptance`, says the same in words, and records that the GCD's rules were available to the acceptor in full before it accepted.

### Schema

The schema is in [`gcd-acceptance.schema.json`](gcd-acceptance.schema.json), its rules in [`rules.json`](rules.json), an instance in [`example.json`](example.json) (Northstar Procurement accepting the GCD gallery's `ai-purchasing-agent`), a delegate accepting its own appointment in [`examples/real-estate-agent.json`](examples/real-estate-agent.json), and one fixture per defect in [`invalid/`](invalid).
