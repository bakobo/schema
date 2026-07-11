"""The ``schematools`` command-line entry point.

Subcommands:
  - ``check``    run all conformance checks over a schema repo (CI gate).
  - ``saidify``  (re)compute and write SAIDs into a schema file.
  - ``registry`` rebuild ``registry.json`` from the schemas on disk.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from . import checks
from .repo import REGISTRY_NAME, discover_schemas, find_repo_root
from .said import SAD_LABEL, SAID_LABEL, saidify_sad, saidify_schema


def _resolve_root(root: str | None) -> Path:
    return Path(root).resolve() if root else find_repo_root()


def cmd_check(args: argparse.Namespace) -> int:
    root = _resolve_root(args.root)
    problems = checks.run_all(root)
    for problem in problems:
        print(problem, file=sys.stderr)
    count = len(problems)
    schemas = len(discover_schemas(root))
    verdict = "FAIL" if count else "OK"
    print(f"{verdict}: {count} problem(s) across {schemas} schema(s) in {root}")
    return 1 if count else 0


def cmd_saidify(args: argparse.Namespace) -> int:
    path = Path(args.file).resolve()
    schema = json.loads(path.read_text())
    saidified = saidify_schema(schema)
    path.write_text(json.dumps(saidified, indent=2) + "\n")
    print(f"saidified {path} -> {SAID_LABEL} {saidified[SAID_LABEL]}")
    return 0


def cmd_saidify_sad(args: argparse.Namespace) -> int:
    path = Path(args.file).resolve()
    sad = json.loads(path.read_text())
    saidified = saidify_sad(sad, label=args.label)
    path.write_text(json.dumps(saidified, indent=2) + "\n")
    print(f"saidified SAD {path} -> {args.label} {saidified[args.label]}")
    return 0


def cmd_registry(args: argparse.Namespace) -> int:
    root = _resolve_root(args.root)
    registry: dict[str, str] = {}
    for entry in discover_schemas(root):
        schema = json.loads(entry.path.read_text())
        registry[schema[SAID_LABEL]] = entry.rel
    (root / REGISTRY_NAME).write_text(json.dumps(registry, indent=2) + "\n")
    print(f"wrote {len(registry)} entries to {root / REGISTRY_NAME}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="schematools",
        description="ACDC / JSON-Schema authoring and conformance tooling",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p_check = sub.add_parser("check", help="run all conformance checks over a schema repo")
    p_check.add_argument("--root", help="repo root (default: auto-detect via registry.json)")
    p_check.set_defaults(func=cmd_check)

    p_said = sub.add_parser("saidify", help="(re)compute and write SAIDs into a schema file")
    p_said.add_argument("-f", "--file", required=True, help="path to the schema JSON file")
    p_said.set_defaults(func=cmd_saidify)

    p_sad = sub.add_parser("saidify-sad", help="(re)compute SAIDs of a self-addressing datum (ACDC instance)")
    p_sad.add_argument("-f", "--file", required=True, help="path to the SAD/instance JSON file")
    p_sad.add_argument("-l", "--label", default=SAD_LABEL, help=f"SAID field label (default: {SAD_LABEL!r})")
    p_sad.set_defaults(func=cmd_saidify_sad)

    p_reg = sub.add_parser("registry", help="rebuild registry.json from schemas on disk")
    p_reg.add_argument("--root", help="repo root (default: auto-detect via registry.json)")
    p_reg.set_defaults(func=cmd_registry)

    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
