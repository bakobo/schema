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
