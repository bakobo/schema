"""Shared fixtures for the schematools test suite."""

from __future__ import annotations

from pathlib import Path

import pytest

from tests.support import minimal_schema, write_registry, write_schema


@pytest.fixture
def synthetic_repo(tmp_path: Path) -> Path:
    """A temp dir holding one valid, saidified, registered schema ("widget")."""
    write_schema(tmp_path, "widget", minimal_schema("Widget", "color"))
    write_registry(tmp_path)
    return tmp_path
