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
