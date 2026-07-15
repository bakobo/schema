# Schema house style

Derived from `this.i` `@p6mwk4`. Applies to **Bakobo-authored domain fields** —
the members of the `a` / `e` / `r` blocks beyond the ACDC envelope. Existing
schemas adopt it when they next get a version bump; it is not a repo-wide rename.

## Rules

1. **camelCase.** The JSON default, and what imbu already writes for the relation
   facet (`relationType`, `obligationBearer`, `presentsAs`, `exerciseMode`).
2. **Expressive, but an obvious abbreviation beats the full word.** "Obvious" =
   understood with no legend *and* no collision with a well-known other meaning.
   - ✅ `phys`, `virt`, `val`, `proto`, `geo` — obvious.
   - ❌ `dom` for domain — collides with the HTML DOM → use `domain`.
3. **Abbreviate freely; amputate never.** An abbreviation shortens a *word*
   (`jurisdiction`→`juris`); it must not drop a word. `stateKind` stays — `kind`
   alone loses the load-bearing "state".
4. **Array-valued fields are plural.** Pluralize the English word, *then*
   abbreviate: `goals`, `effects`, `stateKinds`, `protos`, `proofs`, `physGeos`,
   `virtGeos`. An abbreviation whose plural is not *itself* clearly plural is
   rejected: `jurisdiction` stays `jurisdictions`, never `juris` (a bare `juris`
   does not read as a plural). Format-label plurals are the accepted exception —
   `icals` (iCalendar fragments) keeps the label rather than spelling it out.
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
| protocol | `proto` |
| iCalendar (RFC 5545) fragment | `ical` |
| value | `val` |
| maximum / minimum | `max` / `min` |
| datetime | `dt` |
| identifier | `id` |
| information | `info` |
| reference | `ref` |
| message | `msg` |
| address | `addr` |

## Worked example — GCD constraints (v1 `c_*` → v2)

In v2.0 these all live inside the `constraints` container (this.i `@h4tqm7`,
`@k7wd3m`); the `c_` prefix is dropped.

| v1 | v2 (`a.constraints.*`) | array? |
|---|---|---|
| `c_goal` | `goals` | ✓ |
| *(new)* | `effects` | ✓ |
| *(new)* | `stateKinds` | ✓ |
| *(new)* | `domains` | ✓ |
| `c_jur` | `jurisdictions` | ✓ |
| `c_pgeo` | `physGeos` | ✓ |
| `c_rgeo` | `virtGeos` | ✓ |
| `c_ical` | `icals` | ✓ |
| `c_upto` | `monetaryLimit` | — |
| `c_proto` | `protos` | ✓ |
| `c_prove` | `proofs` | ✓ |
| `c_after` / `c_before` | `validFrom` / `validUntil` | — |
| `c_human` | `humanReview` | — |

New v2.0 fields with no v1 `c_*` ancestor: the a-block siblings
`terminatingEvents` and `disclosables` (`@v3rk5p`); the `facet` members `role`,
`relationType`, `liableParty`, `presentsAs`, `exerciseMode` (`@k7wd3m`,
`@x4nq6t`); and the `r`-block `duties` array (`@m6tq4w`).
