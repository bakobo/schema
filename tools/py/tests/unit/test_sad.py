"""Unit tests for SAD (ACDC instance) saidification."""

from __future__ import annotations

import copy

from keri.core.serdering import SerderACDC

from schematools.said import saidify_sad


def _acdc() -> dict:
    """A minimal expanded ACDC with nested a/e/r blocks, SAIDs unset."""
    return {
        "v": "ACDC10JSON000000_",
        "d": "",
        "i": "EC4SuEyzrRwu3FWFrK0Ubd9xejlo5bUwAtGcbBGUk2nL",
        "s": "EM3kQ1QEU3kJFqV8aZrse-QXs5oNlaFfaiwEUFt4uq4C",
        "a": {"d": "", "role": "example", "c_pgeo": ["US"]},
        "r": {"d": "", "rule": "some disclaimer text"},
    }


def test_saidify_sad_makes_a_fixed_point():
    out = saidify_sad(_acdc())
    # Re-makifying an already-saidified ACDC via the oracle changes nothing.
    remade = SerderACDC(sad=copy.deepcopy(out), makify=True)
    assert out == remade.sad


def test_saidify_sad_sets_version_size():
    out = saidify_sad(_acdc())
    assert out["v"].startswith("ACDC10JSON")
    assert out["v"] != "ACDC10JSON000000_"  # size was filled in


def test_saidify_sad_computes_nested_block_saids():
    out = saidify_sad(_acdc())
    for block in ("a", "r"):
        assert out[block]["d"].startswith("E")
    # nested SAIDs are self-consistent under the oracle
    from keri.core.coring import Saider

    for block in ("a", "r"):
        _, checked = Saider.saidify(sad=copy.deepcopy(out[block]), label="d")
        assert checked["d"] == out[block]["d"]


def test_saidify_sad_does_not_mutate_input():
    original = _acdc()
    snapshot = copy.deepcopy(original)
    saidify_sad(original)
    assert original == snapshot


def test_content_change_changes_top_said():
    before = saidify_sad(_acdc())["d"]
    changed = _acdc()
    changed["a"]["role"] = "different"
    assert saidify_sad(changed)["d"] != before


def test_saidify_sad_without_top_label_only_saidifies_children():
    # No top-level 'd' and no 'v': children are saidified, top is left as-is.
    out = saidify_sad({"a": {"d": "", "x": "y"}})
    assert "d" not in out
    assert out["a"]["d"].startswith("E")
