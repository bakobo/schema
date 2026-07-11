"""schematools — ACDC / JSON-Schema authoring and conformance tooling.

Generic in shape (operates over a schema repo discovered from ``registry.json``,
with no repo-specific hard-coding — this.i @c5tj3p), so an eventual extraction
into its own package/repo stays cheap.

Layers:
  - ``said``   — SAID computation via the keri oracle (this.i @xv4m7d).
  - ``repo``   — discovery of a schema repo's schemas/registry.
  - ``checks`` — the repo-wide invariant checks (the linter; this.i @n7xk4r).
  - ``cli``    — the ``schematools`` command-line entry point.
"""

__all__ = ["said", "repo", "checks", "cli"]
