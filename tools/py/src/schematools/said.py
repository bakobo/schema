"""SAID computation — the keri oracle interface (this.i @xv4m7d).

A schema's ``$id`` is a SAID: a Blake3 digest over the canonically-serialized,
saidified schema content. The entire KERI/ACDC ecosystem verifies against
keri's computation of it, so keri is the single source of truth here and every
SAID this module produces must be byte-identical to it.

The saidification order is faithful to how this repo's corpus was minted: the
inner ``a``/``e``/``r`` block ids are computed first (from each block's own
content), then the top-level ``$id`` is computed over the whole schema with
those block ids in place.
"""

from __future__ import annotations

import copy

from keri.core.coring import MtrDex, Saider

#: The label whose value is the SAID. For a JSON Schema this is ``$id``.
SAID_LABEL = "$id"

#: The digest code. Blake3-256 is what the corpus was minted with.
SAID_CODE = MtrDex.Blake3_256

#: The saidifiable inner blocks of an ACDC schema, in canonical order.
BLOCKS = ("a", "e", "r")


def _saidify_in_place(schema: dict, label: str, code: str) -> None:
    props = schema.get("properties")
    if isinstance(props, dict):
        for name in BLOCKS:
            block = props.get(name)
            if not isinstance(block, dict):
                continue
            if label in block:
                block[label] = Saider(sad=block, code=code, label=label).qb64
            elif isinstance(block.get("oneOf"), list):
                for arm in block["oneOf"]:
                    if isinstance(arm, dict) and label in arm:
                        arm[label] = Saider(sad=arm, code=code, label=label).qb64
    schema[label] = Saider(sad=schema, code=code, label=label).qb64


def saidify_schema(schema: dict, *, label: str = SAID_LABEL, code: str = SAID_CODE) -> dict:
    """Return a deep copy of ``schema`` with all SAIDs (block ids, then the
    top-level id) freshly computed and written in."""
    out = copy.deepcopy(schema)
    _saidify_in_place(out, label, code)
    return out


def compute_schema_said(schema: dict, *, label: str = SAID_LABEL, code: str = SAID_CODE) -> str:
    """Return the top-level SAID ``schema`` *should* carry, without mutating it.

    Used by the SAID-integrity check: compare this against the embedded
    ``$id`` to detect a schema whose content and SAID have drifted apart.
    """
    return saidify_schema(schema, label=label, code=code)[label]
