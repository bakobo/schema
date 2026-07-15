"""Discovery of a schema repo — generic, no repo-specific hard-coding (this.i @c5tj3p).

A "schema repo" is any directory containing a ``registry.json`` and a set of
``<folder>/<folder>.schema.json`` files. Everything here is driven by that
convention, so the same tooling serves any issuer's schema repo, not just this one.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

#: The crawl-free index of released schemas: ``{SAID: relative/path.schema.json}``.
REGISTRY_NAME = "registry.json"


class SchemaRepoNotFoundError(FileNotFoundError):
    """No schema repository (a directory with a ``registry.json``) was found.

    Carries a stable symbolic :attr:`code` so a caller can branch on the kind of
    failure without string-matching (Bakobo error-handling standard). Subclasses
    :class:`FileNotFoundError` so existing callers that catch that still work.
    Permanent: the same location will fail identically until a ``registry.json``
    exists at or above it, so retrying unchanged cannot help.
    """

    #: Stable identifier, independent of the human-readable message.
    code = "BK_NO_SCHEMA_REPO"

    def __init__(self, searched: Path):
        self.searched = searched
        super().__init__(
            f"[{self.code}] No schema repository was found at or above {searched}. "
            f"A schema repository is a directory that contains a {REGISTRY_NAME!r} index. "
            f"Run the command from inside one, or pass --root pointing at one. "
            f"Retrying from the same location will not help."
        )


def find_repo_root(start: str | Path | None = None) -> Path:
    """Walk up from ``start`` (default: cwd) to the nearest dir with a registry.

    Raises :class:`SchemaRepoNotFoundError` (a coded ``FileNotFoundError``) when
    no ``registry.json`` is found at or above ``start``.
    """
    here = Path(start).resolve() if start is not None else Path.cwd()
    if here.is_file():
        here = here.parent
    for candidate in (here, *here.parents):
        if (candidate / REGISTRY_NAME).is_file():
            return candidate
    raise SchemaRepoNotFoundError(here)


def load_registry(root: str | Path) -> dict[str, str]:
    """Return the parsed ``registry.json`` mapping (SAID -> relative path)."""
    return json.loads((Path(root) / REGISTRY_NAME).read_text())


@dataclass(frozen=True)
class SchemaEntry:
    """One discovered schema on disk."""

    name: str          #: folder name, e.g. "gcd"
    path: Path         #: absolute path to <name>/<name>.schema.json
    rel: str           #: path relative to the repo root, forward-slashed
    example: Path | None  #: <name>/example.json if it exists, else None


def discover_schemas(root: str | Path) -> list[SchemaEntry]:
    """Return every ``<folder>/<folder>.schema.json`` under ``root``, sorted by name.

    The ``<folder>/<folder>.schema.json`` convention naturally excludes non-schema
    directories (``tools``, ``oldtools``, ``docs``, dot-dirs) with no explicit list.
    """
    root = Path(root)
    entries: list[SchemaEntry] = []
    for child in sorted(root.iterdir(), key=lambda p: p.name):
        if not child.is_dir() or child.name.startswith("."):
            continue
        schema_file = child / f"{child.name}.schema.json"
        if not schema_file.is_file():
            continue
        example = child / "example.json"
        entries.append(
            SchemaEntry(
                name=child.name,
                path=schema_file,
                rel=f"{child.name}/{child.name}.schema.json",
                example=example if example.is_file() else None,
            )
        )
    return entries
