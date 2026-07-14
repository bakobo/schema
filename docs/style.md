# Schema house style

Derived from `this.i` `@p6mwk4`. Applies to **Bakobo-authored domain fields** —
the members of the `a` / `e` / `r` blocks beyond the ACDC envelope. Existing
schemas adopt it when they next get a version bump; it is not a repo-wide rename.

## Rules

1. **camelCase.** The JSON default, and what imbu already writes for the relation
   facet (`relationType`, `obligationBearer`, `presentsAs`, `exerciseMode`).
2. **Expressive, but an obvious abbreviation beats the full word.** "Obvious" =
   understood with no legend *and* no collision with a well-known other meaning.
   - ✅ `juris`, `phys`, `virt`, `val`, `proto` — obvious.
   - ❌ `dom` for domain — collides with the HTML DOM → use `domain`.
3. **Abbreviate freely; amputate never.** An abbreviation shortens a *word*
   (`jurisdiction`→`juris`); it must not drop a word. `stateKind` stays — `kind`
   alone loses the load-bearing "state".
4. **Array-valued fields are plural.** Pluralize the English word, *then*
   abbreviate: `goals`, `effects`, `stateKinds`, `protos`, `proofs`, `physGeos`,
   `virtGeos`, `juris`.
5. **Never restyle the ACDC envelope.** `v / d / u / i / ri / s / a / e / r` and
   block `d`s are fixed by ACDC. Their terseness earns its keep (universal, and
   in the compact form they are all that ships). Domain fields appear only in the
   *expanded* form, so their verbosity costs nothing on the wire.

## Canonical abbreviations

Add to this list rather than inventing ad hoc. (Future `schematools check_naming`
will read it.)

| full | abbrev |
|---|---|
| geographic / geography | `geo` |
| physical | `phys` |
| virtual | `virt` |
| jurisdiction(s) | `juris` |
| protocol | `proto` |
| value | `val` |
| maximum / minimum | `max` / `min` |
| schedule | `sched` |
| datetime | `dt` |
| identifier | `id` |
| information | `info` |
| reference | `ref` |
| message | `msg` |
| address | `addr` |

## Worked example — GCD constraints (v1 `c_*` → v2)

| v1 | v2 | array? |
|---|---|---|
| `c_goal` | `goals` | ✓ |
| *(new)* | `effects` | ✓ |
| *(new)* | `stateKinds` | ✓ |
| *(new)* | `domain` | tbd |
| `c_jur` | `juris` | ✓ |
| `c_pgeo` | `physGeos` | ✓ |
| `c_rgeo` | `virtGeos` | ✓ |
| `c_ical` | `scheds` | ✓ |
| `c_upto` | `maxVal` | — |
| `c_proto` | `protos` | ✓ |
| `c_prove` | `proofs` | ✓ |
| `c_after` / `c_before` | `validFrom` / `validUntil` | — |
