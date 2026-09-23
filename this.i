# schema — Intent Tree (this.i)
#
# Source of truth for the design of bakobo/schema, per the Bakobo intent-first methodology
# (docs/methodology.md). This repo is a hard-fork of provenant-dev/public-schema; the credential
# schemas (JSON/ACDC) are captured artifacts, and any tooling and docs are derived from the
# decisions recorded here.
#
# Node ids are opaque base32 [a-z2-7]; NEVER parse them, never make them semantic. When a node is
# renamed its id is untouched and all @id references still hold.

bakobo owns a home for general-purpose ACDC schemas, GCD chief among them = goal:
  id: q3nv6t
  why: >
    Bakobo needs a repository it controls for the general-purpose ACDC credential schemas it authored
    — above all GCD (Generalized Cooperative Delegation), the delegation credential that imbu's
    decision core enforces and that "The Shape of Delegated Authority" describes. Chose a HARD-FORK of
    provenant-dev/public-schema (copy the general-purpose schemas, sever the upstream link, evolve
    independently) over three alternatives: depending on public-schema (Provenant-owned, telco/vLEI-
    focused, and not evolving the general types — Bakobo would be blocked on Provenant's cadence and
    priorities); contributing the SDA evolution upstream (same blocker, and it entangles Bakobo's
    product direction with Provenant's telco roadmap); and a clean-room rewrite (throws away working,
    already-SAIDified schemas and their design history). Tradeoff accepted: no automatic upstream sync
    and we own maintenance — if Provenant ever evolves a shared general-purpose type, we must re-pull it
    by hand. Captured from public-schema at commit 8db57eb (2026-05-22); provenance recorded in NOTICE
    per Apache-2.0. This repo is the "schema" node of imbu's ecosystem federation (see imbu's this.i
    @f6dx2n): an OSS dependency imbu stands on, GCD being imbu's keystone delegation credential.
  children:
    Scope is general-purpose only; telco and vLEI credential types are removed = decision:
      id: k5wd2r
      why: >
        Kept the 12 general-purpose types (gcd, ai-coder, ai-user-coca, attestation, award, bindkey,
        citation, dossier-base, faa, face-to-face, org-vet, proof-of-control) and removed the telco and
        vLEI types (a2p-campaign, tcr-vetting, tn, tn-alloc, vvp-dossier, brand-owner, ovc-brand-owner,
        ovc-org-vet, aegis-std-vetting, and the whole vLEI tree). Chose to strip rather than keep-all
        because the telco/vLEI types encode Provenant's line of business (A2P 10DLC, branded calling, the
        vLEI ecosystem), not general delegation, and carrying them would blur this repo's purpose and drag
        in the schema-registry deployment coupling built around them. The general org-vetting need is met
        by the retained org-vet; only the telco-vendor vetting (aegis-std-vetting) and branded-calling
        (brand-owner / ovc-*) variants were dropped. Verified no retained schema has a SCHEMA-LEVEL edge
        into a stripped type — the only cross-mentions were prose in three index.md files (ai-coder, award,
        org-vet), left as a cleanup follow-up. Tradeoff: a stripped type later needed is re-imported from
        public-schema, not recreated. Two strips are borderline and flagged for reconsideration:
        brand-owner (the non-OVC sibling of the telco branded-calling pair) and aegis-std-vetting.
    GCD is the flagship and must be evolved to the SDA model = decision:
      id: b6xh4m
      stage-status: done
      why: >
        The captured GCD (credentialType gcd-credential, version 1.0.0) already carries much of the model:
        c_goal, c_jur, c_pgeo / c_rgeo, c_ical, c_upto, c_proto, c_prove, c_human, c_after / c_before, plus
        role + gfw (a governance-framework SAID) and a rules/disclaimer block (noRoleSemanticsWithoutGfw,
        issuerNotResponsibleOutsideConstraints, noConstraintSansPrefix, useStdIfPossible,
        onlyDelegateHeldAuthority). But it PREDATES "The Shape of Delegated Authority" and is missing the
        refinements that paper and imbu's this.i settled: c_effect (the effect axis — observe / create /
        modify / preserve / destroy), the named state-kind and target modulators, the relation/obligation
        facet (relationType, obligationBearer, presentsAs, authority-to-authorize), the may/must duty split,
        and the outbound-disclosure axis (c_disc). Evolving GCD to carry these — as a new version, keeping
        the old — is the near-term work, because GCD is imbu's keystone delegation credential and the
        interface its decision core enforces. Chose to evolve GCD in place (a new version) over minting a
        new credential type, because GCD is already the right shape and named vocabulary. KNOWN DEFECT
        inherited from the source: gcd/gcd.schema.json is NOT valid JSON (an extra closing brace in/after
        the c_upto block, ~line 180) — it must be repaired and re-SAIDified as the first evolution step; its
        current $id SAID cannot match its bytes. Captured byte-for-byte anyway, so provenance is provable.
      children:
        The a-block replaces the flat c_ prefix with named container objects = decision:
          id: h4tqm7
          stage-status: done
          why: >
            Today every GCD constraint is a c_-prefixed field flat in the a block (c_goal, c_jur, ...), a naming
            CONVENTION whose real job is safe-ignore forward-compat: noConstraintSansPrefix lets a stranger-
            verifier split fields into "must-satisfy-or-fail-closed" vs "informational, ignore" from the field
            name alone (open-loop, imbu @kp5l4o). v2.0 replaces the flat prefix with NAMED CONTAINER OBJECTS in
            the a block: constraints{} (the "may" — enabling and voiding @v5nq2r), plus reserved facet{} (the
            relation/obligation facet, imbu @nf5rx7) and discloses{} (the outbound axis, imbu @m3xc7d / @c3wqn7).
            The "must" (duties) does NOT get an a.duties object — it lives in the r block (@r5dnk2). The c_ prefix
            is DROPPED, fields renamed per the house style (@p6mwk4: goals, effects, juris, physGeos, ...). The
            safe-ignore rule is preserved and STRENGTHENED (a subtree boundary is firmer than a lexical
            convention), restated as "nothing outside constraints constrains; an unrecognized key inside
            constraints → fail closed" (replacing noConstraintSansPrefix). Bonus the prefix could not express: the
            container encodes ENFORCEMENT SEMANTICS — constraints{} is gate-relevant / fail-closed, whereas duties
            are accountability a verifier may ignore for the authorization decision; a flat scheme would need a
            SECOND prefix to say that. Chose this at v2.0 (the sanctioned break) because (a) the c_* blast-radius
            inventory (2026-07-13) found ZERO code dependency on the prefix or names — pap_policy collects
            metadata by isinstance-dict, name-agnostic; semantic-perm-hook has none; imbu enforcement is unbuilt —
            so the cost is prose, not code; and (b) the container shape is STABLE even while the field set still
            moves (c_effect / kind / dom, voiding c_until), decoupling structure from field-set, so it is the
            low-thrash decision to make first. Rejected "just strip c_" (keeps cryptic names, gives duties no home)
            and keeping the flat prefix (cannot carry the may/must enforcement split without a second prefix).
            CONSEQUENCE: every c_ reference in schema/imbu/org prose (and the upstream pap doc) goes stale on
            authoring — tracked in tick 5hlz (schema docs, resolved) and 44oc (cross-repo); the schema artifact + example +
            registry re-SAIDify per @b6xh4m.
          children:
            The v2.0 constraints container is a closed enum-checked gate; facet stays permissive = decision:
              id: k7wd3m
              stage-status: done
              why: >
                Realizes @h4tqm7's containers with the FINAL v2.0 field set and the fail-closed boundary.
                constraints{} carries goals, effects, stateKinds, domains, jurisdictions, physGeos, virtGeos, icals,
                monetaryLimit, protos, proofs, validFrom, validUntil, and humanReview, and sets
                additionalProperties:false — so an unrecognized key INSIDE constraints fails closed, the
                subtree-firm restatement of the old noConstraintSansPrefix rule. effects
                (observe|create|modify|preserve|destroy) and stateKinds
                (information|record|commitment|authority|resource|relationship) are CLOSED enums, not free strings,
                because a gate that cannot reject an unknown effect is not a gate; the SDA effect/state axes (imbu
                @x3ns6p, org record-shape) fix the value sets. facet{} carries role, relationType
                (delegation|guardianship|controllership|stewardship), liableParty, presentsAs, and exerciseMode, and
                stays PERMISSIVE (no additionalProperties:false) because ONLY constraints is the fail-closed gate —
                the facet is descriptive accountability a verifier MAY ignore for the authorization decision, and
                imbu's facet is still growing (revocability, principal-threshold @nf5rx7), so locking it now would
                force a version bump on every added field. monetaryLimit is MONEY-LOCKED (a magnitude + a
                currency-like unit token, currency-first) and is NOT "stakes": stakes is the derived gate quantity,
                and non-money or unquantifiable stakes route to the gate (@d6mk3g), never to this field. liableParty
                (renamed from obligationBearer, already propagated to imbu/org/paper) is OUTWARD liability — who the
                world holds responsible if an act goes wrong — distinct from grantor (issuer i), beneficiary
                (relationType), actor (delegate), and the inward accountability of the duties in r. Kept minItems:1 +
                uniqueItems on every array field (an empty allow-list is meaningless; a pure delegator omits goals
                and sets exerciseMode:authorize rather than carrying an empty goals array). Rejected free-string
                effect/stateKind (ungateable) and a fail-closed facet (churns on every imbu facet addition).
              children:
                effects+stateKinds were a drift; authority is a set of (effect,state-kind) POINTS in acts = decision:
                  id: k4pv7n
                  stage-status: done
                  why: >
                    @k7wd3m modeled effect and state-kind as two INDEPENDENT allow-list fields (effects[],
                    stateKinds[]), ANDed across like the other constraints. That is a drift from the model this schema
                    serves: SDA §4 / Fig 2 locates an act as a VECTOR of (effect, state-kind) POINTS — the two are the
                    axes of one coordinate grid, and neither is meaningful alone ("create" is create WHAT; "commitment"
                    is do WHAT to it). ANDing two independent axes grants their CROSS-PRODUCT: to permit "create a
                    relationship" and "observe a commitment" you had to list effects [create,observe] and stateKinds
                    [relationship,commitment], which silently ALSO granted "create a commitment" and "observe a
                    relationship" — over-granting, and unable to express asymmetric per-kind effects. imbu already
                    models the act as a coordinate vector (@mq4v7d) with the gate a function of (effect, state-kind,
                    target) (@d6mk3g); GCD drifted, not imbu. FIX: replace effects + stateKinds with a single field,
                    constraints.acts — a set of (effect, state-kind) POINTS. Each point is a space-delimited string
                    "effect state-kind" (verb object, reads as a phrase: "create commitment"), with a ONE-SIDED brace
                    enumeration to name several kinds for an effect ("observe {info, record}") or several effects for a
                    kind ("{create, modify} record"); brace-internal items separate on one or more commas/spaces.
                    Two-sided braces (a rectangle in one token) and open wildcards are FORBIDDEN — the first
                    structurally re-admits the cross-product, the second is fail-open on a later-added kind; both are
                    rejected by the field's pattern regex, so a malformed or unknown token fails closed at the schema
                    level. state-kind is abbreviated info (house glossary). An act is authorized iff EVERY point it
                    occupies is covered; the gate (auto/rule/human) it must clear is DERIVED per act from those points
                    and the target via the gfw (@d6mk3g), NOT enumerated here — so state-kind stays gate-machinery,
                    present in acts only as the coordinate half of a point. goals (telos) stays a SEPARATE axis, not
                    folded into the point (SDA: effect is "a separate lock from telos"). A pure delegator has an EMPTY
                    act surface (SDA §5): it omits acts and sets exerciseMode:authorize. Chose the space-delimited
                    string DSL over nested {effect,stateKind} objects (keeps every constraint a flat array of strings;
                    the author can be verbose or use braces) and over spreadsheet cell/range notation (whose whole
                    advantage is compact rectangles — the very cross-product we are removing — and whose A1-style refs
                    need a legend, violating the house style). Folded into v2.0 in place because it is unreleased and
                    imbu's enforcement unbuilt, so no consumer depends on the effects/stateKinds shape yet; the parent
                    why's effects/stateKinds naming is left as the dated record. Grounded by re-reading SDA Fig 2 with
                    Daniel, 2026-07-15.
            exerciseMode is the enum act|authorize|both; imbu's delegated-only reconciles to authorize = decision:
              id: x4nq6t
              stage-status: done
              why: >
                exerciseMode encodes which of the two independent authorities (@z6tq4a: authority-to-act vs
                authority-to-authorize) a GCD confers: act (goals, no authorize), authorize (the pure delegator —
                authority-to-authorize with empty goals, what imbu writes as delegated-only), or both. Chose to make
                GCD's clean three-token enum the CANONICAL vocabulary over adopting imbu's delegated-only phrasing,
                because GCD is the credential interface imbu's decision core enforces — the schema is the contract,
                imbu the consumer — so the on-the-wire vocabulary should read cleanly and not inherit a consumer's
                internal label. Consequence: imbu's delegated-only becomes the stale term, reconciled to authorize
                under the already-tracked cross-repo tick 44oc. Confirmed with Daniel 2026-07-15. Rejected keeping
                delegated-only (ties the interface enum to one consumer's phrasing) and a boolean pair
                canAct/canAuthorize (three states read more clearly as one enum, and "both" is a real, common case).
            terminatingEvents and disclosables are a-block siblings of constraints, each a distinct polarity = decision:
              id: v3rk5p
              stage-status: done
              why: >
                @h4tqm7 reserved discloses{} and @v5nq2r introduced the voiding polarity; v2.0 realizes both as
                a-block SIBLINGS of constraints, NOT keys inside it, because their enforcement semantics differ from
                the enabling "may". terminatingEvents is an array of proof-request SAIDs for attested VOIDING events
                (ANY firing voids authority; proof-shaped, not a live predicate, per @v5nq2r) — kept outside
                constraints so the fail-closed unknown-key rule on constraints never mis-reads a voiding entry as an
                enabling allow-list. It REQUIRES a constraints.validUntil backstop, enforced in-schema by an if/then
                (terminatingEvents present -> validUntil required), realizing @v5nq2r's rule that a never-fired
                "done" signal cannot leave authority alive forever. disclosables is the OUTBOUND axis (@m3xc7d): an
                array of credential-SCHEMA SAIDs the delegate MAY reveal about its principal — absent = unconstrained,
                present = allow-list, at schema granularity (intra-credential selective disclosure stays ACDC's job).
                Rejected folding either into constraints (conflates voiding and outbound-disclosure with the enabling
                gate, and forces the fail-closed rule to special-case them) and a live untilObserved predicate
                (deferred @tq5wnh — kept proof-shaped so any two verifiers replay to the same result).
        The reciprocal record IS the GCD r block; the "must" is first-class there, not a second credential = decision:
          id: r5dnk2
          stage-status: done
          why: >
            The may/must split (SDA §5; imbu @v2kd7m; org @dwx5twwyh) parks the "must" (duties) in a "reciprocal
            record," and @d5tqm6 left OPEN whether duties ride on the GCD credential or a separate reciprocal
            record (mirrored by the org tension @ot4puqrj). Resolved: the reciprocal record is NOT a second
            credential — it is the GCD's own r (rules) block, which v2.0 upgrades to carry FIRST-CLASS structured
            duties alongside its Ricardian disclaimer clauses. Chose one credential with duties in r over a paired
            second credential because: (1) open-loop — a duty-bearing act stays verifiable from ONE self-contained
            artifact, where a second record forces two-artifact correlation at verification, the closed loop imbu
            forbids (@kp5l4o); (2) the r block IS the accepted-terms / Ricardian mechanism, and because the
            delegator issues (signs) the GCD, anything in r is delegator-signed by construction — exactly what
            "delegator-signed reciprocal record" asked for; (3) multi-principal conflicting duties (@v2kd7m) are
            handled naturally — each principal's duties sit on THEIR own GCD to the delegate, and imbu aggregates
            across held credentials regardless; (4) @k3wm7d already puts a duty (timelyReviewAndRevoke) into the
            rules block, so first-classing duties there regularizes what exists. Duties are DISCLOSURE +
            ACCOUNTABILITY, not enabling constraints (@d5tqm6) — a stranger-verifier does not gate on them (audit +
            recourse) — so they belong in r, NOT in a.constraints, and NOT in an a.duties object (this CORRECTS an
            earlier container sketch that tentatively placed duties in a). The lone case a separate record would win
            — duties renegotiated far more often than permissions — is YAGNI (SDA duties are role-level, ~as stable
            as permissions) and extractable later (@c5tj3p logic). This resolves @ot4puqrj and @d5tqm6's open, and
            REQUIRES a paired update to imbu @v2kd7m / @nf5rx7 and org @dwx5twwyh / @ot4puqrj (which still model a
            distinct reciprocal record) — the cross-repo obligation tracked in tick 44oc.
          children:
            The r-block duties are a first-class array keyed by bearer; timelyReviewAndRevoke becomes an issuer duty = decision:
              id: m6tq4w
              stage-status: done
              why: >
                Realizes @r5dnk2's first-class duties with the FINAL shape. r gains an OPTIONAL duties array whose
                items are one of two bearer-discriminated objects: a DELEGATE duty {bearer:delegate, effect, goal,
                cadence?, priority} (a machine-structured "must" — produce this effect toward this goal on this
                cadence) and an ISSUER duty {bearer:issuer, rule, l?, priority} (a named governance obligation, its
                legal text optional in l). priority is REQUIRED on both and carries the fail-loud precedence /
                escalation @v2kd7m demands for conflicting musts. timelyReviewAndRevoke (@k3wm7d) is modeled as an
                ISSUER DUTY, not the sixth disclaimer it was planned as — correcting the "duty smuggled in as a
                disclaimer" that @d5tqm6 flagged, and resolving the duty-vs-disclaimer shape that tick 3isv tracked. duties is OPTIONAL (a
                minimal GCD carries none) while the baseline governance ruleset (rules.json) carries the issuer
                timelyReviewAndRevoke duty, so the standing obligation ships by default without forcing every
                credential to enumerate it. Separately the fifth disclaimer noConstraintSansPrefix is RENAMED to
                noConstraintOutsideConstraints with new const text ("enforceable constraints exist only inside the
                constraints container ... nothing outside it constrains"), realizing @h4tqm7's restated,
                subtree-firm safe-ignore rule. Rejected requiring duties (over-taxes a minimal delegation), a single
                untyped duty object (bearer:delegate and bearer:issuer carry genuinely different fields), and keeping
                timelyReviewAndRevoke as a disclaimer (it is an obligation, not a liability-scoping clause).
        GCD 1.0.0 is preserved as a registered versioned directory; gcd/ becomes 2.0.0 = decision:
          id: r5vk3n
          stage-status: done
          why: >
            @b6xh4m evolves GCD "as a new version, keeping the old"; this fixes HOW. Chose to copy the current gcd/
            to a sibling gcd-1.0.0/ (its schema at gcd-1.0.0/gcd-1.0.0.schema.json plus its example), keep its
            unchanged SAID EM3kQ1QEU3kJFqV8aZrse-QXs5oNlaFfaiwEUFt4uq4C in registry.json, and publish it — so 1.0.0
            stays resolvable by SAID/OOBI — while gcd/gcd.schema.json is rewritten to 2.0.0 with a fresh SAID. Chose
            the versioned DIRECTORY over the handoff's floated archived-in-place gcd/gcd-1.0.0.schema.json, which
            FAILS the linter: discover_schemas keys on <folder>/<folder>.schema.json, so a second schema file in the
            gcd/ folder is never discovered, and check_registry rejects any registry path that is not a discovered
            folder-schema. Also rejected an unregistered archival copy (1.0.0 would drop out of the registry and lose
            its OOBI, contradicting "keeping the old" as a resolvable artifact). credentialType stays gcd-credential;
            the compact/expanded oneOf and the e-block I2I issuer edge are preserved in both versions. Confirmed with
            Daniel 2026-07-15.
        GCD documents delegated authority, not a required KERI cooperative-delegation binding = decision:
          id: n8wq3d
          why: >
            GCD's issuee field carried the description "AID of delegate, as it appears in delegator's interaction
            event", and gcd/index.md framed the whole credential as documenting "a KERI-style cooperative
            delegation". Both hard-coded a PRECONDITION that GCD never actually enforced: that the issuee be a KERI
            cooperative-delegated AID — one whose inception (dip) is anchored in the delegator's KEL via an
            interaction event (ixn). Re-verified before editing that no this.i node ever DECIDED that precondition:
            the wording is inherited verbatim from the captured 1.0.0 schema (@b6xh4m), and the GCD design nodes
            (@b6xh4m / @h4tqm7 / @k7wd3m / @k4pv7n) are all about constraints, duties, and facet modeling; the
            onlyDelegateHeldAuthority disclaimer is about no-privilege-escalation, not a KEL binding. So this is a
            description CORRECTION, not relitigating a recorded decision. A GCD credential is a standard targeted
            ACDC whose authorization/constraint mechanics do not depend on the issuee being KEL-anchored to the
            issuer — an issuer routinely issues a credential to an AID it does not control — so the "as it appears
            in delegator's interaction event" clause over-specified. THE PRECISION THAT KEEPS THIS CLEAN: GCD stays
            legitimately ABOUT delegated authority; what is decoupled is "delegated AUTHORITY" (which GCD documents,
            no KEL anchoring required) from "KERI COOPERATIVE-DELEGATION KEL binding" (a stronger, optional fact).
            GCD is NOT weakened into a generic bearer credential; onlyDelegateHeldAuthority is unaffected; the
            cooperative-delegation dip+ixn two-way binding remains the paradigmatic and strongest way to bind a
            delegate to a delegator and stays fully supported — it is now the EXEMPLAR, not the gate. EXTERNAL
            DRIVER: the Principal Action Protocol (provenant-dev/pap). PAP's Phase-4 trust chain (pap @k4tnpw)
            needs, on a governed request, evidence that the user-held signer was authorized by an established
            authority, expiry-bounded (PAP tension e3vmqk, "Delegation Evidence Form"); a GCD v2 credential is the
            leading candidate (KERI-native, TEL-revocable, validUntil-bounded; constraints.goals + validUntil
            express "authorized for this action, until expiry"). But PAP's signer is an INDEPENDENT role AID
            (firstname-as-employee-at-org, authorized by the org's AID), NOT a cooperative-delegate of the authorizer
            (PAP decision a6peer: incepted AIDs are independent peers), so PAP issues a GCD with issuer = authorizing
            AID and issuee = the independent signer with no dip/ixn between them — a valid grant the old wording
            wrongly excluded. Decoupling unblocks PAP without abusing GCD semantics and matches what "GENERALIZED"
            Cooperative Delegation already implies. GRADING & CASCADE: description-only, changing no validation
            semantics and invalidating no instance, so PATCH per RFC-0430 grading (@k3wm7d): 2.0.0 -> 2.0.1. Chose
            to land the schema edit NOW with the full re-SAIDify cascade over the split the handoff floated (prose
            now / schema next bump), because prose-only would leave gcd/index.md ("not required") contradicting the
            schema's own a.i ("as it appears in delegator's interaction event") and would leave PAP's actual blocker
            (the wording it quotes) in place; the tooling makes the cascade mechanical and the linter (@n7xk4r)
            verifies consistency. Blast radius was WIDER than the handoff described: beyond gcd/ (schema $id + nested
            a-block $id, registry.json, example.json, the five examples/ gallery instances, and the three acts-*
            invalid fixtures' top s), sedi-guardian's optional scope edge (@sdlg3n) pins the GCD schema SAID at
            e.scope.s in its example.json and all twelve invalid fixtures, so those edge refs were repointed to the
            new SAID (positive examples re-saidified; should-reject fixtures only repointed, their intended defects
            untouched and still rejected). Cross-repo (external to this repo, tracked as the 44oc item): PAP's
            pap/docs/pap-vs-ipex/gcd-v2-for-delegation-evidence.md and any other consumer pinning the old GCD SAID.
        GCD 3.0.0 adopts the ACDC v2 envelope; 2.0.1 is archived as gcd-2.0.1/ = decision:
          id: enr3eg
          why: >
            Driver: heti is v2-first by recorded decision (heti this.i @0nx0p6gd) — its facets mint KERI v2
            KELs and it issues acm/JSON ACDCs against rip/upd registries, never a v1 wire artifact — so no
            credential heti can issue will ever validate against the v1-enveloped 2.0.1 schema ('ri', v1
            ordering). heti's end-to-end suite runs on a GCD-shaped stand-in awaiting this schema (heti tick
            3qtb; this repo's 25ra). The revision keeps the v2.0 semantic content unchanged (facet,
            constraints, terminatingEvents, disclosables, duties, the five clauses, the if/then validUntil
            backstop) and changes the ENVELOPE, following the v2 spec's worked examples
            (kswg-acdc-specification branch fix-worked-examples-schema-1520, the branch that matches keripy):
            top-level order [v, t, d, u, i, rd, s, a, e, r]; 't' optional in the schema (absent means acm in
            JSON, and the builder emits t=acm); dialect stays Draft 2020-12 ($schema is an identifier, never
            dereferenced); the compact SAID-string arm stays FIRST in every oneOf, which the most-compact-form
            SAID algorithm keys on (spec-body.md §"Most compact form SAID"); and the v1-era inner $id fields
            on the expanded a/e/r arms are DROPPED — the v2 idiom carries none, and the saidify tooling skips
            absent inner ids, so nothing recomputes them. THE ONE PLACE THIS OVERRIDES A SPEC DEFAULT: 'rd'
            (replacing 'ri') is REQUIRED. The spec makes rd optional for correlation minimization
            (spec-body.md :2019); a GCD is authority evidence — its issuer is already public, secure registry
            discovery is exactly what a stranger-verifier needs, heti-issued ACDCs always carry rd (heti
            @89kk7cft), and requiring it answers, for GCD, the rd-inclusion policy heti's review flagged as
            undecided (heti reviews/2026-08-14-acdc-plan PRV-F4: an rd-less ACDC verifies with only
            one-directional registry binding). Correlation-minimized delegation is not a GCD use case, and a
            schema that let rd be omitted would fail open on the discovery a verifier gates on. Required set
            [v, d, i, rd, s, a, r]; 'u' stays optional (the private variant remains expressible). a.d becomes
            OPTIONAL (was required): measured against the fork's acdcmap 2026-08-15 — the map form emits NO
            a.d; a d-less a section is fully expanded during most-compact computation while a d-bearing one
            compacts (both valid, distinct top-level d), and requiring d would reject every heti-built GCD.
            r.d stays REQUIRED: a d-less rules section cannot be compacted or SAID-addressed, and the GCD
            ruleset is SAID-referenced (gfw). The e block (I2I issuer edge) is carried over and stays
            OPTIONAL: heti refuses edge-bearing ACDCs by name until a real consumer needs chains (heti tick
            2esz), so a GCD that required its issuer edge could not be verified through heti today — edges
            remain the exemplar chaining mechanism, not the gate. Nothing in the schema depends on registry
            form (heti issues unblinded upd registries this tranche, heti @895yr58n). Versioning and layout:
            renaming required 'ri' to 'rd' invalidates every conceivable prior instance, so the change is
            MAJOR per RFC-0430 grading (@k3wm7d) — 2.0.1 -> 3.0.0 (the 25ra handoff guessed "a new
            gcd-2.0.0/" from a stale 1.x premise; the tree's current version is 2.0.1). Per @r5vk3n's
            convention the current schema, example, and rules are archived byte-identical at gcd-2.0.1/ with
            the old SAID EAqOeo_YMHDEMZ-dIJTYd72nsoUS-C1RdXtOdfAj7ZxR kept in registry.json, while gcd/ is
            rewritten with a fresh SAID. sedi-guardian is deliberately UNTOUCHED even though its example and
            fixtures pin the old GCD SAID at e.scope.s: that SAID stays registered and resolvable via the
            archive, and the pending sedi-guardian-no-gcd branch (unmerged) withdraws the GCD composition and
            deletes that edge anyway — repointing those refs on main would manufacture conflicts with a
            recorded withdrawal. Examples: example.json and the five-scenario gallery are re-authored as
            AUTHENTIC v2 instances (real v2 version strings, most-compact top-level d, verified by the fork
            oracle @h3or4x), which also discharges tick 62ws (the voiding and outbound axes get distinct
            illustrative SAIDs instead of reusing the edge's). The negative corpus is re-based on the v2
            valid instance, one mutation each, plus a new missing-rd fixture so the require-rd decision has
            a positive oracle that would fail if it regressed. ACCEPTANCE ORACLE: a credential built by the
            fork's acdcmap(israid, regid, schema=<new $id>, attribute={'i': ...}, rule={...}) validates
            against the schema (Schemer + Draft 2020-12 with format assertion), and heti's
            tests/produce/test_end_to_end.py Z1-Z4 pass with this schema's raw JSON swapped into
            GCD_SHAPED_RAW — closing heti tick 3qtb and this repo's 25ra.
        GCD 3.1.0 opens constraints and duties to custom keys; the verifier fails closed, not the schema = decision:
          id: vy7qoj
          why: >
            DRIVER — the schema contradicted itself. gfw's own description promises to add richer semantics
            to "any CUSTOM CONSTRAINTS present in this credential", and useStdIfPossible asks issuers to
            prefer a pre-defined field "rather than expressing the constraint in a note or in a CUSTOM
            FIELD". Both clauses are dead letters while constraints carries additionalProperties:false
            (@k7wd3m): a custom constraint is unexpressible, so the gfw hook the rules block advertises is
            unreachable and an issuer with a domain constraint outside the standard fifteen fields has
            nowhere to put it but a facet key, which by construction does not gate. THE INTENT THAT SETTLES
            IT (Daniel, 2026-08-18): a verifier MUST fail closed — if it does not understand an additional
            property, it MUST assume that constraint is unmet — but the credential as an embodied artifact
            does not have to enforce this; the verifier who chooses to deal with GCD credentials must.
            @k7wd3m conflated the two, making a JSON-Schema validator's rejection the enforcement mechanism
            for a rule that was always addressed to verifiers. CHANGE: a.constraints and both duty-item
            branches under r.duties (@r5dnk2) set additionalProperties:true. No field is added, removed,
            renamed, or retyped; every enum, const, pattern, required list, and the terminatingEvents ->
            validUntil if/then are untouched, as is the facet's long-standing permissiveness. The
            noConstraintOutsideConstraints clause ALREADY carries the obligation in Ricardian text ("an
            unrecognized key inside the constraints container MUST be treated as fail-closed") and needs no
            edit, so rules.json and its SAID ENiUyBCG2MjCHa9djlgHiogd6uZHECc09ZELmQ3fEMzR are byte-identical
            and every gfw reference to them still resolves. TRADEOFF ACCEPTED: a verifier that gates on
            schema validation ALONE loses a free backstop — an unknown constraint key now validates, and
            denial depends on that verifier's own code. Judged acceptable, and arguably clarifying, because
            schema validity was never authorization: a validator that could stand in for the gate invited
            exactly the confusion of the two that this node separates. REJECTED — namespaced custom keys
            (patternProperties ^x-[A-Za-z0-9]+$ with additionalProperties still false), which would keep a
            mechanical backstop and let a verifier tell "custom, consult the gfw" from "standard key I ought
            to know but do not": rejected because it re-introduces a lexical convention of exactly the kind
            @h4tqm7 retired the c_ prefix to escape, and the container boundary already says "gate-relevant".
            REJECTED — requiring gfw whenever a custom key is present (an if/then): a custom constraint that
            an issuer and delegate both understand is meaningful without a published framework, and the
            requirement would again be the schema legislating verifier semantics. DUTIES are opened for the
            same reason and for symmetry: a duty is disclosure and accountability that a stranger-verifier
            does not gate on at all (@r5dnk2), so a closed duty object was the strictest construct in the
            schema guarding the least. bearer stays a closed const on each branch, so the oneOf remains
            mutually exclusive and an unknown bearer still fails. GRADING & CASCADE: adds expressiveness and
            invalidates no 3.0.0 instance, so MINOR per RFC-0430 grading (@k3wm7d) — 3.0.0 -> 3.1.0.
            Per the 2.0.0 -> 2.0.1 precedent, a non-MAJOR re-mint rewrites gcd/ IN PLACE with a fresh SAID
            and does NOT archive its predecessor: @r5vk3n's versioned-directory archive is the MAJOR-bump
            convention (gcd-1.0.0/, gcd-2.0.1/), so 3.0.0's SAID
            EMxJ4BrRJ2zFpJ0yl4MP4MG9OXnoKT_Ehho_fHxRmzXM is retired rather than published. Cascade: schema
            $id, registry.json, example.json, the five gallery instances, and the negative corpus's top-level
            s. CORPUS: invalid/constraints-unknown-key.json is DELETED — its mutation (a legacy c_goal key
            inside constraints) is valid under 3.1.0, and it was the schema-level oracle for precisely the
            enforcement this node hands to the verifier. Its replacement, so the decision keeps an oracle in
            the corpus, is a POSITIVE one: examples/ai-deploy-agent.json carries a custom constraint
            (maxDeploysPerDay, a rate limit no standard field expresses) and a custom delegate-duty key
            (escalateTo), both of which 3.0.0 rejected and 3.1.0 accepts, so a regression to a closed
            container fails the conformance suite. CROSS-REPO: heti's tests/produce/test_end_to_end.py pins
            this schema's raw JSON in GCD_SHAPED_RAW (@enr3eg) and any consumer pinning the 3.0.0 SAID must
            repoint; tracked as tick 2zy3.
    face-to-face is hardened as a proof-of-personhood primitive for AI-proscribed contexts (v1.2.0) = decision:
      id: hp4mk7
      stage-status: done
      why: >
        face-to-face attests HUMANNESS from embodied interaction — one human vouching, from real-life
        contact, that an issuee is a human being and not an AI, org, or device. As AI participation gets
        actively PROSCRIBED (forums, elections, benefits, creative contests) and embodied AI improves, a
        verifier needs the credential to answer three distinct questions the v1.1 shape blurred: (1) is the
        subject human at all; (2) is that human bound to THIS key/AID; (3) is the binding still true now —
        plus the orthogonal (4) uniqueness. v1.2.0 hardens it with OPTIONAL, additive fields: knownAs (the
        non-legal label the issuer knew them by — already used in the example and docs but undefined in the
        schema, now formalized), modalities + keyControl (@ar6vk2), firstMet / lastInteraction / ongoing
        (freshness and relationship duration, complementing assertDate), and biometricProtocol (@uq5nw3).
        Chose an ADDITIVE MINOR bump (1.1.0 -> 1.2.0) over a MAJOR restructure: every new field is optional
        and no existing instance is invalidated (RFC-0430 grading @k3wm7d / @p3rk6d), and the existing
        noOverstatement / fairBiometric disclaimers already govern the added attestation detail, so the rules
        block and its SAID are untouched. Deliberately did NOT restructure basis into separate
        relationship/assurance axes (that would be MAJOR and is a second pass) and did NOT add a binding
        correlation-consent rule for the biometric uniqueness lever (documented as a privacy tradeoff in
        index.md; a governance revision deferred). This is the first design intent recorded for a captured
        (non-GCD) schema — face-to-face earns it because proof-of-personhood is strategically load-bearing.
      children:
        f2f proves humanness, not uniqueness; biometricHashes are the optional uniqueness lever = decision:
          id: uq5nw3
          stage-status: done
          why: >
            A face-to-face credential proves the subject is A human, NOT that they are a UNIQUE human — one
            person can hold many AIDs, each vouched by different friends, so f2f alone is Sybil-permeable. For
            "no AI allowed" that is often enough (we care that no AI participates, not that a human has one
            account); for one-human-one-vote / UBI it is not. Rather than bolt a uniqueness protocol onto f2f,
            the schema leans into the affordance it already has: biometricHashes. The SAME biometric hash
            appearing across many independent issuers' credentials is privacy-preserving evidence of ONE human
            — a decentralized dedup signal a verifier MAY use where uniqueness matters. The gap that blocked
            this was comparability: an unlabelled hash cannot be compared across credentials without knowing
            how it was computed. v1.2.0 adds the OPTIONAL biometricProtocol field naming the canonicalization +
            hash protocol, so two credentials' hashes are comparable iff they cite the same protocol. Chose a
            protocol pointer (additive, MINOR) over restructuring biometricHashes into typed objects (MAJOR,
            breaks existing string-array instances) — the protocol string carries the comparability
            information without changing the field's type. Accepted tradeoff: correlatable biometrics are a
            privacy cost (documented in index.md); a binding correlation-consent governance clause is deferred.
        Observation richness and in-person key-control are the android-resistance and human-key-binding levers = decision:
          id: ar6vk2
          stage-status: done
          why: >
            v1.1 captured the strength of the humanness observation only as minutes + a free-text basis, but
            the model rests on "ordinary human observation can tell a human from an artifact" — an assumption
            that DECAYS as embodied AI improves. Two additive fields make what a verifier is trusting explicit
            and weightable. modalities (array enum: visual, tactile, conversational, movement, sharedActivity,
            multiSession) records WHICH human-specific channels the issuer observed — the ones current AI
            embodiments cannot fake (a handshake, spontaneous unscripted conversation, a shared meal, natural
            gait, corroboration across separate occasions) — so a verifier can weight android-resistance, not
            just duration. keyControl (enum: signedChallenge | deviceControl) records whether the issuer
            watched the issuee DEMONSTRATE control of the AID in person — signing a fresh challenge with the
            key (strongest), or operating the device that holds it — upgrading "this person is human" to "this
            human demonstrably controlled this key in my presence," the strongest available defence against the
            "get vouched, then hand your keys to an AI" attack. Both optional; absence means "not attested,"
            never "false." Chose closed enums over free text so aggregators can reason over them, and kept them
            descriptive attestation detail (governed by noOverstatement) rather than minting new rules.
    proof-of-control 2.0.0 adopts the ACDC v2 envelope; 1.1.0 is archived = decision:
      id: 2n2vtee3
      why: >
        The same migration @enr3eg made for GCD, for the same driver and with the same mechanics, now
        that proof-of-control has an actual issuer. bakobo/merti issues email proof-of-control through
        heti, which is v2-first by recorded decision (heti @0nx0p6gd) and builds every ACDC as an
        acm/JSON field map carrying `rd`. The 1.1.0 schema required v1's `ri`, so NO credential heti
        can issue would ever have validated against it — verified by running heti's issuance path
        against it (2026-09-11): it failed on `ri`, then on a required `u` heti deliberately never
        mints, then on a required `a.d`. That is not a defect discovered by review; it is a schema no
        issuer had ever exercised, which is the cost of a corpus authored ahead of its first consumer.
        Envelope follows @enr3eg exactly: top-level order [v, t, d, u, i, rd, s, a, r]; `t` optional;
        the compact SAID-string arm stays FIRST in every oneOf, which the most-compact-form SAID
        algorithm keys on; the v1-era inner `$id` on the expanded a/r arms is dropped, since the v2
        idiom carries none. `a.d` becomes OPTIONAL for the reason @enr3eg measured and this work
        rediscovered independently before finding that node — the fork's `acdcmap` emits no `a.d`, so
        requiring it rejects every heti-built credential. `u` drops out of a.required for the parallel
        reason: heti mints no privacy nonce (@895yr58n), so a required nonce is unsatisfiable by the
        only issuer there is.
        THE ONE PLACE THIS DIVERGES FROM @enr3eg, deliberately: `rd` is OPTIONAL here, where GCD made
        it REQUIRED. That was not an oversight and the two are not inconsistent — @enr3eg's argument
        is specific to what a GCD is ("a GCD is authority evidence — its issuer is already public,
        secure registry discovery is exactly what a stranger-verifier needs", and "correlation-
        minimized delegation is not a GCD use case"). For proof-of-control every clause inverts.
        merti's @pxfdnc wants short-lived registry-free issuance as the DEFAULT, and its @g3lxeo
        treats a self-serve issuing site as a correlation honeypot to be designed against. So
        correlation minimization is precisely the use case, and the spec's own default (rd optional,
        spec-body.md :2019) is the right one to keep. This also means merti's tension @3y4oko can
        resolve toward rd-less issuance later without a third schema.
        MAJOR per @k3wm7d's RFC-0430 grading, since renaming `ri` invalidates every conceivable prior
        instance: 1.1.0 -> 2.0.0. Per @r5vk3n the old schema is archived byte-identical at
        proof-of-control-1.1.0/ with its SAID EO6WbKaHwNOalVVY5oHi4NaZWG5yynFIDCHpQACVPCw7 still
        resolvable in registry.json, and proof-of-control/ is rewritten with a fresh SAID
        EL8UCysa2vrg3pe1dg9UAe3mC3-C57DarB1vJVE38j0Y. Nothing external pinned the old one: it 404s at
        schema.bakobo.com, and Bakobo's OOBI catalog states it has incepted no organisational AIDs,
        so no credential anywhere references it. The negative corpus is repointed at the new SAID and
        each fixture re-verified to fail for the defect it is NAMED after rather than for the envelope
        — without that check the five fixtures would have kept passing while testing nothing.
        ACCEPTANCE ORACLE, run and passing: heti mints a facet, opens a registry, and issues against
        this schema end to end, producing a 470-byte genus-pinned acm ACDC and a 2095-byte IPEX grant.
        Deliberately NOT done here: example.json and a positive gallery. 1.1.0 shipped without either,
        so adding them is a separate improvement and not part of an envelope migration.

    proof-of-control 2.1.0 gains an optional validUntil, because expiry IS its revocation story = decision:
      id: 3j5lwc7w
      why: >
        1.1.0 and 2.0.0 carried `assertDate` — when the issuer asserts the control was fresh — and
        nothing saying when the assertion stops. For the credential's first real issuer that gap is
        not cosmetic: merti's @pxfdnc chose SHORT-LIVED AND REGISTRY-FREE precisely so that expiry
        substitutes for revocation ("if merti learns an issuance was wrong, the remedy is to wait out
        the expiry and refuse the renewal"), and merti's Issuer port already takes an `expires`
        argument it had nowhere to put. A schema whose only issuer cannot express its central design
        decision is the schema that is wrong. Found while writing that issuer's adapter, which is the
        second thing in two days that reading the schema did not surface and exercising it did.
        OPTIONAL, not required, and the corpus reason outranks the convenience: this repo serves any
        issuer's schema repo (@c5tj3p), and a proof-of-control that never expires is a coherent thing
        for a different issuer to assert. Absence means "the issuer set no horizon", never "valid
        forever" — the same absence-is-not-false discipline @ar6vk2 applies to f2f's optional levers.
        merti always sets it; that is merti's policy and belongs in merti's governance framework
        rather than in the shape everyone shares.
        Placed as a sibling of `assertDate` in the attribute block rather than inside a container.
        GCD reaches validUntil through `a.constraints.validUntil` with an if/then backstop (@enr3eg),
        but `constraints` is GCD's authority vocabulary and proof-of-control has no such container;
        borrowing the path without the structure would imply a kinship that does not exist.
        MINOR per @k3wm7d: adding an optional property invalidates no prior instance, so 2.0.0 ->
        2.1.0 and no archive is warranted. 2.0.0 existed for one commit and was never published or
        issued against, so it is superseded in place rather than preserved — @r5vk3n's archiving
        convention protects SAIDs somebody might hold, and nobody ever held this one.
        Oracle: the same end-to-end issuance as @2n2vtee3, now carrying validUntil, still passing.
    The rest of the v1-enveloped corpus migrates to ACDC v2, carrying the redesign the MAJOR already buys = decision:
      id: jruwvxnt
      stage-status: planned
      why: >
        DRIVER. Eleven of the sixteen live schemas are still v1-shaped — ai-coder, ai-user-coca,
        attestation, award, bindkey, citation, faa, face-to-face, org-vet, sedi-guardian, sedi-id — each
        carrying 'ri' rather than 'rd', v1 top-level ordering, no optional 't', v1-era inner '$id' on the
        expanded arms, and mostly a required 'a.d'. That is precisely the set of failures @2n2vtee3
        measured by running heti's issuance path against proof-of-control 1.1.0, so no credential heti or
        merti can mint validates against any of the eleven. Both prior migrations (@enr3eg for GCD,
        @2n2vtee3 for proof-of-control) were pulled by one named issuer; what changed on 2026-09-12 is that
        heti, imbu and merti reached the maturity where credentials can actually be issued, and Daniel
        chose to offer several of these as working demonstrators. Every schema here is now on a path to
        being issued rather than merely published, which turns @2n2vtee3's closing lesson — "a schema no
        issuer had ever exercised, which is the cost of a corpus authored ahead of its first consumer" —
        into a thing that would otherwise be paid eleven more times.
        SCOPE OF EACH MIGRATION. The envelope exactly as @enr3eg fixed it: top-level order
        [v, t, d, u, i, rd, s, a, (A), e, r]; 't' optional; the compact SAID-string arm FIRST in every
        oneOf, which the most-compact-form SAID algorithm keys on; the v1-era inner '$id' fields dropped.
        PLUS the four redesign axes decided in the children below, PLUS the house-style debt: @p6mwk4
        settled camelCase, obvious-abbrev and plural arrays long ago, and the inherited corpus never paid
        it (effective_dt, expire_dt, issuer_name, issuee_name, award_name, art_digest, art_posture,
        content_location, content_size, content_type, rev_latency), and citation's des/lbl/loc/sdt/siz/typ
        are past what "obvious-abbrev" carries. Field declarations are brought up at the same time: every
        property gets a type, a description that says what a verifier does with the value, a pattern or
        named format where the value has a shape, and examples where the pattern is not self-evident.
        WHY ALL OF IT AT ONCE, which is the decision a reviewer should attack. Renaming required 'ri' to
        'rd' invalidates every conceivable prior instance, so each migration is MAJOR per @k3wm7d's
        RFC-0430 grading no matter how little else changes. Every other breaking improvement is therefore
        free at this moment and expensive at any other. REJECTED an envelope-only sweep followed later by a
        design sweep: @r5vk3n mints an archived versioned directory per MAJOR, so two sweeps means two
        archive directories per schema and two full re-SAID cascades across registry.json, example.json,
        the examples/ galleries, the invalid/ corpora and every cross-pinned const — and it asks consumers
        to absorb two breaking changes where one would do. TRADEOFF ACCEPTED: a bigger blast radius per
        schema and a longer review per schema, against a corpus that reaches its settled shape in one pass.
        ENFORCEMENT LANDS FIRST, before any schema moves. 'schematools check' reported "0 problems across
        18 schemas" on 2026-09-12 with eleven unissuable schemas in the tree, because no check has an
        opinion about v1 versus v2 — a linter blind to the thing being fixed cannot say when the work is
        done, and cannot stop the twelfth schema from regressing. The envelope and house-style checks are
        added with the eleven failures marked xfail(strict=True) against their tick ids, the mechanism
        @n7xk4r's conformance suite already uses, so CI stays green and each migration flips one marker to
        XPASS and forces its removal.
        THE ENVELOPE CHECK IS A CONFORMANCE INVARIANT, NOT A PUBLICATION GATE. 'schematools publish' fails
        closed on any problem run_all reports, so adding the envelope check to that set would refuse to
        publish the whole site until the last of the eleven migrated — and would be wrong on the merits, not
        merely inconvenient. @r5vk3n keeps every superseded schema published BYTE-IDENTICAL AND FOREVER, so
        that a SAID somebody holds stays resolvable; gcd-1.0.0, gcd-2.0.1 and proof-of-control-1.1.0 are v1
        by design and must go on being served. A v1 envelope is therefore not a defect in the artifact being
        published — the schema is valid, SAID-correct, registered and resolvable — it is a statement about
        which issuer can mint against it. So the publication gate keeps the invariants that make a published
        artifact trustworthy (structure, SAID, registry, examples, the negative corpus) and the envelope
        check runs in 'schematools check' and the conformance suite, where the audience is a maintainer
        deciding what to work on rather than a stranger resolving a SAID.
        ORDER is by design load rather than field count, easiest first, because the early schemas are where
        the defaults below get tested against reality: attestation, bindkey, org-vet, citation, then
        ai-user-coca and ai-coder TOGETHER (ai-coder pins ai-user-coca's SAID as a const, so migrating one
        alone forces two re-SAID rounds), then award, faa, face-to-face. The SEDI family follows as its own
        tranche — sedi-id first, since sedi-guardian and sedi-present-age-portrait both pin its SAID, and
        sedi-guardian only after the unmerged sedi-guardian-no-gcd branch is settled. faa is held until the
        sedi-bridge question (tick 3nhn) is answered, because a foreign-artifact affidavit and a
        foreign-artifact bridge may be one credential and designing both is designing it twice.
      children:
        Every migrating schema declares 'u' in both slots; the aggregate section is for genuine subset disclosure only = decision:
          id: jsmu322m
          why: >
            heti's answer of 2026-09-14 (heti @8znj834r, @4trv8p9d, @4wyvymuw, @u75gb3uv) makes this the
            schema's decision and nobody else's: heti mints a privacy nonce into every slot the named
            schema DECLARES one for, and nowhere else, because the schema is where a credential's
            disclosure design already lives. Declaring is therefore the trigger for minting; requiring is a
            separate axis that governs what a DIFFERENT issuer may omit (@c5tj3p — this repo serves any
            issuer's schema repo).
            THE DRIVING CONSTRAINT, measured rather than assumed. heti's registry state is public this
            tranche (heti @895yr58n, its deferral standing on heti tick 7vhf), so the 'upd' event publishes
            the credential's SAID as 'td' in the clear. An observer who knows issuer, registry, schema and
            issuee confirms a guessed attribute by recomputing the SAID — heti has the row in its suite
            showing a guessed boolean reproducing the published td exactly. For a low-entropy credential
            that is the whole content. This is not hypothetical for the first two demonstrators: attestation
            asserts a digest of a document the observer may well hold, and bindkey binds a public key.
            DECISION. Declare 'u' at top level and in the expanded arm of 'a' on every migrating schema.
            The attribute-block 'u' goes in a.required; the top-level 'u' stays OPTIONAL, matching @enr3eg
            and @2n2vtee3. That asymmetry is deliberate and is the thing to disagree with: declaring is
            what makes heti mint, so an optional-but-declared top-level 'u' is minted anyway, and leaving
            it optional keeps the public variant expressible for a credential whose identity is meant to be
            public, without forcing an archive-triggering change on the two schemas already migrated.
            Requiring the attribute-block one costs the only issuer there is nothing, since heti fills it
            automatically, and stops a different issuer shipping an unblinded block silently.
            REJECTED leaving 'u' undeclared and carrying the obligation in a rules clause instead: a nonce
            is a field, not a promise, and a clause cannot blind a SAID. REJECTED requiring the top-level
            'u' as well, which buys no measured protection the attribute-block nonce does not already give
            and contradicts two recorded decisions.
            THE AGGREGATE SECTION is for credentials where a holder genuinely discloses a subset, and
            nothing else. Its cost, per heti: element 1 must be the issuee block and the schema MUST
            require it, expressed with prefixItems plus minItems, because SerderACDC.iseaid reads
            sad["A"][1]["i"] and returns None for a WITHHELD issuee block exactly as it does for a
            credential that never had one — so an unpinned schema lets a holder, or a thief holding a
            stolen copy, present a targeted credential as an untargeted affidavit. No block other than
            element 1 may carry 'i', since a party named at another index reads as untargeted to every
            keripy consumer. Every block is nonced unconditionally: in an aggregate the nonce is the
            structure and not a defence, because a withheld block travels as its bare SAID. sedi-age is the
            only current aggregate and fails the element-1 requirement today (tick 6grq); face-to-face is
            the only other candidate worth evaluating, since its biometric hashes and protocol identifiers
            disclose on a different axis from the meeting facts. The other ten stay attributive — an
            aggregate bought without a disclosure story is complexity with no holder behind it.
            ACCEPTED LIMIT, recorded so no schema's prose overstates it: correlation resistance stops at
            the field level. Issuance timing is public, every credential is its own anchored TEL event, and
            the issuer-holder pairing is inferable from the anchor sequence however well contents are
            blinded (heti tick 6zxo). A schema must not promise unlinkability the deployment cannot deliver.
        additionalProperties closes by default and opens only where a rules clause carries the fail-closed duty = decision:
          id: hoag7c7s
          why: >
            Resolves the posture @p3rk6d explicitly left open ("STILL OPEN ... flipping additionalProperties
            to false is a genuine MAJOR"), which is exactly the kind of change this migration exists to
            absorb. Three tiers rather than one rule. The top-level envelope CLOSES: the v2 'alls' set is
            the spec's vocabulary, not an issuer's, so an unknown top-level field is a protocol error, and a
            field a future spec version adds arrives with a schema version of its own under @k3wm7d's
            grading. Blocks with a fixed vocabulary CLOSE — the aggregate issuee block, threshold blocks,
            enum-gated containers — because an unknown key there is a typo or an attack, and accepting it
            silently is failing open where the Bakobo standard is fail closed. A block OPENS only where the
            schema advertises extension, and then only paired with a Ricardian clause carrying the
            fail-closed obligation on the verifier: the pattern @vy7qoj realized for GCD, whose
            noConstraintOutsideConstraints says an unrecognized key inside the container MUST be treated as
            unmet.
            REJECTED closing everything, which is the reading @k7wd3m made and @vy7qoj overturned on
            Daniel's own intent: a JSON-Schema validator's rejection is not the enforcement mechanism for a
            rule addressed to verifiers, and closing a container whose own prose invites extension makes the
            invitation a dead letter. REJECTED opening everything, which would let an unknown key ride in a
            block whose whole meaning is its fixed vocabulary.
            CONCRETELY this closes the six @p3rk6d named — ai-user-coca top-level, citation top-level, and
            the 'a' blocks of award, bindkey, face-to-face and org-vet. TRADEOFF ACCEPTED: a consumer
            relying on unknown-key passthrough breaks. Nothing in this corpus does, no released instance
            install base exists for these nine, and the MAJOR is being paid anyway.
        Every migrating schema carries a real rules section; a dangling r.d does not survive = decision:
          id: jnft7xse
          why: >
            The corpus is inconsistent here in a way nothing surfaces until you look: three schemas declare
            no 'r' at all (ai-user-coca, attestation, bindkey); three declare an 'r' whose expanded arm
            holds only 'd', with no rules.json on disk behind it (ai-coder, award, faa); the rest carry a
            compact string arm plus a real rules.json. A schema whose 'r' is a SAID slot with nothing behind
            it advertises governance it does not have, and no existing check catches it, because the linter
            validates the schema's structure rather than whether a referenced ruleset resolves.
            DECISION. 'r' is declared on every migrating schema, compact SAID-string arm first per @enr3eg,
            with a rules.json on disk whose SAID the schema references and which the re-SAID cascade
            recomputes. Minimum content is one scope clause naming what the credential does NOT assert —
            the noOverstatement pattern face-to-face and proof-of-control already carry — plus the
            fail-closed clause @hoag7c7s requires wherever a container is left open. 'r' goes in the
            top-level required list by default; a schema that omits it records why.
            THE ISSUER-SIDE DRIVER. heti's Registry.issue takes a rules mapping and every verdict surfaces
            that block as text, uninterpreted (heti @3pszqp). So the rules section is the only channel by
            which a credential tells a relying party what it means and what it does not, and a demonstrator
            with an empty one demonstrates a credential nobody can safely read.
            REJECTED one shared boilerplate ruleset SAID for the whole corpus, which would be cheaper to
            author and is wrong on both axes: the clause that matters is per-credential — "a bindkey does
            not assert the key is uncompromised" is not "an attestation does not assert the document is
            true" — and a shared SAID would make every schema's governance change together, so amending one
            credential's terms would re-SAID all of them.
        validUntil is the corpus's one spelling for a horizon, optional everywhere, with revocation left to the TEL = decision:
          id: pp4wv7pw
          why: >
            The corpus spells one concept four ways or not at all: ai-coder 'expire_dt', bindkey
            'startDate'/'stopDate', sedi-guardian 'expiryDate', proof-of-control 'validUntil' (@3j5lwc7w),
            GCD 'a.constraints.validUntil' with an if/then backstop (@enr3eg), and six schemas say nothing
            about when the assertion stops. One concept, one name — @p6mwk4's house style applied to
            semantics rather than casing: 'validUntil', with 'validFrom' where a start genuinely matters
            (bindkey's key lifetime does; ai-coder's effective_dt is the same thing under another name).
            OPTIONAL, never required, generalizing the reason @3j5lwc7w gave for proof-of-control: this repo
            serves any issuer (@c5tj3p), and a credential with no horizon is a coherent thing for a
            different issuer to assert. Absence means "the issuer set no horizon", never "valid forever" —
            @ar6vk2's absence-is-not-false discipline. An issuer that always sets one states that in its own
            governance framework rather than in the shape everyone shares.
            REVOCATION IS DELIBERATELY NOT MODELLED in any schema. heti issues into an 'upd' registry, so
            every credential it mints is revocable without the schema saying anything, and heti refuses to
            anchor an aggregate as a bare 'acg' precisely to keep that available (heti @4trv8p9d). Expiry is
            the complement for the registry-free short-lived case merti chose (merti @pxfdnc), not a
            substitute for the TEL — a schema field asserting revocation status would be a claim the
            credential cannot keep current, which is the failure the TEL exists to avoid.
            GCD IS THE RECORDED DEPARTURE and stays as it is: its horizon lives in a.constraints.validUntil
            because 'constraints' is GCD's authority vocabulary and the if/then backstop ties it to
            terminatingEvents. @3j5lwc7w already reasoned that borrowing that path without the structure
            implies a kinship that does not exist; the same holds in reverse, so GCD is not flattened to
            match the others.
        attestation 2.0.0 is the first migration, and the first test of the defaults; 1.0.0 is archived = decision:
          id: 4t5t4yca
          why: >
            The first schema migrated under @jruwvxnt, and chosen first (tick 5mk3) precisely because it is
            the smallest — 5 fields, already camelCase, no cross-pinned SAIDs — so the four default nodes
            would meet a real schema before nine more were designed against them. Everything below either
            applies a default or records the one place it does not fit.
            ENVELOPE per @enr3eg: order [v, t, d, u, i, rd, s, a, e, r]; 't' declared and optional; the
            v1-era inner '$id' dropped from the a and e arms. One addition beyond a rename: 1.0.0's 'a' was a
            BARE OBJECT with no oneOf at all, so the credential could not compact — there was no
            SAID-string arm for a most-compact form to collapse to. The compact arm is added, first in the
            oneOf, for a and e alike.
            'rd' is OPTIONAL, diverging from @enr3eg's GCD and following @2n2vtee3. @enr3eg's argument for
            requiring it is specific to authority evidence that a stranger-verifier must discover a registry
            for; an attestation is a statement about content at a time, the registry-free short-lived variant
            merti chose (@pxfdnc) is coherent for it, and heti carries 'rd' on every credential it issues
            anyway (heti @89kk7cft), so requiring it would constrain only the issuers that are not heti.
            'a.d' is OPTIONAL for the reason @enr3eg measured — the fork's acdcmap emits none — and 'a.u' is
            REQUIRED per @jsmu322m. That requirement is load-bearing here rather than formulaic: the
            attributes block's entire content is a digest and a datetime, and an observer of an attestation
            is very often someone who already HOLDS the attested content, so an unblinded block is
            confirmable by exactly the party the credential is most likely to be shown to.
            UNTARGETED, confirmed rather than assumed. 1.0.0's index.md states it outright ("there is no
            issuee"), so no 'a.i' was added even though heti's Registry.issue can insert one. The consequence
            is deliberate: a targeted issuance against this schema fails validation, because a data
            attestation is an affidavit about content and has no party to be about.
            RULES per @jnft7xse, where 1.0.0 declared no 'r' at all. Three clauses, and 'r' is required at
            top level: digestOnly (the credential commits to a digest and nothing else — a verifier that has
            not recomputed it over content it holds has verified nothing about that content);
            noContentAssertion (the issuer attests the digest was computed over content it observed, not that
            the content is true, lawful, complete, or fit for anything); absenceIsNotFalse (@ar6vk2's
            discipline, named here because validUntil makes it concrete). The texts live in ONE place: the
            build reads the schema's own 'const' values back out to generate rules.json, so the block and
            the schema cannot drift apart the way a hand-copied clause eventually does.
            'validUntil' optional per @pp4wv7pw. FIELD QUALITY per @jruwvxnt: faa's house SAID/AID pattern
            applied to d, i, rd, s and a.d, and its digest pattern to 'digest'. 'u' is deliberately left
            UNPATTERNED — a salty nonce is a 24-character 0A-coded primitive, and the 44-character SAID
            pattern would have rejected every nonce heti actually mints. A constraint that cannot be checked
            against the issuer is worse than none.
            THE 1.0.0 EXAMPLE IS NOT ARCHIVED, and that is the finding rather than an oversight. Its 's' named
            EB4AsU1rKGOAf7m4MS324XhanXq8G01sR_bUdUV2TULm — not this schema, and in no registry — so it had
            never been saidified against the schema it claimed to instantiate. It survived because it was
            called example-attestation.json, and all three positive checks key on example.json, which is the
            silent skip @jruwvxnt's rename convention exists to end. Archiving it would preserve a defect, so
            attestation-1.0.0/ carries the schema and index.md only, following proof-of-control-1.1.0.
            ACCEPTANCE ORACLE, run and passing at BOTH levels. The probe @enr3eg used: a credential built by
            the fork's acdcmap(israid, uuid, regid, schema=<new $id>, attribute={u, dt, digest},
            rule=<rules>) validates against the schema under Draft 2020-12 with format assertion on. And the
            stronger one @2n2vtee3 used, run 2026-09-15 because @jsmu322m's required 'a.u' rests on a claim
            about heti rather than about this repo: heti mints a facet, opens an upd registry, learns this
            schema and issues against it end to end, reporting nonced slots ('u', 'a.u') — so heti DOES fill
            a nonce into a block whose schema requires one, and the default is safe for the nine schemas
            designed after this one. Two things that run measured which reading could not. heti emits the
            attribute block in the order [dt, digest, u], appending the nonce it mints rather than following
            the schema's declaration order, which is harmless under JSON Schema but would matter to anything
            comparing serializations. And heti's own facet AID came back E-prefixed, which is the first real
            evidence that the [BE] pattern applied to 'i' accepts what the only issuer actually mints —
            heti validates a credential against the schema BEFORE anchoring, so a wrong pattern would have
            refused the issuance rather than passing quietly. The negative corpus is REBUILT from that instance, one
            mutation each, and every fixture verified to fail for the defect it is NAMED after rather than
            for the envelope — the check @2n2vtee3 added after finding repointed fixtures can keep passing
            while testing nothing. Four are new and exist to give this node's decisions a failing oracle:
            a missing block nonce (@jsmu322m), a missing rules section (@jnft7xse), a mis-shaped digest (the
            new pattern), and an instance carrying v1's 'ri' (the migration itself).
            MAJOR per @k3wm7d, since renaming 'ri' invalidates every conceivable prior instance: 1.0.0 ->
            2.0.0, new SAID EE5FA0uE3ydhSYrG8lqECgR0Ad3NpkQxPw0b3jp-2eDa, with the old
            EJxFPpyDRV-W6O2Vtjdy2K90ltWmQK8l1jePw5YOo_Ft kept resolvable in registry.json per @r5vk3n.
            Nothing pinned the old SAID: no other schema references it and it has no recorded issuer.
        bindkey 2.0.0 is public by design, so it takes the nonce default's opposite; pubkey gains keyFormat = decision:
          id: v5ma6uxn
          why: >
            The second migration (tick 4jwa), and the first to depart from a default in the direction of LESS
            privacy — which is what makes it a useful test of whether @jsmu322m is a rule or a reflex.
            NO NONCE, IN EITHER SLOT, and no compact arm. Both honor an intent 1.0.0 already recorded in its
            own $comment ("intentionally public and untargeted ... don't support compaction"), and both
            invert @jsmu322m's driver rather than ignoring it. That driver is an observer confirming a guess
            about a credential's contents by recomputing its published SAID; here being confirmable by
            anyone who knows the issuer and the key IS the function, so blinding would defeat the credential
            rather than protect it. Rejected adding a compact arm "for consistency with @enr3eg": that rule
            says a compact arm must come FIRST where one exists, not that every section must have one, and
            manufacturing a withheld form for a public announcement would invite presenting a bindkey that
            asserts nothing. MEASURED, not merely intended: heti issues this schema reporting nonced slots
            (), so the departure is real at the issuer and not just in prose.
            'rd' is REQUIRED, the opposite of @4t5t4yca's call for attestation, and the schema's own
            description settles it: "Issuing this ACDC makes key binding provable and REVOKABLE". A key
            binding nobody can withdraw is a claim that outlives the facts, and a compromised key needs a
            public retraction as much as it needed a public declaration. The two credentials differ because
            what they assert differs, which is the shape @2n2vtee3 established for this question.
            'dt' is REQUIRED, and the reason is MEASURED rather than assumed. heti's schemas.py documents
            _ENVELOPE = ("d", "u", "i", "dt") as "the attribute-block keys heti fills in itself when it
            issues", but an issuance omitting dt was REFUSED by heti's own pre-anchor schema validation. That
            matches heti's credentials.py, which says the issuance datetime is "the credential's own word ...
            never invented and never read off a clock here" — so the docstring overstates and the ENVELOPE
            constant is about which keys a caller need not be prompted for, not which heti supplies. The
            corpus consequence: dt is the issuer's own statement, and the caller provides it.
            'startDate'/'stopDate' become 'validFrom'/'validUntil' per @pp4wv7pw. 1.0.0's wording already
            carried the right semantics ("if missing, stops only on revocation"), so this is the corpus
            converging on one spelling, not a change of meaning.
            PUBKEY GAINS A keyFormat DISCRIMINATOR — Daniel's decision, 2026-09-15, taken because the
            migration surfaced a contradiction between the schema and its own documentation. index.md
            motivates the credential with SPF/DKIM/DMARC, which want RSA keys, while the schema typed pubkey
            as format "cesr"; the pinned fork's MtrDex carries Ed25519 and ECDSA 256k1/256r1 and NO RSA code
            (verified against the pin, not recalled). So the schema could not express the case it was
            designed around. pubkey becomes a plain string and a REQUIRED keyFormat enum
            (cesr | spki-der-b64 | pem | openssh | jwk) says how to read it, each member answering a use the
            schema already advertises: spki-der-b64 is literally what DKIM publishes in the DNS p= tag, and
            openssh answers the 'ssh' the uses examples have always listed.
            REQUIRED rather than defaulted, which deviates from the sketch the decision was taken on: a JSON
            Schema 'default' is an annotation that nothing applies, so an absent keyFormat would leave two
            readers free to parse the same key differently — failing open on precisely the ambiguity the
            field exists to close. NO PATTERN is asserted on pubkey, and that restraint is deliberate: four
            of the five encodings cannot be tested here against a real issuer of that format, and @4t5t4yca
            paid for the general version of this lesson with the privacy nonce, where the SAID pattern would
            have rejected every nonce heti actually mints. The discriminator's job is to tell a reader how to
            parse; enforcing the encoding belongs to the parser, failing closed per @vy7qoj.
            A fifth rules clause, unknownFormatFailsClosed, carries that obligation in Ricardian text — what
            @hoag7c7s requires wherever meaning can arrive that the schema did not anticipate. The case is
            not hypothetical: a later version naming a sixth format would otherwise be silently misread by a
            verifier built against this one.
            RULES per @jnft7xse, where 1.0.0 declared no 'r' at all: five clauses, 'r' required at top level.
            additionalProperties CLOSED on the attribute block per @hoag7c7s — bindkey's 'a' was one of the
            six @p3rk6d left open.
            ORACLES, both run and passing. The fork's acdcmap builds an acm that validates; and heti mints a
            facet, opens an upd registry, learns this schema and issues the DKIM case end to end — a real
            2048-bit RSA public key as spki-der-b64 — reporting nonced slots (). examples/dkim-rsa.json is
            that same case, carried in the gallery the linter validates (@g4tn7w), so the motivating use is
            a checked artifact rather than a paragraph.
            1.0.0's example is NOT archived, for the reason @4t5t4yca established and 1.0.0's own index.md
            states outright — it was "an informal example (that looks plausible but won't verify)", and it
            does not: its 'v' is the string "1.0", which is not an ACDC version string, and its SAIDs are
            decorative. MAJOR per @k3wm7d: 1.0.0 -> 2.0.0, new SAID
            EAwWdh1p_JlRUn35GjvueqljM5w-tQCe3XWIc52k0pyC, with EFvHYHX0cUx9sdjxZOr9fpPcQKdzRNFH42D8R29p7lAH
            kept resolvable in registry.json per @r5vk3n.
        org-vet 2.0.0 gets governance of its own, an issuee, and a bounded loa; 1.0.0 is archived = decision:
          id: kdndo6dc
          why: >
            The third migration (tick 4a4i), and the one where the envelope was the least of it: three
            things this schema's own documentation claimed were either absent from the schema or contradicted
            by it. None was caught by any check, because every check here validates shape and SAIDs rather
            than whether a credential says what it says it says.
            THE GOVERNANCE FRAMEWORK BELONGED TO ANOTHER CREDENTIAL. org-vet/rules.json was BYTE-IDENTICAL to
            citation/rules.json — four clauses entirely about citations ("the citation, in and of itself,
            only commits the issuer to point at content in a way that makes the issuer and the target
            verifiable") — and the schema pinned that ruleset's SAID as a const on 'r'. So an org-vet's
            binding terms, the thing @jnft7xse calls the only channel by which a credential tells a relying
            party what it means, were a disclaimer about pointing at content. Replaced with four clauses of
            its own — loaIsTheIssuersProcedure, noClaimBeyondTheTier, lidsAreReferencesNotAssertions,
            assuranceIsPointInTime — each traceable to a sentence index.md's own LoA table already contained.
            THE INDEX.MD GOVERNANCE SECTION BELONGED TO A THIRD CREDENTIAL. It cited rules SAID
            EFthNcTE20MLMaCOoXlSmNtdooGEbZF8uGmO5G85eMSF, which is GCD's pre-@k3wm7d ruleset and is not the
            SAID org-vet actually pinned; it referred to a 'gfw' field org-vet does not have; and it closed
            with "the act of issuing or receiving a GCD credential constitutes binding acceptance of the
            rules". Three wrong things in one paragraph, all copy-paste inherited at the hard fork (@q3nv6t).
            THE CREDENTIAL WAS UNTARGETED WHILE ITS PROSE SAID IT WAS TARGETED. index.md: "It is issued to a
            cryptographic identifier controlled by the org, allowing the org to authenticate itself on the
            basis of the credential." The attribute block had no 'i', so there was no org to issue it to and
            nothing for a presentation to bind to. 'a.i' is added and REQUIRED. That is the third schema in
            three migrations whose prose and shape disagreed (@4t5t4yca's untargeted-but-broken example,
            @v5ma6uxn's RSA that CESR could not carry), which is a finding about the corpus rather than about
            any one schema: it was documented aspirationally and never exercised by an issuer.
            'loa' AND 'lids' BECOME REQUIRED. A credential titled "Authenticate an org with an explicit level
            of assurance" left the level of assurance optional, so a conforming instance could assert nothing
            its own title promises. 'lids' follows at one remove: every tier in the LoA table begins by
            proving that a non-cryptographic identifier references a real, non-defunct org, so a vet carrying
            no references records no vetting.
            'loa' IS BOUNDED to [1, 4], where 1.0.0 accepted any number at all including zero and negatives.
            index.md defines exactly four tiers and explicitly blesses fractional values within one
            (2.1 < 2.2), which is why the type stays 'number' rather than becoming an integer enum. A fifth
            tier later only raises the ceiling, which invalidates no existing instance and is MINOR under
            @k3wm7d — so the bound costs nothing that a future tier could not undo cheaply.
            The rest is the defaults applying cleanly. Nonce in both slots with 'a.u' required (@jsmu322m),
            and this is the most guessable attribute block in the corpus — a short list of public identifiers
            and a number between 1 and 4 — so confirmation by recomputation against the registry's published
            SAID is available to anyone who cares to try. 'rd' REQUIRED as for @v5ma6uxn and for the reason
            its own assuranceIsPointInTime clause states: an assurance level speaks to a state of affairs
            that changes, and an issuer's duty to revoke is empty without a registry to exercise it in.
            additionalProperties CLOSED at top level and on 'a' (@hoag7c7s) — two more of @p3rk6d's six.
            FIRST EXAMPLE EVER. org-vet was the only family in the corpus with no positive example on disk,
            so check_examples, check_example_refs and check_example_saids all had nothing to look at and
            reported clean. example.json is built by the fork's acdcmap and is now SAID-checked like the rest.
            ORACLES, both run: the fork-built acm validates under Draft 2020-12 with format assertion, and
            heti mints a facet, opens an upd registry, learns this schema and issues against it end to end,
            reporting nonced slots ('u', 'a.u').
            MAJOR per @k3wm7d: 1.0.0 -> 2.0.0, new SAID EJ5HgojIGN2_R9TzhCgnYe9NhNHxfWY0MkENZcs1CRZa, old
            EJvwY9n7EsJ4ZejUBHFrnrNammC8BkGI9YaW1Wnp5c22 kept resolvable per @r5vk3n. The archive keeps
            rules.json, UNLIKE the archives at @4t5t4yca and @v5ma6uxn where the old example was dropped as
            defective: the 1.0.0 schema pins that ruleset's SAID as a const, so an archive without it would
            not resolve. Preserving the citation clauses there is not endorsing them; it is keeping a
            published SAID answerable, which is the whole of what @r5vk3n asks.
        citation 2.0.0 spells its field names out and keeps rd optional, because its own rules say why = decision:
          id: ydh7zk6r
          why: >
            The fourth migration (tick 7bdk), and the first schema that was already well designed — its
            content block carried a salty nonce years before @jsmu322m argued for one, and its index.md
            "Semantic precision" section is the most carefully reasoned prose in the corpus. So the work here
            was naming, the envelope, and two decisions its own governance already implied.
            THE NAMES. @p6mwk4 retrofits terse fields "when they next get a version bump", which is now:
            des -> description, typ -> contentType, lbl -> label, siz -> sizeBytes, loc -> locationHint,
            sdt -> snapshotDt. 'dt' stays, because docs/style.md's abbreviation glossary already carries it.
            Two of the old names fail @p6mwk4's obviousness test on COLLISION rather than terseness ('des'
            reads as the cipher, 'loc' as lines-of-code or locale), and three fail its amputation rule rather
            than its abbreviation rule: a content type is not a type, a size in bytes is not a size, and a
            location HINT is emphatically not a location — the field's own description spends a paragraph
            insisting the issuer guarantees nothing about it, and the name now carries that instead of
            burying it. Nothing was added to the canonical abbreviation list, because this migration removes
            abbreviations rather than coining them.
            'rd' STAYS OPTIONAL, and uniquely here the credential's own governance settles it rather than an
            argument from outside. The undefinedRevocation clause says "there is no defined relationship
            between the revocation status of a citation and that of cited data" — so requiring a registry
            would compel machinery whose meaning the ruleset deliberately refuses to fix. Contrast @v5ma6uxn,
            where bindkey's description SELLS revocability and so requires it. The pattern across four
            migrations: what a credential says about itself decides this field, not a corpus-wide default.
            UNTARGETED, like attestation and for a stronger reason: index.md says citations "resemble
            affidavits more than credentials; they have no issuee, and do not prove entitlement", and
            useViaEdges makes a citation a node that OTHER ACDCs point at. So it needs no 'e' block of its
            own either, and none was added.
            THE RULES BLOCK WAS CORRECT AND STAYS BYTE-IDENTICAL. This is the credential org-vet's ruleset
            was stolen from (@kdndo6dc), and here the four clauses are about citations because they were
            written for citations. rules.json is unchanged, so SAID
            EM6kWxMNL9BFm0ReegqQfNJLw8OZAfn2ZxcjWs4Ceifh resolves for both versions — but the schema now
            EMBEDS the clause texts as consts in a v2 oneOf 'r' block rather than merely pinning the SAID
            with a const string, which is the corpus idiom and makes the texts part of the schema's own SAID.
            The build asserts the embedded texts equal rules.json exactly and that rules.json is a saidify
            fixed point, so the two cannot drift.
            index.md's Governance Framework section was the SAME copy-paste defect @kdndo6dc found in
            org-vet, verbatim: GCD's pre-@k3wm7d rules SAID, a 'gfw' field citation does not have, and "the
            act of issuing or receiving a GCD credential constitutes binding acceptance". Two schemas is a
            pattern, so assume the remaining inherited families carry it too and check that paragraph in each.
            Daniel's own prose above it is untouched.
            MEASURED AT THE ISSUER, and this one is new: heti does NOT mint a nonce into a NESTED block. It
            fills the top-level 'u' and the attribute block's 'u' — the two depths its answer named — so
            citation's required a.content.u must be supplied by the caller. The first issuance attempt failed
            on exactly that, which is the value of running the oracle rather than reasoning about it. No
            schema change follows: content.u was required in 1.0.0 too, blinding it is right (cargo is often
            a digest of content the observer already holds), and a caller that wants a nested blinded block
            can pass one. Worth heti knowing; it is a gap in reach, not a defect.
            Field quality otherwise: sizeBytes gains minimum 0, contentType gains faa's house media-type
            pattern, snapshotDt keeps its format assertion, and an optional validUntil lands per @pp4wv7pw.
            additionalProperties CLOSED at top level and on both the 'a' and 'content' blocks (@hoag7c7s) —
            citation's top-level 'true' was another of @p3rk6d's six.
            ORACLES: the fork-built acm validates; heti issues end to end reporting nonced slots ('u', 'a.u');
            and examples/social-media-post.json rebuilds the 1.0.0 example's scenario as a real v2 instance in
            the gallery the linter validates (@g4tn7w). The 1.0.0 example itself is not archived — it is a v1
            artifact of a schema whose SAID it never matched, the same disposition as @4t5t4yca's.
            THE NEGATIVE CORPUS EXPOSED A FLAW IN HOW THE PREVIOUS THREE WERE VERIFIED. Fixtures are checked
            to fail for the defect they are NAMED after (@2n2vtee3), and the checker used for @4t5t4yca,
            @v5ma6uxn and @kdndo6dc walked only ONE level of oneOf context and matched on the keyword alone,
            so a nested failure could have matched a coincidental sibling error. Citation's content block is
            two oneOf levels deep, which surfaced it. The checker now walks the whole error tree and requires
            keyword AND path; all 53 fixtures across the four migrated schemas were re-verified under it and
            all 53 still fail for their named reason, so nothing was papered over — but the earlier three were
            verified more weakly than their nodes claim, and this records that.
            MAJOR per @k3wm7d: 1.0.0 -> 2.0.0, new SAID EKzRBzCdp2t0iKuHMSNAa-EaJdULjmEJTJ6zR1DlzuQq, old
            EDH3Q0MW6oCcwyYw2MN39n1YfPs37o1QEv86kB-fBzmh kept resolvable per @r5vk3n.
        ai-user-coca and ai-coder 2.0.0 migrate as one unit, because one pins the other's SAID = decision:
          id: xuq4lelk
          why: >
            The fifth migration (tick 6e3q), and the first that had to move TWO schemas in one re-SAID
            round: ai-coder's e.coca edge pins ai-user-coca's schema SAID as a const
            (properties/e/oneOf[1]/properties/coca/properties/s/const), so migrating either alone would
            leave a dangling constant and force a second cascade. coca is saidified first and ai-coder's
            const is repointed at the result in the same build.
            ai-user-coca IS PUBLIC AND SELF-ISSUED, so it takes bindkey's departure from @jsmu322m rather
            than the default: no nonce in either slot, on the same reasoning @v5ma6uxn recorded — its
            index.md calls it "a public declaration, not a credential", and a declaration nobody can
            confirm does no work. Measured: heti issues it reporting nonced slots ().
            AND IT DROPS a.i, WHICH 1.0.0 REQUIRED. The credential attests that THE ISSUER is committed to a
            code of conduct "with respect to their personal use of AI" — the issuer declaring something about
            itself, so there is no issuee and nothing for a.i to name. 1.0.0 described that field as "AID of
            issuee (award recipient)", which is award's wording, and the top-level i as "Identifier of the
            issuer (the one giving the award)" — so the field was copy-paste rather than a considered
            decision, and removing it is the schema finally matching its own first sentence. 'rd' is REQUIRED
            for @v5ma6uxn's reason: a public commitment that cannot be withdrawn outlives the issuer's
            willingness to stand behind it.
            ai-coder TAKES THE DEFAULTS STRAIGHT: nonce declared in both slots with a.u required, because the
            attribute block names a licensed person and an unblinded block lets anyone watching the registry
            confirm a guess about who was licensed; 'rd' required, because a licence the issuer cannot revoke
            confers privileges it can no longer stand behind; effective_dt/expire_dt -> validFrom/validUntil
            and issuer_name/issuee_name -> issuerName/issueeName per @p6mwk4 and @pp4wv7pw.
            BOTH RULES SECTIONS ARE NEW, and ai-coder's was the worst case @jnft7xse describes: its 'r'
            expanded arm declared 'd' alone with additionalProperties true, so it accepted ANY content as a
            ruleset while advertising governance, and its shipped example pointed 'r' at
            EGhkNqT1LbfYlimCBMsorDt7PpeGKYdOdj6hKpUjrqtB — FACE-TO-FACE's ruleset. Between this, org-vet
            carrying citation's ruleset (@kdndo6dc), and the GCD governance paragraph pasted into both
            org-vet's and citation's index.md (@ydh7zk6r), the inherited corpus's governance was wired
            essentially at random. ai-coder now carries licenseNotGuarantee, namesAreConvenience and
            privilegesEndAtTheHorizon; coca carries commitmentNotCompliance, referencedCodeMayChange and
            selfAsserted. Every clause is grounded in a sentence one of the schemas or its index.md already
            contained — the privileges clause, for instance, just makes binding what expire_dt's own
            description always said ("issuer stops managing revocation").
            ai-coder's index.md WAS ABOUT AWARDS. All five "notable features" bullets described the award
            credential's optional category, timeframe, citation and image — none of which exist in ai-coder's
            schema. Rewritten. That is the fourth distinct copy-paste defect in the inherited corpus and the
            first in a Purpose-adjacent section rather than a boilerplate one.
            coc1.json IS NOT AN EXAMPLE, which the tick for this work assumed it was. It is the recommended
            CODE OF CONDUCT itself — a saidified document whose SAID index.md tells issuers to place in
            'coc'. So coca had no example instance at all, like org-vet, and now has one; coc1.json is
            untouched and its SAID still resolves.
            A NEW ENVELOPE FACT, found the same way @ydh7zk6r found the nested-nonce one: the fork's acdcmap
            emits NO block SAID for an EDGE section, exactly as @enr3eg measured for the attribute section.
            ai-coder's chained gallery example failed against its own schema until e.d was made optional. GCD
            has the same shape and still requires e.d, so an edge-bearing GCD built by the only builder there
            is would fail its own schema — latent, since GCD's 'e' is optional and no example carries one.
            Recorded as tick 5xm4 rather than fixed here, because GCD is already migrated and a quiet edit to
            a shipped schema is a re-mint by stealth.
            ORACLES: fork-built acms validate for both; heti issues both end to end, reporting nonced slots
            () for coca and ('u', 'a.u') for ai-coder; and ai-coder/examples/chained-to-coca.json carries the
            e.coca edge into the gallery the linter validates (@g4tn7w), so the pinned const is exercised by
            an artifact rather than asserted in prose.
            MAJOR for both per @k3wm7d. ai-user-coca 1.0.0 -> 2.0.0, new SAID
            EHReayB8hE1jqYEr418Hxh_najdMS8UExEG4G6Ris3MO, old EBCnd7qk82wLBOgFukdmsdkksAuPpmzt5-eg9YKWWP3j
            archived per @r5vk3n; ai-coder 1.0.0 -> 2.0.0, new SAID
            ELIEUVwNAk1z-_jJJ9BuUtQw-c3TY-RvcQyYw5dI4_JK, old EPhWFgeOy8g7yRy-Xtyvbdieqvl_3YVXNHMgTEZuJOWh
            archived. Neither archive keeps its example: coca never had one, and ai-coder's was a v1 artifact
            whose rules pointer was wrong anyway.
        award 2.0.0 keeps its rules optional and open, and ships its disclosure layers as prose = decision:
          id: wfr34gwm
          why: >
            The sixth migration (tick 272l), and the first schema whose own documentation overrides one of
            @jruwvxnt's defaults on a reasoned basis rather than a historical accident. Award is also where
            the corpus's copy-paste trail ends: ai-coder's award-shaped index.md (@xuq4lelk) and its
            face-to-face rules pointer were both copied FROM here, and award's own prose is the original and
            is good — the graduated-disclosure section is real design thinking, not boilerplate.
            THE RULES SECTION STAYS OPTIONAL AND OPEN, against @jnft7xse's default that 'r' is required and
            enumerates its clauses. Award's index.md states the position and the reason: "Very formal awards
            like the Oscars, the Nobel prize, or an Olympic medal may have carefully defined rules; casual
            employee recognitions may have no strong rules about acceptance or usage." An award's terms
            belong to its ISSUER in a way that an attestation's or a licence's do not, so a schema that
            enumerated clauses would be legislating for the Oscars and the employee-of-the-month board
            alike. The expanded 'r' arm therefore requires only 'd' and keeps additionalProperties TRUE.
            THE COST OF THAT, STATED PLAINLY: @hoag7c7s requires that openness be paired with a Ricardian
            fail-closed clause, and here the schema CANNOT enforce the pairing, because it deliberately does
            not own the vocabulary. The mitigation is the coc1.json pattern borrowed from ai-user-coca — a
            RECOMMENDED baseline ruleset is published at award/rules.json for an issuer to reference by
            SAID, and it carries unrecognizedClauseFailsClosed along with recognitionNotPrivilege,
            namesAreConvenience and imageByReferenceMayChange. An issuer that writes its own ruleset takes
            on stating the fail-closed rule itself, and index.md says so. Rejected requiring 'r' with a
            fixed vocabulary (legislates for every issuer), and rejected shipping no baseline at all (leaves
            every issuer to rediscover that an award confers no privilege).
            recognitionNotPrivilege is index.md's own sentence made binding: "Awards do not necessarily
            confer privileges ... A particular verifier can decide to confer privileges based on the award,
            if they wish." A verifier that grants something on the strength of an award owns that decision.
            GRADUATED DISCLOSURE SHIPS AS PROSE, WITH NO PARTIAL-DISCLOSURE EXAMPLE, and this is the
            substantive finding of this migration rather than a formatting choice. Award's design puts the
            identifying material (issueeName, citation, image) in a nested 'details' block with its own
            nonce, so a holder can prove the award without proving the name — three layers: compact, partial
            (details as a SAID), full. Attempting to SHIP the partial layer as a checked artifact failed.
            MEASURED on the pin, and CORRECTED the same day after a first reading that was wrong: disclosure
            invariance DOES hold. acdcmap(compactify=True) on an award whose 'a' and 'a.details' mappings
            carry a 'd' SLOT yields a credential whose sections collapse to their SAIDs with a top-level
            SAID identical to the expanded form's. The first probes all omitted that slot, so nothing could
            compact and the SAID necessarily differed — and @enr3eg had already recorded the governing fact
            ("a d-less a section is fully expanded during most-compact computation while a d-bearing one
            compacts"). The mistake was mine, not the fork's, and it is left visible here because the
            corrected version is the one a later reader needs and the wrong one was briefly acted on.
            WHAT SURVIVES is the half that decides this migration: heti passes a caller's attributes
            straight through and supplies no 'd' slot, so a heti-issued credential is NON-COMPACTABLE and
            cannot be partially disclosed at all. Award's middle layer is therefore unreachable for the only
            issuer there is, which is a heti question rather than a keripy one. Two narrower things may be
            defects or may be misuse, and are recorded on tick 2zqx rather than asserted: acdcmap leaves a
            caller-supplied 'd' slot as the empty string on the wire when compactify is False, and
            Compactor's said for a block differs from the one the most-compact computation uses for that
            same block while sectattr refuses any block whose 'd' is not already correct. Award therefore takes @sd2qfw's disposition
            for sedi-id under the v1 oracle — layers described in prose, not published as files that the
            oracle would reject — and index.md says outright that the partial layer is a design intent the
            schema is shaped for rather than a form a holder can present today.
            THAT FINDING REACHES PAST AWARD. @jsmu322m decided the other ten schemas "stay attributive"
            partly because attributive graduated disclosure was assumed to work; face-to-face and the whole
            SEDI family lean on it. It is a question for heti and keripy, not one to reverse-engineer
            further from this repo.
            The rest is the defaults applying. Nonce in both slots with a.u required and details.u required
            (@jsmu322m) — load-bearing here, since the whole design is about withholding a name. 'rd'
            OPTIONAL, unlike @v5ma6uxn and @kdndo6dc: nothing in award's text promises revocability the way
            bindkey's description does, and a casual recognition issued registry-free is coherent.
            award_name/issuer_name -> awardName/issuerName, issuee_name -> issueeName, effective_dt ->
            validFrom (@p6mwk4, @pp4wv7pw); validFrom also drops OUT of a.required, since @pp4wv7pw's
            "absent means on issuance" makes requiring it redundant. additionalProperties closed on 'a' and
            on 'details' (@hoag7c7s) — award's 'a' was another of @p3rk6d's six. The edge block's 'd' is
            optional per @xuq4lelk's finding.
            ORACLES: the fork-built acm validates, and heti mints a facet, opens an upd registry and issues
            end to end reporting nonced slots ('u', 'a.u'). MAJOR per @k3wm7d: 1.0.0 -> 2.0.0, new SAID
            EM00uWV5K7YtTt5dDWH2diXCGtDhQlrWHsLPT5WKh-Pc, old EBxJHMk6MOEUogB6A1rP5x9te7DscPfxFfUGJCkq1Lq5
            kept resolvable per @r5vk3n. The 1.0.0 example is not archived: its 'r' pointed at
            face-to-face's ruleset, the same defect ai-coder's example inherited from it.

    Schema-authoring tooling is deferred, pending a TypeScript-vs-Python decision = decision:
      id: p4zc7n
      stage-status: planned
      why: >
        public-schema's Python machinery (tools/: saidify_schema, saidify_sad, register_all, check_schemas,
        and a small serving api) is copied verbatim as a REFERENCE to replicate in concept — NOT adopted as
        the committed toolchain. The target is undecided: pure browser-compatible TypeScript (so high-quality
        browser-based schema DESIGN and client-side SAIDification / validation tools become possible) versus
        staying Python (reuse the working machinery as-is). Driver for the open question: the desire for
        browser-based schema-design tooling and client-side validation. Deferred deliberately rather than
        decided now; the copied tools/ are PROVISIONAL and must not be treated as load-bearing. The
        Dockerfile / docker-compose / schema-registry-deployment coupling from public-schema was NOT copied
        (Provenant deployment infra, out of scope for a schema-authoring repo).
    Schema correctness is guaranteed by tooling that GCD's own needs pull into existence = goal:
      id: tq5wnh
      stage-status: in-progress
      why: >
        The near-term need — evolving GCD — could be met by hand-editing the schema and re-running the
        inherited Python saidify (quick-and-dirty). Chose instead to treat GCD as the FIRST CUSTOMER and
        FORCING FUNCTION for real schema tooling: every capability the tooling grows is PULLED by a concrete
        GCD need, not pushed speculatively as a framework. The discipline that keeps "pulled" from collapsing
        back into "quick-and-dirty" is conformance-suite-first — the checks that assert a schema is correct are
        written and made to pass BEFORE the tool that must satisfy them, so the tests are the spec and the
        tooling is the derived artifact (methodology §6, applied to schemas). Rejected the opposite ordering
        (build the browser editor / test framework / CD pipeline as a standalone program first, then use it on
        GCD) because it blocks GCD indefinitely and gold-plates against guessed rather than observed needs.
        Tradeoff accepted: the tooling grows incrementally and may look under-built at any snapshot; we accept
        that in exchange for every piece being justified by a real schema it had to serve. This resolves the
        urgency-vs-rigor tension: GCD ships well AND soon because doing it well IS the mechanism, not a
        competing goal.
      children:
        keripy is the SAID conformance oracle; any reimplementation is differential-tested against it = decision:
          id: xv4m7d
          why: >
            A schema's $id is a SAID: a Blake3 digest over canonically-serialized, saidified content, and the
            ENTIRE KERI/ACDC ecosystem verifies credentials against keripy's computation of it. So the
            load-bearing constraint on any tooling here is not "which language" but "whatever computes a SAID
            must be byte-identical to keripy, permanently." Consequence: the inherited Python tool
            (keri.core.coring.Saider / scheming.Schemer) is not legacy-to-replace — it is the CONFORMANCE
            ORACLE and stays regardless of what else is built. Any future reimplementation (e.g. a browser-side
            TypeScript saidifier via signify-ts / cesride) is therefore not a port but a consensus-critical
            reimplementation that MUST be differential-tested against keripy on every commit, because its
            failure mode is silent — a SAID that is 99.9% right simply fails to verify with no error. Rejected
            treating keripy as one interchangeable option among language choices; the oracle role is fixed and
            the language of the AUTHORING / EDITING layer is a separate, still-open question (@p4zc7n). This is
            the specific fact that de-risks the eventual browser dream: client-side saidify is a library call
            against a vetted CESR lib IF that lib is proven byte-compatible with keripy — which the differential
            test is exactly there to prove.
        Near-term schema work and the MVP checks proceed in Python now; the TS-vs-Python target stays deferred = decision:
          id: s6bq2w
          why: >
            Task 1 (repair GCD's invalid JSON and re-SAIDify) is urgent and needs A saidifier now; the inherited
            Python tools already work and keripy is the oracle we keep regardless (@xv4m7d). Chose to do Phase-1
            work — the GCD JSON repair, the MVP checks (SAID-integrity, registry-consistency, example-validation),
            and their CI wiring — in Python now, rather than first resolving the TS-vs-Python target (@p4zc7n) and
            building the chosen toolchain before touching GCD. Driving reason it costs us nothing strategic: the
            SAID-integrity check we write in Python IS the specification any future TS tool must also pass, so no
            work is thrown away by the language choice — we are writing the conformance suite first (@tq5wnh), in
            the oracle's own language. Tradeoff accepted: this lightly entrenches Python for the CI / oracle
            layer (approved by Daniel, 2026-07-11); the browser / TS authoring layer remains deferred and
            unprejudiced, since it would be differential-tested against exactly these Python-authored checks.
            Rejected blocking Task 1 on the language decision — it inverts urgency for a decision Phase 1 does
            not need to make.
        A schema's tests decompose into repo-wide linter invariants plus per-schema instance fixtures = decision:
          id: n7xk4r
          why: >
            Defining what "a test for an ACDC schema" MEANS, because it is the external contract the whole
            tooling program derives from. A schema's correctness decomposes into two lifecycles: (1) REPO-WIDE
            INVARIANTS true of every schema — a linter — comprising valid JSON + valid Draft-2020-12,
            SAID-integrity (recompute the SAID and assert it equals the embedded $id — the KEYSTONE, and the
            single check that would have caught GCD's inherited broken state; absent today), registry-consistency
            (every SAID indexed, path correct, no orphans), ACDC-convention conformance (compact/expanded oneOf,
            a/e/r blocks, d/i/s/ri patterns, edge operators), and referential integrity (edges resolve to
            schemas that exist); and (2) PER-SCHEMA INSTANCE FIXTURES — a runner — comprising positive
            (example.json validates), negative (a golden should-fail corpus is rejected — the part that is
            actually "testing"), semantic / business invariants not expressible in JSON Schema (e.g. GCD's
            c_-prefix rule), and evolution / regression (a new version leaves the old intact and still
            validating its old examples). Chose this two-axis decomposition over treating "schema testing" as a
            single undifferentiated validator because the two axes have different lifecycles (invariants are
            global and cheap; fixtures are per-schema and grow with each type) and because it ORDERS the work:
            SAID-integrity + registry-consistency + positive-example are the Phase-1 MVP that Task 1 needs
            anyway, while negative corpora, semantic rules, and regression are pulled in as GCD's evolution
            requires them. The browser editor and CD-publish are consumers of this contract, not part of it.
          children:
            The positive axis extends to an examples/ gallery the linter validates, not just one example.json = decision:
              id: g4tn7w
              stage-status: done
              why: >
                @n7xk4r's positive axis was realized as a single per-schema example.json (validated for
                schema-validity, s-vs-$id reference, and SAID self-consistency). GCD v2.0 has enough distinct
                features (four relationTypes, three exerciseModes, the voiding/outbound sibling axes, duties) that
                one example cannot show them; a set of scenario examples (guardianship, AI delegation, a pure
                delegator, ...) is worth shipping as documentation. Chose to let a schema ALSO carry a
                <folder>/examples/ gallery of full, valid instances and to GENERALIZE the three positive checks
                (check_examples, check_example_refs, check_example_saids) to validate every gallery file exactly as
                they validate example.json — so a didactic example that drifts (an invalidated instance, a stale s,
                a broken SAID) fails CI like any other, keeping the human showcase and the machine gate the same
                list (the repo's standing generated-vs-hand-written discipline, @f7dr3k/@z5nc4d/@c5nq7d). Chose a
                validated gallery over illustrative fenced code blocks in index.md (which carry placeholder SAIDs
                and rot silently) and over a bespoke per-gallery check (the existing positive checks already
                express the contract; generalizing them avoids a second source of truth). example.json stays the
                ONE canonical instance; the gallery is additive and optional, so schemas without one are
                unaffected. Prompted by a request for feature-showcase examples.
            The negative axis lands as a per-schema invalid/ corpus that a check proves is rejected = decision:
              id: n6dqw2
              why: >
                Realizing @n7xk4r's negative (golden should-fail) axis — the part that actually TESTS a schema
                rather than lints it. Chose a per-schema ``<folder>/invalid/*.json`` directory of full-instance
                fixtures, each one mutation away from a valid instance, plus a repo-wide ``check_negative_examples``
                that asserts every fixture is REJECTED and reports any the schema ACCEPTS as a too-permissive
                defect. Chose full-instance-minus-one-mutation over minimal violating stubs because a single
                isolated defect is legible ("this differs from valid by exactly one thing") and mirrors how the
                positive example.json is authored; chose a plain directory (filename carries intent, since JSON
                has no comments) over a manifest with per-fixture metadata because the check only needs "reject or
                not" and a manifest is a second source of truth to drift. Fixtures were authored by probing the
                REAL Draft-2020-12 validator (not by eyeballing), so the shipped corpus contains only fixtures the
                schema genuinely rejects today — 49 across the 11 registered schemas, covering missing-required,
                wrong-type, null, additionalProperties, const/enum, regex pattern, min/minItems/uniqueItems, and
                edge-operator violations. Scope boundary held: the corpus covers only violations expressible AND
                asserted in JSON Schema — it does not cover ``format`` (date-time/uri/cesr are annotation-only and
                NOT asserted by the checker; see the defect node), semantic/business rules (@n7xk4r's third axis),
                or SAID integrity (the fixtures carry deliberately-bogus SAIDs and are seen only by this check,
                never by the SAID/example checks). Tradeoff: the corpus grows by hand per schema, but that is the
                nature of the fixtures axis and the check makes a missing/weak corpus visible rather than silent.
            Building the negative corpus surfaced five schema defects; fixing them is deferred (re-mint decision) = tension:
              id: d7km4v
              stage-status: partially-resolved
              why: >
                Authoring should-reject fixtures against the real validator exposed five pre-existing defects
                inherited/introduced in the schemas — recorded here so they are tracked, not silently absorbed,
                and deliberately NOT fixed in the same unit of work because every one changes a schema's bytes and
                therefore its SAID, cascading to registry.json, the example's ``s``, and re-SAIDification (@xv4m7d,
                @tq5wnh) — a re-mint that is Daniel's call, not a lint cleanup. The defects: (1) face-to-face
                ``a.minutes`` uses ``exclusiveMin`` and (2) proof-of-control ``a.be`` uses ``exclusiveMin`` — NOT
                a Draft-2020-12 keyword (the correct spelling is ``exclusiveMinimum``); as written the keyword is
                ignored, so ``minutes``/``be`` of 0 or negative are wrongly ACCEPTED. (3) proof-of-control lists
                ``minutes`` in its attributes ``required`` but defines no such property — only ``be`` — so the
                required list looks copy-pasted from face-to-face; a correct instance per the intended design
                (``be`` present, no ``minutes``) is wrongly rejected. (4) face-to-face ``a.basis`` pattern
                ``^[-a-z0-0 ]+$`` has a range typo ``0-0`` (a single character, "0") where ``0-9`` was meant, so
                the schema rejects its OWN documented example values ("nist-ial1".."nist-ial3") and any basis
                containing a digit 1-9. (5) faa attributes constrain a ``content_identifier`` property with a SAID
                regex, but ``required``/the example use ``art_digest`` (unconstrained) — the constrained property
                is dead and the used one is unvalidated; a bogus ``art_digest`` is accepted. Also surfaced, but
                classed as design choices to review rather than defects: top-level and ``a``-level
                ``additionalProperties: true`` on several schemas (ai-user-coca top, citation top, award/bindkey/
                face-to-face/org-vet ``a``) let unknown fields through; and ``format`` assertion is off repo-wide
                (date-time/uri/cesr unchecked). Resolution stance: when Daniel approves a re-mint, fix 1-5, add
                the now-enforceable negatives (minutes<=0, be<=0, bad art_digest) to the corpus, and separately
                decide the additionalProperties / format-assertion posture; until then these live as tick entries.
              children:
                Defects 1-5 fixed as a re-mint; each fix is MINOR (adds precision), not a breaking change = decision:
                  id: p3rk6d
                  why: >
                    Daniel approved the re-mint (2026-07-13). Fixed all five: (1)+(2) ``exclusiveMin`` ->
                    ``exclusiveMinimum`` on face-to-face ``minutes`` and proof-of-control ``be``; (3)
                    proof-of-control ``required`` now lists ``be`` (the defined field, confirmed intended by its
                    own index.md §"the `be` field in the schema") instead of the phantom ``minutes``; (4)
                    face-to-face ``basis`` pattern ``0-0`` -> ``0-9``; (5) faa renamed the orphan constrained
                    property ``content_identifier`` -> ``art_digest`` so the SAID-shape regex lands on the field
                    that is actually required and used. Chose to give each fix a MINOR ``version`` bump
                    (1.0.0 -> 1.1.0) over PATCH or MAJOR, applying @k3wm7d's RFC-0430 grading: every change ADDS
                    PRECISION (enforces an intended bound, widens ``basis`` to the documented digit set, or
                    constrains a live field) without invalidating any legitimately-valid instance — the shipped
                    examples all re-validate — so none "breaks trust" (MAJOR) and none is a mere cosmetic/no-op
                    (PATCH). Each edit changes the schema bytes, so the full cascade ran: re-saidify schema (new
                    ``$id`` and nested block ``$id``s), rebuild registry.json, set each example's ``s`` to the new
                    schema SAID and re-saidify the example (new ``d``/block-``d``s/``v``), and regenerate the three
                    schemas' negative corpora from now-valid bases — adding the three negatives the bugs had made
                    unenforceable (face-to-face minutes<=0, proof-of-control be<=0 and missing-be, faa bad
                    art_digest). No cross-schema ``const`` referenced these SAIDs (only ai-coder->ai-user-coca,
                    untouched), so the blast radius stayed inside the three folders + registry. Tradeoff of MINOR
                    over MAJOR: a consumer pinning only the major version sees tightened validation without a
                    major signal — accepted because no real credential is invalidated and the schemas carry no
                    released-instance install base yet. STILL OPEN (not part of this re-mint): the
                    additionalProperties posture and repo-wide ``format`` assertion — deferred to their own
                    decision because flipping additionalProperties to false is a genuine MAJOR (breaks graduated-
                    disclosure extensibility) and format assertion needs a dependency + a checker change.
        Tooling stays in this repo, generic in shape, until a second consumer justifies a split = decision:
          id: c5tj3p
          why: >
            This repo has a latent second identity: not just bakobo's schema corpus but potentially publishable
            schema TOOLING any credential issuer could use. Chose to keep the tooling IN THIS REPO, written
            generic in SHAPE (operating over a configured schema directory with no bakobo-specific hard-coding),
            rather than either (a) splitting it into its own repo now, or (b) letting it hard-code bakobo
            assumptions for expedience. Decisive reason against an early split: the schemas ARE the tooling's
            test corpus — co-location is the natural state, and a split would force cross-repo version
            coordination for a tool with exactly one consumer today. Generic-in-shape-but-in-repo keeps the
            eventual extraction cheap (a clean boundary is the reversible direction) WITHOUT paying the split's
            coordination cost before a second consumer exists. This resolves the corpus-vs-product tension for
            now: we pay for the split when it bites (a real second consumer), not on speculation. It also
            reframes the "open-source it as a product" question as one of release cadence / packaging (a later
            concern) rather than open-vs-closed — the repo is already OSS-intended (Apache fork; GCD is imbu's
            keystone).
        Tooling is laid out as tools/py (now) and tools/ts (reserved); the inherited scripts become oldtools = decision:
          id: w3kp6m
          why: >
            The inherited public-schema tooling (tools/) is provisional (@p4zc7n) and not the committed
            toolchain. Chose to (a) rename it to oldtools/ — kept as a faithful REFERENCE, not deleted, so the
            original saidify / register / check logic stays inspectable — and (b) build the new committed tooling
            under tools/py/ as a clean, uv- and pytest-native Python package, RESERVING tools/ts/ as the sibling
            namespace for the future browser / TypeScript layer whose language is still deferred (@p4zc7n,
            @xv4m7d). Chose the tools/py|ts split over a flat tools/ (which would force an awkward rename or
            intermixing when the TS layer arrives) and over scattered top-level dirs (which would fragment the
            tooling identity). This makes @c5tj3p's "generic-in-shape, extract-when-a-second-consumer-appears"
            concrete: the Python oracle layer and the eventual browser layer are siblings under one tools/ tree,
            each independently packageable. tools/ts/ is NOT created empty now (YAGNI); the load-bearing part is
            the CONVENTION that Python tooling lives under tools/py/ rather than a bare tools/.
        keri is pinned to ==1.2.13, verified SAID-identical to the corpus's minting version = decision:
          id: m4vd7s
          why: >
            keri is the SAID oracle (@xv4m7d), so its version is load-bearing — a keri that serialized or
            digested differently would silently change every SAID. The inherited tools ran against keri 1.1.33
            (the version the 10-schema corpus was minted under). Chose to pin keri==1.2.13 rather than stay on
            1.1.33, AFTER empirically verifying (2026-07-11) that 1.2.13 recomputes byte-IDENTICAL SAIDs for all
            10 currently-valid schemas — so the bump carries the 1.1→1.2 line's fixes without invalidating any
            existing SAID or credential. Tradeoff accepted: 1.2.x resolves to a newer Python and emits some
            cosmetic upstream SyntaxWarnings, taken in exchange for not shipping tooling pinned to an
            unreasonably old runtime. The pin is EXACT (==), not a range, because "the oracle" must be a single
            reproducible version; any future bump REQUIRES re-running the same SAID-identity check as a gate.
          children:
            The oracle pin moves to the bakobo/keripy fork at heti's exact commit, re-gated differentially = decision:
              id: h3or4x
              why: >
                GCD's ACDC-v2 revision (tick 25ra, @enr3eg) needs an oracle that can stamp v2 instances, and
                keri 1.2.13 cannot: it rejects the v2 'rd' field and version strings outright, and v2 computes
                the top-level 'd' over the MOST-COMPACT form where 1.2.13 digests literal content (@sd2qfw).
                Reimplementing most-compact SAIDs inside schematools would be exactly the consensus-critical
                reimplementation @xv4m7d forbids without a differential oracle. Chose to move the pin
                keri==1.2.13 -> keri @ git+https://github.com/bakobo/keripy@a3118956 (keri 2.0.0.dev6, the
                EXACT commit bakobo/heti pins), after running the gate @m4vd7s itself prescribes (2026-08-15):
                the full check suite under the fork over the whole corpus — schema $ids byte-identical, every
                v1 example still a saidify_sad fixed point — plus the entire 218-test schematools suite at
                100% branch coverage, zero failures. Also measured before deciding: under the fork,
                saidify_sad is ALREADY a correct fixed point on v2 acm instances (the fork's SerderACDC makify
                does most-compact computation, and the top-level 'd' is invariant to whether r.d carries its
                real SAID or the dummy) — so the bump is a dependency change, not a code change. Rejected
                waiting for a RELEASED keri v2 (tick 2nd5's trigger): it blocks 25ra indefinitely while heti
                already ships on this fork, and pinning heti's own commit keeps one oracle lineage across
                bakobo repos. Rejected extending the @sd2qfw dodge to GCD (make 'v' optional, ship unversioned
                examples): it would publish the FLAGSHIP's reference artifacts as not-actually-v2 (no version
                string, 'd' not most-compact) in a repo whose whole point is SAID-verified reference
                artifacts, and it contradicts the heti-measured silhouette, which requires 'v'. The pin stays
                EXACT in the sense that matters — a git commit is a single reproducible version; any future
                move re-runs this same gate. Consequences accepted: requires-python rises to >=3.14,<3.15
                (keri 2.0.0.dev6's floor), uv.lock regenerates, CI fetches 3.14 via uv; the fork is public,
                so CI needs no credential (no PAT, no App). Deliberately NOT done here: lifting @sd2qfw for
                sedi-age — its examples stay as authored and tick 2nd5 stays open (now unblocked in
                principle) — because that is sedi scope, not 25ra.
                RE-GATED 2026-09-13: the pin moves a3118956 -> a1f2f32b (keri 2.1.0-dev0), again following
                heti's own commit, and again through the gate this node's last sentence demands rather than
                as a bare version bump. Results: `schematools check` reports 0 problems across all 18 schemas,
                so every $id is byte-identical under the new fork, and the schematools suite is 237 passed at
                100% branch coverage. The old commit is an ancestor of the new one, so this is movement along
                one lineage rather than a change of oracle. Occasioned by heti answering bakobo/schema's
                nonce-and-aggregate handoff, where a stale pin reference would have sent the corpus's
                disclosure design against an oracle heti no longer runs.
        schematools surfaces a coded, catchable error at the repo-root boundary, not a raw traceback = decision:
          id: b3kq7w
          stage-status: done
          why: >
            find_repo_root raised a bare FileNotFoundError with a lowercase fragment, so a user who ran
            schematools outside a schema repo got a raw Python traceback — the "something went wrong" failure the
            Bakobo error-handling standard (dev/standards/error-handling.md) forbids: no stable code, no
            permanent/transient signal, no complete sentence. Introduced SchemaRepoNotFoundError (subclass of
            FileNotFoundError, so existing callers and tests that catch FileNotFoundError still work) carrying a
            stable BK_NO_SCHEMA_REPO code and a complete house-voice message that names what failed, states
            permanence (retrying the same location will not help), and is actionable (run inside a schema repo or
            pass --root at one). The CLI entry point catches it and prints the message to stderr with a non-zero
            exit instead of a traceback. Chose to subclass FileNotFoundError over a standalone exception (preserves
            the existing catch contract) and over merely rewording the message (leaves no stable symbolic code for
            a caller to branch on — the standard's load-bearing axis 1). This is the first coded error in
            schematools and sets the pattern for the rest of the toolchain. Prompted by review finding HSX-F1.
        Bakobo-authored schema fields follow a house style — camelCase, obvious-abbrev, plural arrays = decision:
          id: p6mwk4
          why: >
            ACDC schemas mix naming styles — a terse lowercase envelope (v / d / i / s), snake_case customs
            (c_goal, effective_dt), and camelCase rules clauses (noRoleSemanticsWithoutGfw) — so authoring a
            schema without a house style re-creates that inconsistency, and because a field name is part of the
            SAID, fixing a name later forces a re-SAIDify plus a cross-repo prose churn. Adopted one style for
            Bakobo-authored DOMAIN fields (the members of a / e / r beyond the ACDC envelope):
            (1) camelCase — the JSON default, and already what imbu writes for the facet (relationType,
            obligationBearer, presentsAs, exerciseMode), so it REDUCES cross-repo friction rather than adding it;
            (2) expressive by default, but an OBVIOUS abbreviation is preferred over the full word — "obvious" =
            understood with no legend AND no collision with a well-known other meaning (so juris / phys / virt /
            val / proto pass; dom is rejected for the HTML-DOM collision → domain). An abbreviation SHORTENS a
            word; it never DROPS one: stateKind stays, because "kind" alone amputates the load-bearing "state" —
            abbreviate freely, amputate never;
            (3) array-valued fields are PLURAL, the plural taken of the English word before abbreviating (goals,
            effects, stateKinds, protos, proofs, physGeos, virtGeos, juris);
            (4) the terse ACDC envelope and block SAIDs (v / d / u / i / ri / s / a / e / r, block d) are FIXED by
            ACDC and NOT restyled — their terseness earns its keep because they are universal and, in the compact
            form, are all that ships, whereas domain field names appear only in the EXPANDED form and so cost
            nothing on the wire.
            Rejected "just strip the c_ prefix" (keeps cryptic pgeo / upto / ical), rejected fully-spelled names
            (verbose — the container already contextualizes, so constraints.juris needs no legalJurisdiction), and
            rejected pure-ACDC terseness for domain fields (unreadable, and the compact-form argument for envelope
            terseness does not apply to a-block attributes). The consistency mechanism is a canonical abbreviation
            glossary in docs/style.md (authors ADD to the list, never invent ad hoc), which is also the future
            spec for a schematools check_naming lint (@n7xk4r). Applies to schemas going FORWARD and to GCD v2.0
            (@b6xh4m); existing schemas' snake_case fields are retrofitted only when they next get a version bump,
            never repo-wide-renamed now.
          children:
            Array-field abbreviations must be clearly plural; juris is reversed to jurisdictions = decision:
              id: n4wq7t
              stage-status: done
              why: >
                This node's parent why (@p6mwk4) illustrated the pluralize-then-abbreviate rule with `juris` for
                jurisdiction(s), but authoring GCD v2.0 (@k7wd3m) found `juris` fails the rule's own intent: a bare
                `juris` does not read as a plural, so an array field cannot be told from a scalar by its name.
                Reversed the illustrative choice — the shipped schema field, docs/style.md rule 4, and the negative
                corpus all use `jurisdictions`; the glossary drops the jurisdiction->juris row. Chose to record the
                reversal as this child node over editing @p6mwk4's why in place, because the why is a dated record of
                what was decided then and rewriting it would falsify the audit trail (methodology §4); a superseding
                child keeps both the history and a single authoritative go-forward name. Format-label plurals
                (`icals`) remain the one accepted exception, since the label is not abbreviated at all. Rejected
                keeping `juris` (diverges from the shipped field and fails the plural-clarity test the parent rule
                itself states) and silently diverging doc-from-tree (the divergence the review flagged as CON-F2).
        The full surfaced tooling program is scoped far beyond the near-term need = tension:
          id: g6dm2v
          why: >
            Recording the FULL surfaced program so deferral is explicit, not amnesia: a schema unit-test
            framework, an in-browser schema editor, CI-driven checks, CD publication of schemas to a website,
            and open-sourcing the tooling as a product for other issuers — collectively a multi-quarter effort
            surfaced in the 2026-07-11 planning discussion. The tension is between this ambition and the
            near-term need (GCD). Resolution stance (not a full resolution): everything beyond the Phase-1 MVP
            (@n7xk4r) is PULLED by real GCD needs (@tq5wnh) and, until pulled, lives as tick entries so it is
            tracked but unbuilt. The browser editor specifically is gated on the keripy-byte-compatibility
            question (@xv4m7d) and the TS-vs-Python decision (@p4zc7n); CD-to-website is gated on there being
            stable released schemas worth publishing. Left OPEN deliberately — this node exists so a future
            reader sees the whole intended surface and why only a slice of it was built first, rather than
            rediscovering the ambition from scratch.
          children:
            The CD-to-website slice ships now as a machine-first static site on GitHub Pages = decision:
              id: pv6k3d
              why: >
                Approved 2026-07-13: the schemas are stable enough (post-re-mint, all valid, registry
                consistent) to publish, so the CD-to-website slice of @g6dm2v is now PULLED. Chose a
                MACHINE-FIRST static site served from GitHub Pages with the source set to GitHub Actions
                (justified over deploy-from-branch in the 2026-07-13 discussion: every artifact below is
                GENERATED and must be linted before publishing — branch-deploy can do neither). "Machine-first"
                means the load-bearing output is resolvable JSON — each schema at a stable folder URL and each
                as a SAID-addressed OOBI — with human-browsable HTML layered on top (@z5nc4d), never the other
                way round, because the whole point of an ACDC schema registry is content-addressed resolution,
                not documentation. Canonical host: schema.bakobo.com (DNS CNAME -> bakobo.github.io, verified).
                The build is FAIL-CLOSED: the conformance linter runs first and nothing publishes if any schema,
                registry entry, example, or negative fixture is broken (the org's fail-closed principle applied
                to publication). This node also establishes the reusable PATTERN the repo wants other ACDC
                schema publishers to copy (registry + per-SAID OOBI + a .well-known discovery manifest), which is
                why the generation lives in the generic tooling (@c5tj3p), not in one-off workflow YAML.
              children:
                Instance validation asserts formats repo-wide via the non-GPL checker; cesr stays unchecked = decision:
                  id: f4mt6k
                  why: >
                    ``format`` (date-time, uri, ...) is annotation-only in JSON Schema unless a checker is passed,
                    so until now a malformed ``dt`` or ``content_location`` URI validated clean — the input-
                    validation gap flagged in @d7km4v. Chose to enable format ASSERTION in both instance checks
                    (positive examples and the negative corpus) by passing ``Draft202012Validator.FORMAT_CHECKER``,
                    backed by the ``jsonschema[format-nongpl]`` extra (rfc3339-validator for date-time,
                    rfc3986-validator for uri) — the NON-GPL extra deliberately, since the default ``[format]``
                    pulls GPL ``rfc3987`` and this repo is Apache-2.0 in a DCO/LF context. Verified before adopting
                    that all eight positive examples still validate clean under assertion (including citation's
                    4-digit fractional-second ``sdt``), so nothing breaks. Chose to leave ``cesr`` UNCHECKED (an
                    unknown format is ignored by the checker) rather than register a validator, because "valid
                    CESR" spans many primitive types and defining the rule — and deciding whether to lean on keri's
                    Matter for it — is its own decision not forced by this change; the SAID-shaped fields that
                    matter already carry explicit ``pattern`` regexes (faa). Tradeoff: cesr-format typos still pass
                    until that rule is defined. The additionalProperties posture from @d7km4v remains separately
                    open (flipping to false is a MAJOR break of graduated-disclosure extensibility).
                schematools publish emits the machine site — raw schemas + /oobi/<said>.json + a .well-known manifest = decision:
                  id: o6bw3k
                  why: >
                    Chose to move site assembly OUT of the workflow YAML and INTO a tested ``schematools publish``
                    command (100% branch coverage like the rest of the toolchain), because the assembly is real
                    logic (OOBI generation, manifest generation, curation) that must be unit-testable and runnable
                    locally, not shell glue that only executes in CI. ``publish --out DIR`` lints (fail closed),
                    then writes: every schema at ``DIR/<name>/<name>.schema.json`` (+ examples + icons) for
                    browsable folder-URL resolution; ``DIR/registry.json``; a byte-identical OOBI copy of each
                    schema at ``DIR/oobi/<said>.json``; a discovery manifest at ``DIR/.well-known/acdc-schemas.json``
                    (base URL + per-schema {said, name, title, version, schema-path, oobi-path, governance-SAID
                    if any}); ``DIR/CNAME``; and a generated ``DIR/index.html`` registry landing. OOBI URL scheme:
                    ``/oobi/<said>.json`` — chose the ``.json`` extension (proper application/json, browsable) over
                    an extension-less ``/oobi/<said>`` (canonical KERI form but served as octet-stream on static
                    Pages), because WE advertise the OOBI URLs (in the manifest and registry) so ecosystem tools
                    consume what we publish, and OOBI resolution SAID-verifies the body regardless of Content-Type
                    — the extension is cosmetic to the security model. Tradeoff: a tool that blindly constructs
                    ``{host}/oobi/{said}`` without extension gets octet-stream, not our file — accepted because the
                    manifest is the intended discovery path and the folder-path JSON also resolves.
                    WELL-KNOWN (2026-07-14, revised twice): first deploy 404'd on ``/.well-known/acdc-schemas.json``
                    while ``/registry.json`` served, and I WRONGLY concluded GitHub Pages can't serve ``.well-known``
                    and moved the canonical manifest to a root path. That was wrong: GitHub Pages' CDN serves
                    ``.well-known`` fine — WebOfTrust does it (``weboftrust.github.io/.well-known/host-meta.json`` and
                    ``/.well-known/oobi/`` both 200, via deploy-from-branch + Jekyll ``include: [".well-known"]``).
                    The ONLY barrier was ``actions/upload-pages-artifact``, which tars the site with
                    ``--exclude=".[^/]*"`` (stripping top-level dot-entries) and exposes no option to disable it.
                    Chose to STOP using that action and build the ``github-pages`` artifact ourselves — a plain
                    ``tar`` of ``_site`` excluding only ``.git``, uploaded via ``actions/upload-artifact`` under the
                    name ``github-pages``, then the unchanged ``deploy-pages`` — so ``.well-known`` ships. Rejected
                    forking the action (a maintained dependency + supply-chain surface for what is three lines of
                    tar) and rejected switching to deploy-from-branch (a gh-pages branch + committed build output,
                    more moving parts, loses the clean Actions source). With that, the CANONICAL manifest is again
                    ``/.well-known/acdc-schemas.json`` (web standard + aligns with the KERI ecosystem's
                    ``.well-known/`` convention); a byte-identical non-dot alias ``/acdc-schemas.json`` is kept as a
                    convenience and a fallback. Verified locally that our tar contains ``./.well-known/...``; the live
                    200 is confirmed on the next deploy.
                Zensical renders the human HTML chrome, layered over the machine site, not load-bearing = decision:
                  id: z5nc4d
                  stage-status: in-progress
                  why: >
                    Chose Zensical (the Material-for-MkDocs team's successor; pip ``zensical``, currently 0.0.50 —
                    NOT the 0.5 first assumed) for the browsable HTML, over hand-rolled HTML or classic MkDocs,
                    because the per-schema ``index.md`` narratives are already Material-flavored and Zensical is the
                    maintained line. Kept it strictly LAYERED and non-load-bearing: the machine site (@o6bw3k) is
                    complete and deployable without any HTML, and Zensical only upgrades the per-schema pages —
                    chosen so a Zensical breakage or API churn can never take down schema resolution. Integration
                    shape: the build generates a ``docs/`` tree (a landing page + each schema's ``index.md`` and
                    assets) and a ``zensical.toml``, runs ``zensical build`` to HTML, and merges it over the machine
                    site. Left ``stage-status: in-progress`` because Zensical is young (0.0.x) and getting the nav /
                    asset-path / dotdir (``.well-known``) handling right is iterative; the site ships on the machine
                    layer meanwhile. Config lives at repo root (``zensical.toml``) per the tool's convention, an
                    accepted minor exception to "derived artifacts stay under tools/".
                    NAV (2026-07-14, from the live site): each schema is generated as ``<name>/index.md`` — a page
                    IN its folder, so its committed relative links to the schema JSON and icons resolve unchanged.
                    That makes Zensical render each as a collapsible SECTION (folder + toggle + index child), which
                    Daniel rejected: he wants one plain link per schema. ``navigation.indexes`` alone did NOT
                    flatten it (the toggle/nested item persisted). Chose an EXPLICIT ``nav`` in zensical.toml
                    mapping each label straight to ``<name>/index.md`` — an explicit entry to a single file renders
                    as a flat page link (no section, no toggle) while the page still lives in its folder so links
                    resolve. Rejected the flat-``<name>.md`` alternative: it renders flat but relocates the page to
                    the docs root, so Zensical rewrites the committed relative links to ``../<name>.schema.json``
                    (points at root, 404). Tradeoff: the explicit nav is hand-maintained — adding a schema needs
                    one nav line — accepted because it is the idiomatic MkDocs/Zensical control and schemas are
                    added rarely; the coupling is noted in zensical.toml and belongs in the future CONTRIBUTING.
                A federation layer indexes OTHER ACDC schema registries, from a committed federation.json = decision:
                  id: f7dr3k
                  why: >
                    A goal of the site is to make the WHOLE ACDC schema ecosystem more discoverable, not just
                    bakobo's own schemas (2026-07-14). Research (three web/GitHub agents + live verification) found
                    no existing cross-ecosystem index and no other publisher with a browsable registry+manifest like
                    ours — peers are either source-only or OOBI-only. So bakobo can be the FIRST cross-ecosystem
                    index and the reference for the discovery pattern. Chose LAYER 1 first: a hand-edited committed
                    ``federation.json`` (source of truth) that ``schematools publish`` renders into a machine
                    ``/registries.json`` and a human "Ecosystem" nav page. Each entry carries a ``resolution`` type
                    (``static`` | ``oobi`` | ``source-only`` | ``unknown``) because peers differ in shape — not
                    everyone serves browsable JSON. Chose hand-edited-JSON over auto-crawling peers because (a)
                    almost none expose a machine manifest to crawl yet (that is Layer 3, deferred until they do),
                    and (b) a curated list is honest and lets us list source-only peers flagged as such (a nudge to
                    publish). VERIFIED peers before publishing (dead outbound links hurt users and SEO): Provenant
                    serves live at schema.origincloud.net (``/oobi/{said}`` + ``/registry.json``, application/
                    schema+json, AWS S3+CloudFront — found via origin-deployment/.env, NOT the repo, which points
                    nowhere); GLEIF/vLEI (GLEIF-IT/vLEI-schema + WebOfTrust/vLEI, OOBI-served); WebOfTrust/schema
                    (source-only, closest structural peer — has its own registry.json); Veridian/Cardano
                    (docs.veridian.id, resolution unknown). Specs (ACDC/KERI/CESR) live under ToIP's ``kswg-*``
                    paths — the ``tswg-*`` URLs the repo had been using 404 (working group renamed); fixed the
                    stale link in the generated landing at the same time. Layer 2 (publish a JSON Schema FOR the
                    discovery manifest, so others can adopt the shape) and Layer 3 (best-effort cross-registry SAID
                    aggregation) remain deferred, gated on peers exposing manifests.
                SEO is done as generated on-page signals, not off-page tricks = decision:
                  id: s6eqk4
                  why: >
                    Goal: someone searching for "ACDC schema", "KERI credential schema", "SAID schema registry"
                    should find this site (2026-07-14). Zensical already ships the fundamentals (semantic HTML,
                    absolute-URL ``sitemap.xml``, ``rel=canonical``, mobile, HTTPS) and fills a per-page
                    ``<meta description>`` from the site-wide ``site_description``. Chose to add only the HIGH
                    bang-for-buck GENERATED signals, all from the corpus so they never drift: (1) UNIQUE per-page
                    ``<meta description>`` — ``build-docs`` prepends YAML front-matter ``description:`` to each
                    schema page from that schema's own ``description`` field (verified Zensical honors front-matter
                    over the site default); (2) keyword-rich landing + Ecosystem copy naming the terms people
                    actually search (ACDC / Authentic Chained Data Container, KERI, SAID, OOBI, verifiable
                    credentials, registry); (3) a ``robots.txt`` at the site root pointing at the sitemap. Rejected
                    (deferred) the medium-value items that need template overrides or plugins — Open Graph / Twitter
                    cards (Zensical emits none by default) and JSON-LD structured data — as not worth the theme-
                    surgery yet. Off-page (Search Console submission, backlinks) is Daniel's to do; the Ecosystem
                    page's outbound authority links (ToIP, GLEIF, WebOfTrust) are the one on-site lever for it.
                Layer 2 — publish a JSON Schema FOR the discovery manifest, so others can adopt the shape = decision:
                  id: m5tqw3
                  why: >
                    The reusable-pattern payoff (@f7dr3k Layer 2): a committed ``spec/acdc-schema-registry.schema.json``
                    (Draft 2020-12) that DESCRIBES the ``/.well-known/acdc-schemas.json`` discovery manifest —
                    ``baseUrl`` + a ``schemas`` array of {said, name, schema, oobi, title/version/rules}. Published by
                    ``schematools publish`` at the site root so its ``$id`` URL resolves, and our own emitted manifest
                    now carries a ``$schema`` pointer to it (self-describing; editors validate/autocomplete against
                    it). Chose to keep this meta-schema OUT of the ACDC registry (it is a JSON Schema for a manifest,
                    not an ACDC credential) — it lives under ``spec/`` where ``discover_schemas`` never picks it up,
                    so it does not pollute the corpus, its SAID checks, or ``registry.json``. Made it PERMISSIVE
                    (extra fields allowed, several fields nullable) because it is a convention others EXTEND, not a
                    fail-closed gate. Dogfooded: a test asserts the meta-schema is a valid Draft 2020-12 schema AND
                    that the manifest ``build_site`` emits validates against it. Deliberately scoped to the discovery
                    manifest, not ``registries.json`` (the bakobo-specific federation index), because the manifest is
                    the shape we want OTHER publishers to copy.
                A contribution / schema-submission process is deferred until the publication gate is tooled = decision:
                  id: c5nq7d
                  stage-status: planned
                  why: >
                    This repo intends to accept OUTSIDE schema submissions — "instructions for submitting a schema
                    for consideration to be published here" was part of the founding ask, alongside a publication
                    CONTRACT: a schema is publishable only if it has a name, correct semver, passes validation
                    (valid JSON Schema + SAID integrity + a valid example + a should-reject negative corpus), AND
                    carries a good narrative ``index.md``, good examples, and a recommended visualization/icon.
                    Chose to DEFER writing ``CONTRIBUTING.md`` (and the GitHub issue/PR "propose a schema"
                    templates) until that contract is MECHANICALLY ENFORCED by a ``schematools`` publication-
                    readiness gate — Daniel's explicit call (2026-07-14): more tooling should exist before the guide
                    is written. Decisive reason: this repo's standing pattern is that the human checklist and the
                    machine gate must be the SAME list from one source so they cannot drift (the generated-vs-hand-
                    written discipline behind @f7dr3k / @z5nc4d and the fail-closed publish of @o6bw3k); a prose
                    contribution guide written BEFORE the gate documents rules CI cannot check, invites non-
                    conforming submissions, and forces manual gatekeeping — the opposite of fail-closed. Rejected
                    writing the guide now and backfilling enforcement later (the guide would be aspirational and go
                    stale on the first submission it cannot actually reject). What must exist first: a per-schema
                    readiness check that extends the @n7xk4r linter to the FULL contract — most pieces already exist
                    (structure, SAID integrity, example validity, negative corpus, registry consistency, format
                    assertion); the GAPS are a required-``index.md``-sections check, an icon/visualization-present
                    check, a semver field + validity check, and a single ``check-submission`` (or ``publish
                    --check``) entry point that runs them together; optionally a scaffolder (``schematools new
                    <name>``) so contributors start conformant. The Layer-2 manifest meta-schema (@m5tqw3) is the
                    interop half and already exists. Tradeoff accepted: until the gate lands there is NO written
                    contribution path, so any external interest is handled ad hoc (issue / hand-reviewed PR) at low
                    volume. WHEN the gate exists: author ``CONTRIBUTING.md`` to POINT AT it (run the gate locally;
                    CI runs the same), so the human checklist IS the gate's checklist, then add the issue/PR
                    templates. This is the same "surface the contract as tooling, not prose" stance @n7xk4r took for
                    schema tests, applied to submissions.
    Temporal drift is bounded by proactive revocation and the per-act gate, not per-action minting or keep-alives = decision:
      id: tj6vq4
      why: >
        A standing GCD credential is checked against its own static constraints, so the conditions that
        justified a grant can drift before an action takes effect — the "standing authority" critique Paul
        Knowles / Secours.ai raised as an "Exhaustibility Test" (2026). Rejected his cure — authority minted
        and consumed per action by a Warden (single-use Warrants) — because a live evaluator in the path of
        every effect is a reference monitor: the closed-loop, phone-home model that open-loop verification
        (imbu's this.i @kp5l4o) and SDA §7 deliberately reject, and it does not scale to unattended
        stranger-verifiers. Rejected mandatory keep-alives / short-TTL churn as the default, because it taxes
        every standing steward for a risk only a minority of grants carry and re-creates the short-expiry
        churn KERI-native revocation was chosen to avoid (imbu's this.i @n3xwkp). Chose to answer drift with
        mechanisms already in the model: (1) the per-act gate, DERIVED per action and re-evaluated at the
        execution boundary (imbu's this.i @d6mk3g), which already forces a fresh decision on exactly the
        high-stakes, irreversible acts where drift is dangerous (a payment is create-in-commitment above
        threshold → human/rule gate at the moment of effect); and (2) robust, proactive revocation, already
        in the open-loop verification path (KERI-native TEL, real-time). Accepted tradeoff: revocation is
        FAIL-OPEN — it does not stop an act inside the drift window if the delegator is slow or compromised —
        so positive-freshness (a short c_before, or a future c_fresh keep-alive) is RESERVED and documented as
        the exception, strictly for the narrow tail where an irreversible effect meets unattended
        machine-speed action that no gate catches and revocation cannot propagate fast enough. Legal
        grounding: agency law already terminates actual authority on accomplishment of the object (Restatement
        (Third) of Agency §3.09–3.10) — a closer hook than the patent-exhaustion doctrine (Impression v.
        Lexmark) the exhaustibility discourse cites. This refinement post-dates the canonical paper and
        extends the GCD-to-SDA evolution (@b6xh4m); it is being folded into "The Shape of Delegated Authority"
        §8 as a v1.1 addition.
      children:
        The GCD rules gain a sixth clause, timelyReviewAndRevoke = decision:
          id: k3wm7d
          stage-status: done
          why: >
            Adds a sixth rule to the GCD governance framework (rules.json + the schema's embedded r block and
            its required array): "Issuers agree to review each delegation they have issued on a cadence
            appropriate to its stakes, and to revoke or narrow it promptly once the conditions that justified
            the grant no longer hold ... it does not extend authority, since a delegation is valid only while
            its constraints are met." Chose a governance RULE over a new schema field because the schema
            already anticipates rule evolution ("possible to modify or override these rules") and a rule needs
            no credential-shape change; it mirrors onlyDelegateHeldAuthority's "modest, auditable
            accountability" framing and pairs with issuerNotResponsibleOutsideConstraints (which caps issuer
            liability OUTSIDE the constraints) by making the issuer responsible for keeping the constraints
            CURRENT. The closing clause forecloses the "authority persists until revoked" misreading, so the
            duty strengthens the verifier's position without weakening exhaustion. Accepted CONSEQUENCE: a new
            clause changes the rules-block content, so its SAID (currently
            EFthNcTE20MLMaCOoXlSmNtdooGEbZF8uGmO5G85eMSF) MUST be recomputed by tools/py against the keripy
            oracle (@xv4m7d) and the references to it in gcd/index.md and ../org/delegation-theory.md updated;
            existing credentials that inline the old rules SAID are a migration concern folded into the
            @b6xh4m repair-and-re-SAIDify step, not handled independently. Rejected hand-editing the SAID — a
            99.9%-right SAID silently fails to verify (@xv4m7d).
        GCD constraints split into enabling and voiding polarity; termination is an attested event = decision:
          id: v5nq2r
          stage-status: done
          why: >
            Every constraint field today is ENABLING — "permit if the presented value is in this set" (an
            allow-list: c_goal, c_jur, c_rgeo, ...). Expressing "this authority ENDS when X becomes true" needs
            the opposite polarity — VOIDING: "deny if X is observed." So the vocabulary gains a named second
            polarity (a proof-shaped c_until, and a possible live c_...When) rather than overloading the
            allow-list fields; the voiding polarity, not observability, is the real novelty. Chose to realize
            termination preferably as a monotonic, attested EVENT (a TEL revocation, or a completion ACDC
            chaining to the delegation) over a live predicate embedded in the credential, because an
            in-credential live predicate makes the credential's meaning time- and verifier-dependent and breaks
            "any two verifiers replay to the same result"; an event keeps the credential static and the log
            monotonic. Driving distinction: open-loop does NOT require uniformity (cryptographic VERIFICATION
            is uniform; VALIDATION against a verifier's own business goals is not), but a voiding condition is
            safe-as-binding only to the degree the observation is unambiguous and universally accessible — time
            (c_before) is the gold standard; "the email address exists" already slides on what "exists" means;
            "good enough" is a quality judgment, never observable, always a signoff (an attestation). So the
            primary completion hook is proof-shaped (c_until = an attested fact, an oracle's signed observation
            being one such proof), and a live c_untilObserved is added ONLY on a concrete crisp / low-stakes /
            fail-closed use case, never speculatively. Accepted backstop convention: task-scoped grants always
            carry a hard c_before ceiling, so completion/revocation only end them EARLIER (fail-open early-exit
            under a fail-closed ceiling) and a never-fired "done" signal cannot leave authority alive forever.
            Rejected two coequal fields c_untilProven / c_untilObserved as the framing, because an assured
            observation collapses into an attestation and the genuinely observation-only case is the narrow,
            fail-closed tail. Stage: planned and deferred behind the @b6xh4m repair-and-re-SAIDify; the rule
            (@k3wm7d) is the near-term artifact, while the voiding-constraint field is pulled in when a concrete
            GCD need requires it (@tq5wnh).
    Governance-framework ideas surveyed from Aries RFC 0430; adopt the constraints, reject the mechanism = decision:
      id: g7rkn4
      why: >
        Evaluated Aries RFC 0430 (machine-readable governance frameworks) as prior art for the GCD gfw/rules
        layer — the gfw field already gestures at exactly this kind of framework. Rejected its MECHANISM
        wholesale: the SGL rule DSL (grant/when/thus — a boolean role-grammar that fights GCD's declarative
        c_-field, full-disclosure, any-verifier-computes-the-same discipline); the docs_uri/data_uri
        fetch-the-framework-at-runtime resolution (a closed-loop phone-home, where GCD's SAID content-addressing
        is the open-loop answer); and the DIDComm-decorator localization. Adopted four IDEAS about what the
        rules/gfw layer should EXPRESS, captured as children — @d5tqm6 (first-class duties), @w4nzp3
        (version-compatibility class), and two tentatives @r6kv2m (redress pointer) and @c3wqn7 (counterparty
        qualification). Also recorded that GCD is already AHEAD of 0430 where 0430 is explicitly silent: it has
        no framework signing, no TTL, and no version revocation, whereas GCD's gfw/rules are
        SAID-self-authenticating and GCD carries c_before/c_after (TTL) + TEL revocation. Chose mine-and-cite
        over ignore (0430 is the prior art the gfw field points at) and over adopt-wholesale (its ecosystem-trust
        mechanism is closed-loop and its rule DSL is un-analyzable). Extends the GCD-to-SDA evolution (@b6xh4m).
      children:
        GCD gains first-class duties (the "must"), with terms-of-service acceptance = decision:
          id: d5tqm6
          stage-status: done
          why: >
            The GCD credential is ALL "may" — every field (c_goal, c_effect, c_prove, ...) is a permission or a
            condition; nothing expresses an obligation (a "must"). "The Shape of Delegated Authority" §5 names
            the may/must split and parks the "must" in the reciprocal record, but the credential itself cannot
            carry it. RFC 0430's duties (name+URI obligations incurred when a party takes a role/privilege —
            GDPR-dat-control, accept-kmk-tos) is a concrete shape to copy: a duty is a referenced obligation,
            and exercising the authority binds the delegate to it, terms-of-service acceptance included. Chose to
            first-class duties over leaving them prose-only, because (a) our own timelyReviewAndRevoke (@k3wm7d)
            is a duty smuggled in as a disclaimer "rule" — evidence the rules block already conflates duties with
            disclaimers; and (b) ToS-acceptance-as-duty is the machine-readable form of the liability lever
            (issuerNotResponsibleOutsideConstraints made affirmative). OPEN: whether duties ride on the GCD
            credential (0430's vote — on the framework, inherited by role) or the reciprocal record (SDA's
            parking spot) — a live input to the record-shape question (org this.i @ot4puqrj). Tradeoff: a duty is
            an obligation a stranger-verifier cannot ENFORCE (it binds the delegate, checked by audit and
            recourse, not at a c_-style gate) — so it is disclosure + accountability, not an enabling constraint.
        A gfw/rules revision carries a trust-compatibility class (breaking vs preserving) = decision:
          id: w4nzp3
          stage-status: planned
          why: >
            Changing GCD's rules block yields a new SAID, so today ANY rule change — adding timelyReviewAndRevoke
            included — produces a brand-new, opaque gfw with NO signal about whether a party who relied on the
            old one may rely on the new (the SAID-churn flagged at @k3wm7d). RFC 0430's versioning semantics
            classify a change as MAJOR (breaks trust: removes a role/privilege, makes an optional field required,
            changes grant logic to eliminate privileges), MINOR (adds precision without invalidating: new
            roles/privileges, grant changes that only benefit existing holders), or PATCH (safe: new topics,
            description tweaks). Chose to copy a compatibility CLASS onto a gfw/rules revision over relying on the
            bare SAID, because a graded "is this trust-preserving?" signal is exactly what lets a verifier or
            delegate decide whether an updated framework is auto-acceptable or needs fresh consent. Constraint:
            because verification is open-loop, the class MUST be a self-describing, SAID-committed property of the
            revision (published in the ruleset), never a lookup. Tradeoff: semver-style promises are social, not
            cryptographic — a mis-declared "minor" that actually breaks trust is possible; the class is a claim a
            verifier MAY check against the diff, not a proof.
        TENTATIVE — a redress / recourse pointer in the gfw/rules = decision:
          id: r6kv2m
          stage-status: planned
          why: >
            TENTATIVE / candidate, not yet adopted. SDA and GCD name the obligation-bearer (who answers if an act
            goes wrong) but provide no LOCUS OF RECOURSE — where a harmed counterparty actually appeals. RFC
            0430's redress {uri} treats an appeal endpoint as a legitimacy signal. Candidate: a rules-block/gfw
            redress pointer ("recourse for acts taken under this delegation lives here"), as disclosure metadata
            (human/legal process, not machine-checkable). Left tentative because (a) it may belong to the
            org/instance layer (a concrete Bakobo redress process) rather than the generic GCD schema, and (b) a
            bare URI is the closed-loop-flavored part of 0430 we otherwise reject — the open-loop rendering (a
            SAID, an AID, or a pointer that is resolvable but never verification-critical) is unsettled. Revisit
            when the accountability / obligation-bearer axis is specified.
        TENTATIVE — constrain the counterparty (who may rely or verify) — a shape for c_disc = decision:
          id: c3wqn7
          stage-status: planned
          why: >
            TENTATIVE / candidate, not yet adopted. RFC 0430 can restrict WHO may rely — "only approved-verifiers
            may request this proof" (Rule 4) — the counterparty must itself present a qualification. That is a
            concrete shape for SDA's reserved-but-unspecified OUTBOUND c_disc axis ("what a delegate may reveal
            about its principal, and to whom"): a delegation could require the counterparty prove a qualification
            before the delegate discloses or acts. Candidate because it operationalizes the earlier finding that
            a verifier always serves its own purpose, yet an issuer can still bound WHICH verifiers a delegate
            engages. Left tentative because c_disc's whole vocabulary is deliberately open (SDA §6) and adding a
            counterparty-qualification constraint pre-commits part of it, and because a mutual-proof handshake
            edges toward the interaction complexity GCD has so far avoided. Revisit when c_disc is opened for
            design.
    The SEDI credential family models Utah's State-Endorsed Digital Identity = goal:
      id: sd4rkp
      why: >
        Utah's SEDI law (Utah Code Title 63A Ch. 20, enacted by SB 275, effective 2026-05-06) creates a
        rights-and-standards framework whose §301 requirements — a holder-created identifier that is
        "mathematically provable to be under a holder's control", compromise detection/recovery,
        cross-context-correlation protection, no state phone-home, offline presentation, selective
        disclosure, prove-age-without-birthdate, and open standards "free from licensing fees and patent
        restrictions" — in combination only KERI/ACDC cleanly satisfy. Bakobo was invited to help pioneer
        SEDI use cases with Daniel Hardman's KERI leadership as the anchor, so modeling the SEDI credentials
        as ACDC schemas belongs here alongside GCD (delegation is first-class in SEDI via the statutory
        digital guardian, §201(3)). Chose to model SEDI as a small FAMILY rooted at a minimal state-endorsed
        identity credential, not one fat credential, because the statute endorses exactly four attributes
        (name, birth date, image, Utah residence address — §301(2)(f)) and forbids collecting more
        (§302(7)); everything richer (age thresholds, presentations, guardianship, foreign-credential
        bridging) chains to that root as a separate credential. Full research + synthesis lives in the sedi
        knowledge repo (artifacts/sedi-schema-synthesis.md); the load-bearing decisions are recorded below
        and vendored into each credential's index.md. Note SEDI is Utah-specific where the rest of this repo
        is general-purpose (see @k5wd2r) — accepted because the ACDC PRIMITIVES it exercises (the v2
        Aggregate section, selective disclosure, I2I presentation chaining) are exactly the general
        machinery this repo exists to demonstrate, and SEDI is the most credible real-world beachhead for
        them.
      children:
        sedi-id section choice — SUPERSEDED by @sdav5t (was aggregate, now attributive) = decision:
          id: sd7mwq
          why: >
            SUPERSEDED by @sdav5t (2026-07-16): sedi-id was reworked from an aggregate to an ATTRIBUTIVE ('a')
            ACDC after Sam Smith's first-principles reversal in PR WebOfTrust/keripy#1505 — a fixed set of
            meaningfully-labeled fields wants labels, not a blinded array. The original aggregate rationale is
            kept below for history.
            sedi-id is the state-endorsed root: an ACDC v2 Aggregate ('acg', 'A' section) credential whose
            every identity attribute is an individually-blinded, self-addressing block, with element 0 the
            AGID committing to the set. Chose the Aggregate section over an ordinary attribute ('a') section
            because the statute MANDATES selective disclosure and prove-age-without-birthdate (§301(1)(e))
            and bans presentation tracking (§301(3)): the aggregate lets a holder reveal an arbitrary subset
            of blocks in full while the rest travel as bare, per-block-blinded SAIDs, and a verifier
            recomputes the AGID to confirm authenticity — offline, with no issuer callback. The governing
            design constraint is the atomicity rule (all fields in one block disclose together), so block
            granularity IS disclosure granularity. Issuer = the State (DGO); the holder AID is carried in its
            own Issuee block (an aggregate ACDC has no top-level a.i), which is what an I2I presentation chain
            checks. Grounded in the worked keripy example tests/acdc/test_clc_disclosure.py, which runs this
            exact credential shape through selective disclosure + chain-link-confidentiality.
        Name and residence decompose into sibling blocks; residence is the load-bearing case = decision:
          id: sd3vnx
          why: >
            Both name (given/family) and the residence address are split into SEPARATE aggregate blocks, not
            carried as one lump or one nested object — and decomposed is the SOLE production shape (an earlier
            "coarse baseline + fine opt-in" hedge was retracted). Rationale: because a block discloses
            atomically, a single residence block would force over-disclosure on every verifier who only needs
            jurisdiction, making the statute's minimization duty (§501 "minimum attributes", §701 duty of
            loyalty) un-satisfiable at the schema level; "prove Utah resident" (voter eligibility, in-state
            tuition, tax/jurisdiction, alcohol) is the most common residence predicate; withholding the street
            line protects exactly the Title-20A withheld/at-risk-voter classes (DV victims, LEOs, protected
            persons); and NOT decomposing would make SEDI a privacy regression from the ISO 18013-5 mDL it
            replaces (which already splits resident_address/city/state/postal). Decomposed strictly dominates
            (a holder can always disclose every component to reconstruct the coarse view), so the single-block
            form buys nothing and two profiles is itself a cost. Grain: keep the street LINE whole
            (residenceStreet) rather than parse it (PO boxes, rural routes, non-US formats are brittle; the
            useful predicates live in the clean jurisdiction fields); split only city/state/postal/county; go
            no finer. Naming is SEMANTIC interop not field-name interop: use Utah's statutory term "residence"
            (residenceCity, residenceState, ...), not mDL's "resident" — align the component semantics with
            18013-5 so the bridge crosswalk is mechanical, but keep the statute's vocabulary. Labels are flat
            and DOT-FREE on purpose: a dotted key (residence.street) signals a nesting the data model
            deliberately lacks and is a cross-tooling footgun (jq/JSONPath treat the dot as a path; JS
            obj.residence.street traverses; MongoDB reinterprets dotted keys).
        The endorsed image is committed by digest and holder-carried, never a URL or inline blob = decision:
          id: sd6tzc
          why: >
            The image block carries a content DIGEST plus minimal metadata (format, dim, captured); the actual
            portrait bytes are holder-carried and attached to a presentation under chain-link confidentiality,
            verified against the digest. Rejected a DOWNLOAD LOCATOR because it fails three statutory tests at
            once — it breaks mandatory offline presentation (§301(1)(d)); it is phone-home by another name
            (whoever hosts/observes the fetch learns presentation events, §301(3)/§701); and it creates an
            availability/denial chokepoint incompatible with a self-sovereign credential. Rejected INLINING
            raw bytes into the aggregate block (as the keripy demo does) as bloat: a registry-anchored
            credential would re-hash tens of KB on every block-SAID computation. One canonical portrait
            (ISO/IEC 19794-5-grade, matching DMV/mDL) — no resolution ladder (multiplies correlation surfaces;
            a wallet can downscale for display, though a locally-derived thumbnail is not state-verifiable).
            The second biometric artifact is NOT a resolution but a separate optional faceTemplate block: a
            cancelable/biohashed ISO/IEC 24745-style template for consented 1:N dedup (a plain photo hash is
            useless for matching), carrying a named biometricProtocol and disclosed only under a
            correlation-consent rule since a shared protocol is a cross-credential linkage key. Data URLs are
            tolerated only as a presentation-edge convenience; the digested artifact is always the canonical
            raw bytes, never the data-URL string (its MIME/base64/charset params make the digest brittle).
        Age is a derived boolean attestation (sedi-age), not a ZK predicate — the no-edge half is SUPERSEDED by @lkfnoess = decision:
          id: sd5hjb
          why: >
            SUPERSEDED IN PART by @lkfnoess (2026-09-15): the "sedi-age carries NO edge to sedi-id" clause
            below no longer holds. Its reasoning is specifically about I2I and remains correct about I2I;
            sedi-age now carries an E1E identity edge, which constrains only the issuees and so holds where
            I2I would not. Everything else in this node — derived boolean over ZK predicate, and the
            presentation-time I2I binding — stands unchanged.
            REFINED by @sdav5t (2026-07-16): sedi-age is now an AGGREGATE ('A') of boolean threshold flags
            (ageOver13/16/18/21/55/65) plus issuee and as-of blocks — the holder discloses just the needed
            threshold(s) — rather than the single-threshold attribute credential described below. The
            derived-boolean-not-ZK and no-edge-to-sedi-id decisions below still hold.
            prove-age-without-birthdate (§301(1)(e)) is served by a small derived credential, sedi-age, that
            asserts a boolean over a named threshold (ageThreshold/ageOver/asOf), one schema serving every
            threshold like the mDL age_over_NN element. Chose a pre-derived boolean (the plan-of-record
            default) over a zero-knowledge predicate proof for the near term: it keeps the birth date out of
            the transaction with no exotic cryptography, and covers the alcohol/tobacco use case (§204(2)(a)).
            sedi-age carries NO edge to sedi-id: an I2I edge would hold only if age's issuer equalled sedi-id's
            issuee (the holder), i.e. only if the holder self-issued age — which carries no state endorsement.
            The same-holder binding is instead established at PRESENTATION time by a holder-issued bespoke
            credential whose I2I edges point at both source credentials (the holder is issuer there, and the
            issuee of both). A ZK-predicate variant is a possible future profile the statute explicitly
            permits.
        The v1-pinned SAID oracle cannot stamp v2 aggregate ACDCs — LIFTED by @lkfnoess = constraint:
          id: sd2qfw
          why: >
            LIFTED by @lkfnoess (2026-09-15) and retained as the record of why the corpus looked the way it
            did. The premise expired when @h3or4x moved the oracle to bakobo/keripy@a1f2f32b (keri
            2.1.0-dev0), which stamps v2; sedi-age is now a true 'acg', whose field domain has no optional
            fields, so 'v' is required and the unversioned-example dodge below is gone. Consequence (3) —
            this repo's linter does not recompute the AGID — is the ONE part still live, and is tick 2nd5.
            This repo's SAID oracle is pinned to keri 1.2.13 (@m4vd7s, @xv4m7d), which predates the ACDC v2
            Aggregate section. Empirically (probed 2026-07-16): keri 1.2.13's SerderACDC REJECTS a versioned
            aggregate SAD (it disallows even the v2 'rd' field, let alone 'A'), but the generic Saider path
            round-trips an UNVERSIONED aggregate SAD cleanly as a fixed point, treating 'A' opaquely; and
            schema saidification works for an 'A'-section schema (the top-level $id is generic over the JSON).
            NARROWED by @sdav5t (2026-07-16): sedi-id is now ATTRIBUTIVE — a plain v1 ACDC the oracle
            version-stamps fully — so this constraint applies only to the AGGREGATE sedi-age. Consequences for
            sedi-age, recorded so they are not mistaken for defects: (1) sedi-age's 'v' is OPTIONAL and its
            examples omit it — a production credential carries a v2 version string a v2 stack
            stamps; (2) a v2 credential's top-level SAID is computed over the COMPACT form (A = AGID) and is
            disclosure-invariant, but the v1 oracle computes 'd' over literal content, so each sedi-age example
            (full + over-21 disclosure) is a fixed point over its own content and they do not share one 'd'
            (under v2 they would); a related residual applies to ANY nested partial disclosure — keri 1.2.13
            does not compact nested blocks, so sedi-id's partial-disclosure forms are shown illustratively in
            prose rather than as SAID-checked files; (3) the AGID and per-block SAIDs are authentic — computed with the v2 keri Aggor (the
            keripy test) — but this repo's linter does NOT recompute the AGID; it checks top-level SAID
            consistency, schema validity, and the negative corpus. Chose to keep the pin and document the
            limitation over bumping keri to a v2 dev build, because @m4vd7s makes the pin load-bearing for
            every existing SAID in the corpus and a dev build would risk silent SAID drift; revisit when a
            released keri v2 can be pinned and differentially verified.
        The rest of the family and a SEDI governance framework are roadmap = decision:
          id: sdc7xn
          stage-status: planned
          why: >
            Built now: sedi-id (the aggregate root) and sedi-age (derived boolean age). On the roadmap, tracked
            in tick and named in sedi-id/index.md: SEDI presentations (see @sdp3wk — a presentation-base plus
            per-verifier-pattern specializations over a referenced governance framework, NOT a monolithic
            'bespoke' type); sedi-guardian (a GCD-style delegation for the statutory digital guardian,
            §201(3)); and sedi-bridge (a reissuer / foreign-artifact wrapper re-anchoring an ephemeral foreign
            credential — EUDI, another state's mDL, a DHS W3C VC — into a durable holder-controlled ACDC for
            Olympic-scale interop). The SEDI governance framework (sedi-id/rules.json) and the first
            presentation pattern are now authored (see @sdgv7k). The presentation and guardian work lean on the
            GCD/delegation model already in this repo.
        SEDI presentations are a base plus per-pattern specializations, not a bespoke type = decision:
          id: sdp3wk
          stage-status: planned
          why: >
            Reconsidered the earlier "sedi-bespoke" roadmap item and rejected it (DHH agreed 2026-07-16).
            "Bespoke" (the ACDC spec's term for a holder self-issued, disclosure-specific presentation ACDC)
            names an ISSUANCE PATTERN, not a credential TYPE — a schema is a type, so "a reusable schema for the
            thing defined by being one-off" is a category error, and the name misleads. Decomposing what it
            conflated: (1) the VERIFIER'S REQUEST ("prove over-21 and show the state-endorsed photo under
            governance framework G") is an IPEX apply QUERY that names wanted source-credential types and
            predicates — not a credential schema, and not necessarily a repo artifact; (2) the reusable
            PRESENTATION SHAPE — I2I edges to one or more source credentials, an 'r' referencing the governance
            framework, and a minimal interaction-attribute block — is worth at most ONE published base schema
            (analogous to dossier-base) that named verifier-pattern schemas (e.g. age-portrait admittance, KYC
            identity, voter-eligibility) specialize; the club's accepted-shape and the holder's issued
            presentation conform to that ONE schema viewed from two sides, so there is no separate "request
            schema" vs "response schema"; (3) the CLC TERMS live in the SEDI governance framework rules.json
            (referenced by SAID), not authored per presentation. The genuinely one-off case (a holder authoring
            a novel disclosure shape for a single interaction) needs NO repo artifact — the schema travels
            inline. Naming lesson: presentation schemas are named by PATTERN, never "bespoke." Whether the
            presentation-base itself earns a place (vs. leaving each verifier to author its own pattern schema)
            is to be settled from a sketch before building (tick ~5c35).
        The SEDI governance framework is authored and the first presentation pattern is built = decision:
          id: sdgv7k
          why: >
            Authored the SEDI governance framework as sedi-id/rules.json (the root credential's folder is the
            family-wide home, mirroring face-to-face's rules.json) and minted its SAID; sedi-id, sedi-age, and
            the presentation now reference it from 'r', replacing the earlier placeholder. Its clauses ground
            chain-link confidentiality, data minimization, duty of loyalty (63A-20-701), anti-surveillance
            (63A-20-301(3)), guardian acceptance, no device surrender, consent/notice, revocation respect, and
            the 63A-20-701 safe harbor. Also built the FIRST concrete presentation pattern,
            sedi-present-age-portrait — the "prove over-21 and show the state-endorsed photo" admittance case
            (63A-20-204(2)(a)): a holder-issued, unregistered v1 ACDC (issuer = holder, issuee = verifier) with
            I2I edges to sedi-id and sedi-age and 'r' referencing the framework, the photo reached by selective
            disclosure of just the sedi-id image block. Per @sdp3wk it is named by PATTERN, not "bespoke," and
            the schema enforces the pattern's teeth: every edge operator pinned to const "I2I" (the same-holder
            binding), 'r' required, and 'rd' disallowed (additionalProperties:false — unregistered, not logged).
            The general presentation-base remains deferred until a SECOND pattern exists to prove the shared
            shape (tick ~5c35).
        Section choice A-vs-a — sedi-id is attributive, sedi-age is an aggregate boolean vector = decision:
          id: sdav5t
          why: >
            Reversal of the original section choices (@sd7mwq, @sd5hjb), driven by Sam Smith's
            first-principles argument in PR WebOfTrust/keripy#1505 (the CLC worked-example PR). Both his
            initial answer and mine had modeled the core SEDI identity credential as an aggregate; on
            reflection he inverted it, and I agree. The principle: the ONE thing an aggregate ('A') section
            buys over an attribute ('a') section is that its top-level blocks carry NO meaningful labels, so
            block POSITION in the array can be arranged so as not to leak information. That benefits a
            credential only when the presence/identity/position of a field is itself sensitive or the field
            set is variable. It carries a definite COST: you can no longer path to a field by label, so
            graduated-disclosure negotiation (apply/offer path lists, e.g. via keri Pather) needs a
            label->index reverse-lookup table, and if you put the index in the path you defeat the very
            unlinkability the array was for. Applying this: (1) the CORE IDENTITY credential is a fixed set of
            heterogeneous, meaningfully-labeled fields (name, dob, image, residence components) — nothing
            benefits from label/position hiding, and it is the most-used credential, so paying the pathing
            cost is a poor trade. => ATTRIBUTIVE 'a', each attribute a nested, partially-disclosable block
            (own d/u), issuee at a.i, label-based pathing. (2) the AGE credential is a HOMOGENEOUS boolean
            vector (ageOver13/16/18/21/55/65) where you disclose a SUBSET — the thresholds are really an
            indexed numeric series, and treating them as an unordered blinded set matches the ISO mDL
            age_over_NN element and leaves room for the planned sparse-Merkle-tree upgrade with no schema
            change ("a poor man's sparse Merkle tree"). => AGGREGATE 'A' array of boolean blocks.
            Two honest caveats: for age the correlation win is modest with all thresholds always present (the
            drivers are mdoc parity, natural fit, and forward-compat, not a large delta; Sam's optional
            decoy/position-randomization is overkill and skipped); and attribute-form partial disclosure
            FORCES the issuee (a.i) and a-section metadata to be revealed on any disclosure, where an
            aggregate could disclose one element with no issuee — acceptable for SEDI since the holder binding
            is normally wanted. Happy side effect: as a plain v1 ACDC, sedi-id is now fully VERSION-STAMPED and
            SAIDified by the pinned keri 1.2.13 oracle, so the aggregate-can't-be-versioned limitation (@sd2qfw)
            no longer applies to it and now burdens only the rarely-presented sedi-age — better placement, and
            aligned with "don't add complexity to the most-used credential." (Residual, general to nested
            partial disclosure under keri 1.2.13: it does not compact nested blocks, so a partial-disclosure
            form's a.d/top-d differ from the full form's; the "prove Utah residence without the street line"
            case is therefore shown illustratively in sedi-id/index.md rather than as a SAID-checked gallery
            file, and the machine-validated selective-disclosure gallery lives on sedi-age, where the AGID is
            stable across disclosures.)
        SEDI digital guardian — a thin legal-recognition layer over GCD, first of a family = decision:
          id: sdlg3n
          why: >
            sedi-guardian attests recognized legal authority to act on behalf of a ward (Utah Code
            63A-20-201(3); acceptance mandated by Parts 4-6). Grounded in the Sovrin "Guardianship in SSI V2"
            whitepaper, Aries RFC 0103 "Indirect Identity Control", Utah Title 75 Ch. 5 (guardianship) and
            Ch. 5b (UAGPPJA cross-state recognition), and the delegated-authority model in papers/sda.md.
            KEY DESIGN: GCD already carries the generic guardianship machinery (relationType=guardianship,
            presentsAs = the holder!=subject transparency invariant, duties, terminatingEvents, the act grid).
            Unlike the bespoke case, though, guardianship has STABLE, statutorily-enumerated, verifier-critical
            structure a GCD's fail-closed constraints cannot hold: the four bases (designatedRepresentative,
            custodialParent, courtGuardianMinor 75-5-202, courtGuardianIncapacitated 75-5-301), the scope of
            powers (Utah prefers LIMITED, so scope must be explicit and machine-checkable), and the
            appointment/registration. So a schema IS warranted — but as a THIN legal-recognition layer that
            COMPOSES with GCD, not a re-implementation. sedi-guardian carries only what Utah law makes
            relationship- and jurisdiction-specific (basis, powers, and a clustered 'recognition' block:
            court/case/order or self-executed instrument, appointingState, UAGPPJA registrationStatus), is
            registry-bound (guardianship terminates dynamically -> verifiers MUST check status), holds the
            HOLDER!=SUBJECT invariant structurally (issuee = guardian; ward named by a 'subject' edge to the
            ward's sedi-id), and reaches the generic act-constraints via an optional 'scope' edge to a GCD
            (relationType=guardianship). Scope carrier: self-contained powers[] + optional GCD edge (DHH's
            accepted lean) over always-edging-to-GCD.
            GENERALIZATION HYPOTHESIS: this is the first of a likely sedi-legal-authority family. The two-layer
            principle -- GCD for the GENERIC relationship (delegation/controllership/stewardship/simple
            delegation need nothing more); a thin SEDI legal-recognition layer only for relationships the law
            SPECIALLY recognizes and appoints (guardianship, conservatorship, POA-agency) and that a verifier
            must check. Extract a shared sedi-legal-authority base at the SECOND concrete instance
            (conservatorship is the obvious one -- it shares ~80% of the recognition layer), NOT speculatively
            now (same extract-at-second-pattern discipline as @sdp3wk). Boundary: person-fiduciary authority
            (guardian/conservator/POA -- acting in a vulnerable person's best interest) stays distinct from
            thing-controllership (a drone has no interest or rights); controllership stays GCD's territory,
            never folded under the guardianship family with a discriminator flag.
            EXCLUSIONS: SEDI's guardian is of the PERSON, not a conservator of property (a separate Utah
            appointment, not one of the four bases). And supported-decision-making supporters (Utah 2025 Part
            7) are EXCLUDED: a supporter assists but cannot decide FOR the principal, so fails the statutory
            "act on behalf of" test, and categorically transfers no authority (it is not delegation,
            guardianship, controllership, or stewardship). If SEDI ever needs SDM it is a distinct sedi-support
            artifact (likely a consent/accompaniment attestation, not an authority credential), evaluated for a
            shared base only as a second person-relationship pattern.
            RULE (reusable) -- the security-boundary bit: when the single attribute distinguishing two
            credential shapes IS the security boundary (here: does the holder have authority to ACT FOR the
            subject?), make them DISTINCT schemas, never one schema with a discriminator flag. A one-bit
            difference that inverts the verifier's safe default must not be optional/fail-openable -- distinct
            types make each credential's default reading safe without a flag check (the same instinct as not
            putting isAdmin on the ordinary-user schema). This is why SDM is not a basis value on sedi-guardian
            and why thing-controllership is not folded into the person-fiduciary family.
        The whole SEDI family moves to the ACDC v2 envelope; sedi-age becomes a true 'acg' with an E1E edge = decision:
          id: lkfnoess
          stage-status: done
          why: >
            OCCASION: sedi-age refused every ACDC v2 message it exists to describe. It sets
            additionalProperties:false and never listed 't', so a heti-issued credential failed validation on
            the ilk field alone, blocking bakobo/arf-interop from minting a real sedi-age instead of a locally
            shaped stand-in (its ticks 3qay, 7o46, 2awf). The minimal repair is one property. This node records
            why the repair is NOT minimal.
            ROOT CAUSE: diffed against the worked example this credential descends from — AGE_SCHEMA_MAD in
            bakobo/keripy tests/acdc/test_clc_disclosure.py, already cited by sedi-age/index.md — sedi-age is
            that schema MINUS 't' and MINUS 'e'. The missing 't' is the visible half of a dropped envelope, not
            an isolated omission, so fixing only what the error message named would have left the other half.
            ILK: sedi-age is a true 'acg' and pins "t": {"const": "acg"}; the other three pin "const": "acm".
            Rejected declaring sedi-age an 'acm', which would also have worked mechanically — acm's field
            domain (keri.core.serdering FieldDom) lists 'a' and 'A' as an alternate pair, so an acm may carry
            an aggregate section, and building one that way validates against the existing schema plus a bare
            't'. That was the cheap path and it was refused for three reasons: the $comment and index.md
            already assert acg, so the cheap path meant editing the documentation to match a mistake rather
            than the schema to match the documentation; acg is the FIXED-FIELD ilk, whose field set keripy
            itself enforces on every instance, which makes this JSON Schema a second independent check instead
            of the only one; and the worked example mints it with acdcagg. Rejected a bare {"type": "string"}
            for 't' (the style of WebOfTrust/keripy tests/sedi/test_sedi.py and of this repo's gcd and
            proof-of-control) in favour of the const: on a fixed-field ilk the const is load-bearing, since a
            wrong-ilk message is otherwise indistinguishable, and the worked example pins all five of its own.
            ACCEPTED CONSEQUENCE — @sd2qfw IS LIFTED FOR sedi-age: acg has NO optional fields, so 'v' and 'e'
            are present on every instance. The unversioned-aggregate dodge cannot survive the ilk choice; it is
            a consequence of this decision, not a separate one. This is only possible because @h3or4x moved the
            SAID oracle to bakobo/keripy@a1f2f32b (keri 2.1.0-dev0), which stamps v2; that node deferred the
            lift as "sedi scope, not 25ra", and this is that scope. Tick 2nd5's version-stamp half closes here.
            Its linter-recomputes-the-AGID half does NOT: the artifacts minted here carry oracle-computed
            AGIDs, but schematools still treats 'A' opaquely, so AGID authenticity remains checked only by the
            keripy test. That is left open deliberately rather than silently satisfied.
            THE E1E EDGE SUPERSEDES @sd5hjb. That node ruled out an edge from sedi-age to sedi-id, reasoning
            that "an I2I edge would hold only if age's issuer equalled sedi-id's issuee (the holder), i.e. only
            if the holder self-issued age". The reasoning is sound and is specifically about I2I. E1E is an
            IDENTITY relation — near issuee = far issuee, issuer unconstrained (keripy discussion #1515) — so
            it holds in exactly the case I2I fails, which is why the worked example uses it. Verified rather
            than assumed: against the real AGE_SCHEMA_MAD, an edgeless acg (acdcagg emits "e": {}) is REFUSED
            by the 'e' subschema, and an edge carrying o=I2I is REFUSED by the const. The edge is therefore
            mandatory in practice even though 'e' is absent from that schema's required array, and the code
            comment there claiming it is schema-required is right by a two-step argument. The presentation-time
            I2I binding @sd5hjb describes still stands and is unchanged; this adds an issuance-time identity
            relation, it does not replace the presentation-time one.
            WHOLE FAMILY, NOT JUST sedi-age: sedi-id, sedi-guardian and sedi-present-age-portrait all move to
            the v2 envelope ('ri' -> 'rd', 't' pinned to acm). Rejected stopping at sedi-age + sedi-id, which
            was the smaller and more tempting unit. It does not close the problem, it relocates it: both
            sedi-guardian and sedi-present-age-portrait carry edges INTO sedi-id (and the portrait into
            sedi-age too) with I2I/NI2I operators a verifier can only check by resolving the far node, so
            stopping early leaves v1 near-nodes edging into v2 far nodes — a schema that passes CI and a chain
            that does not walk, which is precisely the defect being repaired. The marginal cost is also smaller
            than it looks: guardian and portrait pin the two moving SAIDs in ~25 fixtures between them and must
            be re-minted regardless, so the choice is one migration or two, not one migration or none.
            ACCEPTED CONSEQUENCE: sedi-present-age-portrait/invalid/rd-not-allowed.json asserts a v1 property.
            Under v2 'rd' is legal, so that fixture stops being a negative case and is REPLACED rather than
            re-SAIDified. Every other fixture in the family keeps its meaning and moves only its pins.
            DELIBERATELY NOT DONE HERE — tick 6grq: sedi-age's 'A' arm still uses items/anyOf with no
            prefixItems and no minItems, so the AGID is not pinned at index 0 and the issuee block is not
            required at index 1, which lets a holder withhold element 1 and present a targeted credential as an
            untargeted affidavit. The worked example has the SAME weakness, so fixing it here alone would make
            this family diverge from the artifact it is modeled on, and would fork a security-relevant shape
            downstream of upstream rather than upstream of it. Sequenced instead as its own unit, starting at
            the source: fix the example in bakobo/keripy, raise a PR there, then contribute it back to
            WebOfTrust/keripy, and only then bring the shape here. Confirmed with Daniel 2026-09-15.
            DEFECT FOUND AND FIXED IN PASSING — @sd2qfw's claim that sedi-age's "AGID and per-block SAIDs
            are authentic -- computed with the v2 keri Aggor", which sedi-age/index.md repeated, was NOT
            TRUE OF THE PUBLISHED ARTIFACTS. Measured: the aggregate's element SAIDs were reproducible with
            Saider.saidify (this repo's generic saidify_sad path) and not with Aggor, and
            Aggor.verifyDisclosure returned False on the published 'A'. The corpus was self-consistent
            against the LINTER's algorithm while failing the PROTOCOL's, and nothing could see it because
            schematools treats 'A' opaquely — the linter was checking the corpus against itself. Both
            example.json and the over-21 disclosure are now built with Aggor/acdcagg and verify.
            NOTE the attributive side was NOT affected, and was wrongly suspected first: a Compactor-based
            comparison appeared to indict sedi-id, gcd and face-to-face alike, but building with keripy's
            own acdcmap reproduces their section SAIDs byte-for-byte, because Compactor.said is the SAID
            over the COMPACTED form while an expanded section legitimately carries the Saider value. The
            generalisable lesson: compare against the builder the protocol actually uses, not against a
            primitive that merely looks like it should agree.
            Also fixed: sedi-age's top-level 'u' was '0ABsediagetopnonce00x' — 21 characters where a '0AB'
            nonce is 24, so it was not decodable CESR at all. It survived because the schema types 'u' as a
            bare string and nothing ever parsed it; it had propagated into 9 files.
            OPEN, DELIBERATELY: @sd2qfw predicted that under v2 a credential and its disclosure "would"
            share one top-level 'd'. They do not under the pinned oracle — keripy recomputes 'd' over the
            form it is given. What ties the disclosure to the credential is the AGID they share at A[0],
            which is what Aggor.verifyDisclosure checks. The prediction is retired, not carried forward.
    Align the SEDI family to Sam Smith's pinned Summit schemas = decision:
      id: epnvr5oq
      why: >
        For the November SEDI Summit, publish Sam Smith's IAR, Core, and Residence JSON Schemas
        exactly as authored at WebOfTrust/keripy ec307cd74 (0.1.0), preserving their three
        schema SAIDs. R3 shows our sedi-id differs in field placement, block shape, edge
        semantics, and rule shape, so calling it Sam-compatible would mislead issuers.
        Keep sedi-id resolvable as a superseded Bakobo schema; Core, Residence, and IAR
        are the active state-issued set. Preserve Sam's legalPresenceStatus field while
        documenting that Utah Code 63A-20-301(2)(f) endorses only name, birth date,
        image, and residence address. The existing Saider(label="$id") computation
        equals Sam's Mapper(saids={"$id":"E"}) on all three schemas with JSON serialization,
        so no new SAID algorithm is justified. Pin both SAIDs and source bytes in CI.
      children:
        Keep governance separate from Sam's credential vocabulary = decision:
          id: 2vqmhxai
          why: >
            sedi-id/rules.json is Bakobo's standalone governance artifact, not one of
            Sam's state-issued credentials. Keep it reachable when sedi-id is superseded.
            Sam's r object permits only d and l, so express the existing legal clauses
            as legal-language text in l and re-SAID the artifact and its local examples;
            doing so preserves the text while making it usable in Sam-shaped r sections.
        Age and presentations remain explicit Bakobo profiles = decision:
          id: eqbjfpq3
          why: >
            Sam has no age or presentation schema at ec307cd74. Keep the age threshold
            aggregate and named holder-issued recipes to support the Summit's over-21
            and county steps, but publish new major versions because their source-schema
            edges move from sedi-id to Core. Age's E1E relation and presentations' I2I
            relations remain. Mark age provisional pending Sam's #1098 mechanism.
            A second recipe now exists, but a shared base still adds no enforceable rule
            beyond each concrete schema's edge and disclosure requirements, so defer it.
        Put the ward in guardian attributes and name authority layers distinctly = decision:
          id: 6ge27cya
          why: >
            Tier C follows Sam's #1550 graph and Daniel's ward authorization example:
            the state issues the guardian credential to the guardian, with the ward AID
            in a separately disclosable attribute sub-block; the ward's Core variant
            has the NI2I edge back to guardianship. This avoids a cyclic pair of edges
            and allows the ward identity to be withheld independently. Rename our
            coarse statutory powers list to scope, reserve powers for delegable
            capabilities, and rename the optional GCD scope edge to constraints so
            it cannot be mistaken for statutory scope. The guardian issues a distinct
            revocable ward authorization with I2I authority and E1E ward identity
            edges; its capability set must be checked against guardian powers.
            Ward Core inherits Sam Core's optional, string-valued t: requiring
            acm would make this Core variant's envelope stricter for no reason
            supplied by the new guardianship edge. These are Bakobo provisional
            profiles, not Utah policy or Sam's schemas.
        Preserve every published rules revision by SAID = decision:
          id: jmr6znql
          why: >
            A rules SAID in an issued credential is a permanent content address. Replacing
            sedi-guardian/rules.json and sedi-id/rules.json in place during this migration
            stranded the earlier EOW7nnASAYoY72gJ7brJwE0V2Hm8o6RfZvN2gNeyKmO0 and
            EA5O9z0TB932sm8kJIVdAIpwLpEWRWC5--VNS5r69frn revisions. Keep their
            origin/main bytes in versioned archive paths, alongside the revised rules
            used by new examples. Index both revisions in registry.json so a verifier
            can resolve either SAID without guessing a path. Extend the registry check
            and a corpus-wide conformance test to recompute every referenced rules SAID;
            testing only the current examples would miss old credentials. Preserve the
            archived schema bytes: changing a path description there would itself
            invalidate an already published schema SAID. The cost is retaining old
            governance text and teaching the registry to index rules as well as schemas.
    Publish a compact-capable revision of SEDI Core = decision:
      id: spytom65
      why: >
        The pinned Sam Core 0.1.0 schema accepts only expanded objects for its named
        attribute blocks and utahAgent edge. ACDC compaction replaces those nested
        mappings with their SAID strings, so an issued Core or its selectively disclosed
        form fails schema validation and cannot enter the public admission path. Add a
        string arm before the existing object arm for each compactable nested block,
        preserving the existing expanded-object constraints. This changes the schema
        SAID and therefore requires a new published revision; keep the original 0.1.0
        bytes resolvable, repin dependent schemas and examples to the new Core SAID,
        and identify the revision as a Bakobo interoperability amendment to Sam's
        source. Rejected weakening the object arms or treating any string as an
        endorsed claim: schema validation checks representation, while the verifier
        must still resolve and verify each SAID before admitting a claim. The accepted
        tradeoff is that the revised Core no longer has byte identity with Sam's
        upstream schema; the archived revision retains that provenance.
