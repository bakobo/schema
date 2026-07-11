"""Reusable builders for synthetic schema repos (shared by fixtures and tests)."""

from __future__ import annotations

import json
from pathlib import Path

from schematools.repo import REGISTRY_NAME
from schematools.said import SAID_LABEL, saidify_schema


def minimal_schema(title: str, extra_prop: str) -> dict:
    """A minimal but valid ACDC-ish JSON Schema with one attribute property."""
    return {
        "$id": "",
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": title,
        "type": "object",
        "properties": {
            "d": {"type": "string"},
            "a": {
                "oneOf": [
                    {"type": "string"},
                    {
                        "$id": "",
                        "type": "object",
                        "properties": {
                            "d": {"type": "string"},
                            extra_prop: {"type": "string"},
                        },
                        "required": ["d", extra_prop],
                        "additionalProperties": False,
                    },
                ]
            },
        },
        "required": ["d", "a"],
    }


def write_schema(root: Path, name: str, schema: dict) -> Path:
    """Saidify ``schema`` and write it to ``<root>/<name>/<name>.schema.json``."""
    folder = root / name
    folder.mkdir(parents=True, exist_ok=True)
    saidified = saidify_schema(schema)
    path = folder / f"{name}.schema.json"
    path.write_text(json.dumps(saidified, indent=2) + "\n")
    return path


def write_registry(root: Path) -> None:
    """Build ``registry.json`` from whatever schemas exist under ``root``."""
    registry = {}
    for folder in sorted(root.iterdir()):
        if not folder.is_dir():
            continue
        schema_file = folder / f"{folder.name}.schema.json"
        if schema_file.is_file():
            schema = json.loads(schema_file.read_text())
            registry[schema[SAID_LABEL]] = f"{folder.name}/{folder.name}.schema.json"
    (root / REGISTRY_NAME).write_text(json.dumps(registry, indent=2) + "\n")
