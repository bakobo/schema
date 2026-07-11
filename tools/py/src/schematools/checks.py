"""Repo-wide schema invariants — the linter (this.i @n7xk4r).

Each check returns a list of :class:`Problem`. An empty list means the
invariant holds. The checks are:

  - ``check_structure``      valid JSON + valid Draft 2020-12 schema
  - ``check_said_integrity`` recomputed SAID == embedded ``$id`` (the keystone)
  - ``check_registry``       registry.json <-> disk agree (indexed once, path
                             correct, ``$id`` == key, no orphans, no dangling)
  - ``check_examples``       ``<folder>/example.json`` validates against its schema

Per-schema instance *fixtures* (negative corpora, semantic rules, regression)
are the other axis of @n7xk4r and are added as GCD's evolution pulls them in.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

from jsonschema import Draft202012Validator
from jsonschema import exceptions as js_exc

from .repo import discover_schemas, load_registry
from .said import SAID_LABEL, compute_schema_said


@dataclass(frozen=True)
class Problem:
    """A single invariant violation."""

    check: str    #: which check produced it ("structure", "said", ...)
    where: str    #: schema-relative locus, e.g. "gcd/gcd.schema.json"
    message: str  #: human-readable description

    def __str__(self) -> str:
        return f"[{self.check}] {self.where}: {self.message}"


def _load_json(path: Path):
    return json.loads(Path(path).read_text())


def check_structure(root: str | Path) -> list[Problem]:
    """Every schema file is valid JSON and a valid Draft 2020-12 schema."""
    problems: list[Problem] = []
    for entry in discover_schemas(root):
        try:
            schema = _load_json(entry.path)
        except json.JSONDecodeError as exc:
            problems.append(Problem("structure", entry.rel, f"invalid JSON: {exc}"))
            continue
        try:
            Draft202012Validator.check_schema(schema)
        except js_exc.SchemaError as exc:
            problems.append(Problem("structure", entry.rel, f"invalid JSON Schema: {exc.message}"))
    return problems


def check_said_integrity(root: str | Path) -> list[Problem]:
    """Recomputed SAID must equal the embedded ``$id`` (this.i @xv4m7d)."""
    problems: list[Problem] = []
    for entry in discover_schemas(root):
        try:
            schema = _load_json(entry.path)
        except json.JSONDecodeError as exc:
            problems.append(Problem("said", entry.rel, f"unparseable, cannot verify SAID: {exc}"))
            continue
        stored = schema.get(SAID_LABEL)
        recomputed = compute_schema_said(schema)
        if stored != recomputed:
            problems.append(
                Problem("said", entry.rel, f"$id {stored!r} != recomputed {recomputed!r}")
            )
    return problems


def check_registry(root: str | Path) -> list[Problem]:
    """registry.json and the schemas on disk must agree.

    Every registry entry points at an existing schema whose ``$id`` equals the
    registry key; every schema on disk is indexed exactly once.
    """
    problems: list[Problem] = []
    registry = load_registry(root)
    entries = discover_schemas(root)
    by_rel = {e.rel: e for e in entries}

    indexed: set[str] = set()
    for said, rel in registry.items():
        indexed.add(rel)
        entry = by_rel.get(rel)
        if entry is None:
            problems.append(Problem("registry", said, f"registry path {rel!r} not found on disk"))
            continue
        try:
            schema = _load_json(entry.path)
        except json.JSONDecodeError:
            problems.append(Problem("registry", rel, "unparseable, cannot verify $id vs registry key"))
            continue
        stored = schema.get(SAID_LABEL)
        if stored != said:
            problems.append(
                Problem("registry", rel, f"registry key {said!r} != schema $id {stored!r}")
            )

    for entry in entries:
        if entry.rel not in indexed:
            problems.append(Problem("registry", entry.rel, "schema on disk but absent from registry.json"))
    return problems


def check_examples(root: str | Path) -> list[Problem]:
    """Where present, ``<folder>/example.json`` validates against its schema."""
    problems: list[Problem] = []
    for entry in discover_schemas(root):
        if entry.example is None:
            continue
        try:
            schema = _load_json(entry.path)
        except json.JSONDecodeError:
            problems.append(Problem("example", entry.rel, "schema unparseable, cannot validate example"))
            continue
        try:
            instance = _load_json(entry.example)
        except json.JSONDecodeError as exc:
            problems.append(Problem("example", f"{entry.name}/example.json", f"invalid JSON: {exc}"))
            continue
        errors = sorted(Draft202012Validator(schema).iter_errors(instance), key=lambda e: list(e.path))
        for err in errors:
            loc = "/".join(str(p) for p in err.absolute_path) or "<root>"
            problems.append(Problem("example", f"{entry.name}/example.json", f"at {loc}: {err.message[:160]}"))
    return problems


#: All repo-wide checks, in a stable order.
ALL_CHECKS = (check_structure, check_said_integrity, check_registry, check_examples)


def run_all(root: str | Path) -> list[Problem]:
    """Run every check over ``root`` and return the combined problem list."""
    problems: list[Problem] = []
    for check in ALL_CHECKS:
        problems.extend(check(root))
    return problems
