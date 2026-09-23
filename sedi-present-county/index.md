# SEDI County Presentation (`sedi-present-county`)

**Bakobo holder-issued recipe, version 1.0.0.** This one-time presentation supports the Summit county step. The holder issues it to the verifier, asserting a county in `a.county` and disclosing the county block from the state-issued [Residence](../sedi-residence/) credential alongside it. It also links to [Core](../sedi-core/) so the verifier can establish the presenter's identity chain.

The `identity` and `residence` edges require `I2I`, with their far-schema SAIDs pinned to Core and Residence. The presentation has no `rd`; its required `r` names the standalone [Bakobo governance artifact](../sedi-id/rules.json). Its local [`example.json`](example.json) and [`invalid/`](invalid/) cases exercise the shape. The verifier must resolve and verify both far nodes and compare the disclosed Residence county value to the holder's summary; the schema cannot establish those facts by itself.

Sam Smith has not authored this presentation schema. It follows the predefined presentation recipe pattern in [keripy discussion #1627](https://github.com/WebOfTrust/keripy/discussions/1627).
