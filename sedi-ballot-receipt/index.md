## SEDI Ballot Packet Possession Receipt

A county clerk attests that a verified voter held a mail-in ballot packet at a point in time. The voter scans the QR code on the packet's return envelope, never on the ballot card; the code carries the clerk's signed request (clerk AID and OOBI, election and packet identifiers, a single-use challenge nonce and an expiry). The voter's wallet presents what the request asks for, enough to match the voter roll, and the clerk verifies the presentation and issues this receipt. It is a provisional Bakobo profile for the SEDI Summit's mail-in ballot act, not Utah policy (`this.i` @3l8uwufr).

### Issuer and issuee

The clerk issues the receipt from its own registry (`rd`), so a clerk that later rejects the packet can revoke the receipt. The issuee `a.i` is the AID that presented: a per-copy holder AID, never the SEDI Management AID, which only the State sees.

### What it says

| attribute | meaning |
|---|---|
| `election` | the election identifier printed on the packet |
| `packet` | the return-envelope packet identifier, printed on the envelope and never on the ballot card |
| `request` | SAID of the clerk-signed request the QR code carried |
| `exchange` | SAID of the IPEX grant the holder presented in answer |
| `heldAt` | when the clerk verified the presentation, an RFC 3339 date-time by the clerk's clock |
| `basis` | schema SAID of the credential whose disclosure the clerk matched against the voter roll |

Naming the request and the exchange lets the holder's KEL seal of the exchange, whose witness receipts timestamp it independently of the clerk's clock, be joined to the receipt by anyone the holder shows both to.

### What is deliberately absent

- No voter attribute. The clerk already holds exactly what was disclosed; copying it here would put identity into a credential the holder may show to others.
- No edge to the presented credential. An edge would join the receipt to that copy for every later verifier.
- Nothing about the ballot. The packet is separated from the ballot card before counting, and possession is all this attests: it does not say the voter filled in the ballot.

The attributes are flat strings rather than selectively disclosable blocks; the section as a whole compacts to its SAID. Both nonces are at least 24 characters (a CESR 128-bit salt), because a printed packet identifier is guessable and a compacted section must not let anyone confirm a guess.

### Schema

The schema is in [`sedi-ballot-receipt.schema.json`](sedi-ballot-receipt.schema.json), an instance in [`example.json`](example.json), and one fixture per defect in [`invalid/`](invalid).
