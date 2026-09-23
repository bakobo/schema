# SEDI Age and Portrait Presentation (`sedi-present-age-portrait`)

**Bakobo holder-issued recipe, version 3.0.0.** A holder issues this one-time presentation to a verifier to support an over-21 claim and a state-endorsed portrait disclosure. It is a named presentation pattern, not a Sam Smith schema. Its former 2.0.0 schema remains in [`sedi-present-age-portrait-2.0.0/`](../sedi-present-age-portrait-2.0.0/).

The holder is the issuer `i`, and the verifier is the issuee `a.i`. The required `identity` I2I edge points to [SEDI Core](../sedi-core/); the required `age` I2I edge points to the current [SEDI Age](../sedi-age/) schema. `I2I` requires the presenter to be the issuee of both source credentials. The portrait is disclosed from Core's `facialImageProof` block alongside the presentation; the `ageOver21` attribute is a holder summary backed by the age disclosure. The presentation is not registry bound, so its schema omits `rd`. Its required `r` is the SAID of the [Bakobo governance artifact](../sedi-id/rules.json).

[`example.json`](example.json) illustrates the presentation, and [`invalid/`](invalid/) contains rejected variants. Source credential validity, edge traversal, attribute disclosure, and status checks are verifier duties; JSON Schema only checks the presentation's local shape and pinned edge operators and far-schema SAIDs.
