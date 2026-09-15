## Awards

### Purpose
This type of verifiable data embodies official praise of the issuee by an issuer. Usually, the issuer is an organization, and the recipient is an individual (e.g., a staff member). However, the schema and use cases are flexible &mdash; an individual can give another individual an award, and an organization can give an award to someone other than an employee. Awards do not necessarily confer privileges (and thus, are unlike most credentials). However, they do prove that the recipient received a formal recognition. A particular verifier can decide to confer privileges based on the award, if they wish.

### Suggested visual
As a general category, awards might be visualized like this: 

![suggested award visual](award-256.png)<br>
[1024 px](award-1024.png) | [256 px](award-256.png) | [64 px](award-64.png) | [32 px](award-32.png)

However, each instance of an award supports inclusion of a unique image -- or subcategories can be defined that all share a common visual representation.

### Schema

The schema is in [`award.schema.json`](award.schema.json), a recommended baseline ruleset in [`rules.json`](rules.json), and a SAID-verified instance in [`example.json`](example.json). The [`invalid/`](invalid) directory holds the should-reject corpus.

Some notable features:

* Awards can have an optional `category` (a Nobel prize, specifically in the *literature* category).
* Awards can have an optional `timeframe` (an employee-of-the-month award, specifically for July 2026).
* The `details` block can carry an optional `citation` — formal praise designed to be displayed and quoted, such as "For running the 2024 Olympic Marathon in Paris in 2:01:03".
* The `details` block can carry an optional `image`: a data URL, an ordinary URL, or a digest. An ordinary URL commits the issuer to a location rather than to specific content.
* The edges section is optional. If present it carries an `issuer` edge to a credential of any type; a vLEI credential is recommended where one exists.

`issuerName` and `issueeName` are conveniences for human readers. They are self-asserted, carry no verification weight, and the baseline ruleset says a verifier that matches on a name rather than an AID has matched on nothing.

### Graduated disclosure

Recipients generally want to share an award broadly, since it enhances their public reputation. But an award may carry the recipient's name, and the recipient may want to prove the award before proving the name: "I will comment on this policy question as a recipient of a Nobel prize in economics, but I don't want to be quoted by name." A citation can be identifying, embarrassing or simply irrelevant in some contexts, and an image carried as a data URL can make the expanded credential large.

So the identifying material lives in its own `details` block, separate from the award's public facts, and both the block and the attributes around it carry salty nonces. The intended layers are:

* **compact** — the attributes block as a SAID
* **partial** — the public facts (`issuerName`, `category`, `timeframe`, `awardName`) with `details` as a SAID
* **full** — `details` expanded: `issueeName`, `citation`, `image`

These layers are described here rather than shipped as examples, and the reason is specific. The compaction itself works: a credential whose sections carry a `d` slot compacts to exactly the same top-level SAID it had expanded, which is what makes graduated disclosure safe. But a credential built the way the only issuer builds one today carries no `d` slot at all, and a section without one is fully expanded during most-compact computation — so it cannot be compacted, and the middle layer cannot be produced. Tick `2zqx` records what was measured. Until an issuer emits block SAIDs, treat the partial layer as a design intent the schema is shaped for, not a form you can present.

### Governance framework

The rules section is **optional**, and deliberately so. An award's terms belong to its issuer: the Oscars, a Nobel prize and an Olympic medal have carefully defined rules, while a casual employee recognition may have none worth stating. So this schema does not enumerate clauses the way the rest of the corpus does, and the `r` block accepts an issuer's own vocabulary.

A recommended baseline is published in [`rules.json`](rules.json) for issuers who want one. It carries four clauses: `recognitionNotPrivilege` (an award proves recognition and confers no privilege of itself — a verifier that grants something on the strength of one owns that decision), `namesAreConvenience`, `unrecognizedClauseFailsClosed` (an issuer may add clauses, and a verifier that does not understand one must treat its requirement as unmet), and `imageByReferenceMayChange`.

An issuer that writes its own ruleset takes on stating the fail-closed rule itself; the schema cannot enforce it, because the schema deliberately does not own the vocabulary.

Version 1.0.0 is preserved at [`award-1.0.0/`](../award-1.0.0) and stays resolvable under its original SAID.
