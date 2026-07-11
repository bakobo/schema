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
from keri.core.serdering import SerderACDC

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


#: The label carrying a self-addressing datum's own SAID (``d`` for an ACDC).
SAD_LABEL = "d"


def _saidify_children(node: dict, label: str) -> None:
    # Post-order: saidify every nested block carrying the label, deepest first,
    # so an enclosing block's SAID is computed over already-correct child SAIDs.
    for value in node.values():
        if isinstance(value, dict) and label in value:
            _saidify_children(value, label)
            _, saidified = Saider.saidify(sad=value, label=label)
            value[label] = saidified[label]


def saidify_sad(sad: dict, *, label: str = SAD_LABEL) -> dict:
    """Return a deep copy of a self-addressing datum with every SAID recomputed.

    Nested blocks (the ``a``/``e``/``r`` of an ACDC) are saidified bottom-up so
    a change deep in the structure propagates outward. For a versioned ACDC (a
    top-level ``v`` string), the top is finished with keri's ``SerderACDC``,
    which recomputes both the version string's size and the top-level ``d`` —
    so arbitrary content edits (not only SAID-for-SAID swaps) stay correct.
    A plain, unversioned SAD is finished with :class:`Saider` alone.
    """
    out = copy.deepcopy(sad)
    _saidify_children(out, label)
    if "v" in out and label == SAD_LABEL:
        out = SerderACDC(sad=out, makify=True).sad
    elif label in out:
        _, saidified = Saider.saidify(sad=out, label=label)
        out[label] = saidified[label]
    return out
