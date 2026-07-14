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
      stage-status: planned
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
          stage-status: planned
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
            authoring — tracked in tick ~5hlz (schema docs) and ~44oc (cross-repo); the schema artifact + example +
            registry re-SAIDify per @b6xh4m.
        The reciprocal record IS the GCD r block; the "must" is first-class there, not a second credential = decision:
          id: r5dnk2
          stage-status: planned
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
            distinct reciprocal record) — the cross-repo obligation tracked in tick ~44oc.
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
                    CORRECTION (2026-07-14, from the live deploy): GitHub Pages' ``upload-pages-artifact`` tars the
                    site with ``--exclude=".[^/]*"``, STRIPPING every top-level dot-entry — so a
                    ``.well-known/`` file never reaches the served site (verified: ``/.well-known/acdc-schemas.json``
                    404s while ``/registry.json`` and ``/oobi/<said>.json`` serve). Resolution: the CANONICAL
                    discovery manifest is a root path, ``/acdc-schemas.json`` (served), and the build ALSO writes a
                    byte-identical ``.well-known/acdc-schemas.json`` MIRROR — kept for the cross-host convention the
                    repo wants other publishers to copy (it serves on hosts that don't strip dot-dirs), but never
                    the advertised URL on this host. The landing page and the ``_render_index`` link point at the
                    root path. This is a property of the Pages deploy action, not our build; a future move off
                    ``upload-pages-artifact`` could make ``.well-known`` primary.
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
          stage-status: planned
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
          stage-status: planned
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
          stage-status: planned
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
