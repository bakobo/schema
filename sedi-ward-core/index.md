# SEDI Ward Core (`sedi-ward-core`)

**Bakobo provisional Tier C variant, version 1.0.0.** This keeps the attributes and `utahAgent` edge from [Sam Smith's Core schema at `ec307cd74`](https://github.com/WebOfTrust/keripy/blob/ec307cd74/tests/sedi/test_sedi.py#L138-L359) and adds a required `guardian` edge. The edge uses `NI2I`: the ward is the issuee of this credential, while another person is the issuee of the [guardianship credential](../sedi-guardian/). Sam Smith authored Core; Bakobo authored this variant. It has a distinct SAID, so an issuer must select it intentionally for a ward.

Ward Core follows Sam's Core envelope, so `t` remains optional here even though other Bakobo profiles require `t: acm`.

The `guardian` edge points to the state-issued guardianship credential, whose attribute block names the ward. A verifier checks that the ward AID matches, resolves the guardian credential, and checks its live registry status. Revoking guardianship can therefore remove the guardian's authority without revoking the ward's identity credential. The schema checks the local edge shape and operator; graph and status checks belong to the verifier.

[`example.json`](example.json) forms a coherent local graph with [`sedi-guardian/example.json`](../sedi-guardian/example.json). [`invalid/`](invalid/) covers a missing guardian edge and wrong far-schema or operator. This is a Bakobo profile of the graph in [keripy discussion #1550](https://github.com/WebOfTrust/keripy/discussions/1550), not a Utah-approved schema.
