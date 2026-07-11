"""Conformance suite over the *real* schema corpus in this repo.

Unlike the unit tests (which use synthetic fixtures to prove the tooling
works), this suite runs the invariant checks against the actual schemas and
asserts every one is clean.

Known, tracked pre-existing failures are marked ``xfail(strict=True)`` — a
ratchet: the moment the underlying defect is fixed the test XPASSes and *fails*
the run, forcing the marker's removal. That keeps the suite honest (nothing is
silently tolerated) while still gating on any NEW regression.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from schematools import checks
from schematools.repo import discover_schemas, find_repo_root

ROOT = find_repo_root(Path(__file__).resolve().parent)

CHECK_FUNCS = {
    "structure": checks.check_structure,
    "said": checks.check_said_integrity,
    "registry": checks.check_registry,
    "example": checks.check_examples,
}

# (schema_name, check_name) -> reason. Each cites the tracking tick.
KNOWN_XFAIL = {
    # Task 1: GCD was inherited as invalid JSON; repair + re-SAIDify clears all four.
    ("gcd", "structure"): "Task 1: GCD inherited as invalid JSON (~4wfn)",
    ("gcd", "said"): "Task 1: GCD unparseable, SAID cannot verify (~4wfn)",
    ("gcd", "registry"): "Task 1: GCD unparseable, registry key unverifiable (~4wfn)",
    ("gcd", "example"): "Task 1: GCD schema unparseable, example unvalidatable (~4wfn)",
    # Inherited content bugs: example 'a' block holds face-to-face fields.
    ("ai-coder", "example"): "inherited content bug: example holds face-to-face fields (~56xf)",
    ("award", "example"): "inherited content bug: example holds face-to-face fields (~5s4i)",
}

SCHEMA_NAMES = [entry.name for entry in discover_schemas(ROOT)]


@pytest.fixture(scope="session")
def problems_by_check() -> dict[str, list]:
    """Run each check once over the real corpus; reused across parametrizations."""
    return {name: list(fn(ROOT)) for name, fn in CHECK_FUNCS.items()}


def _problems_for(problems: list, schema_name: str) -> list:
    return [p for p in problems if p.where.split("/")[0] == schema_name or p.where == schema_name]


@pytest.mark.parametrize("check", list(CHECK_FUNCS))
@pytest.mark.parametrize("schema_name", SCHEMA_NAMES)
def test_schema_is_clean(request, problems_by_check, schema_name, check):
    reason = KNOWN_XFAIL.get((schema_name, check))
    if reason:
        request.applymarker(pytest.mark.xfail(reason=reason, strict=True))
    hits = _problems_for(problems_by_check[check], schema_name)
    assert not hits, "\n".join(str(p) for p in hits)
