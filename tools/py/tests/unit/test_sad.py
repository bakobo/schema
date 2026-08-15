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
        "s": "EIqGVj_kEr0GTBELK6QtALn_sqHExLBDl2gHK82Xl-x3",
        "a": {"d": "", "facet": {"role": "example"}, "constraints": {"physGeos": ["US"]}},
        "r": {"d": "", "onlyDelegateHeldAuthority": "some disclaimer text"},
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
    changed["a"]["facet"]["role"] = "different"
    assert saidify_sad(changed)["d"] != before


def test_saidify_sad_without_top_label_only_saidifies_children():
    # No top-level 'd' and no 'v': children are saidified, top is left as-is.
    out = saidify_sad({"a": {"d": "", "x": "y"}})
    assert "d" not in out
    assert out["a"]["d"].startswith("E")


def _acdc_v2() -> dict:
    """A minimal expanded ACDC v2 ``acm`` instance (this.i @h3or4x, @enr3eg).

    The shape the fork's ``acdcmap`` map form emits: ``rd`` present, the
    attribute section carrying no ``d`` (a non-SAIDed block, fully expanded in
    most-compact computation), the rule section carrying one.
    """
    return {
        "v": "ACDCCAACAAJSONAAAA.",
        "t": "acm",
        "d": "",
        "i": "EC4SuEyzrRwu3FWFrK0Ubd9xejlo5bUwAtGcbBGUk2nL",
        "rd": "EJl5EUxL23p_pqgN3IyM-pzru89Nb7NzOM8ijH644xSU",
        "s": "EIqGVj_kEr0GTBELK6QtALn_sqHExLBDl2gHK82Xl-x3",
        "a": {
            "i": "EIkxoE8eYnPLCydPcyc_lhQgwOdBHwzkSe36e2gqEH-5",
            "facet": {"role": "example"},
            "constraints": {"physGeos": ["US"]},
        },
        "r": {"d": "", "onlyDelegateHeldAuthority": "some disclaimer text"},
    }


def test_saidify_sad_v2_acm_is_a_fixed_point():
    out = saidify_sad(_acdc_v2())
    assert saidify_sad(out) == out
    # Re-makifying an already-saidified v2 ACDC via the oracle changes nothing.
    remade = SerderACDC(sad=copy.deepcopy(out), makify=True)
    assert out == remade.sad


def test_saidify_sad_v2_fills_rule_said_top_said_and_version():
    out = saidify_sad(_acdc_v2())
    assert out["r"]["d"].startswith("E")
    assert out["d"].startswith("E")
    assert out["v"].startswith("ACDCCAACAAJSON")
    assert out["v"] != "ACDCCAACAAJSONAAAA."  # size was filled in
    assert "d" not in out["a"]  # a d-less attribute section stays d-less


def test_saidify_sad_v2_top_said_is_most_compact():
    # The top-level 'd' of the expanded form must equal the 'd' of the compact
    # form in which the SAIDed rule section is replaced by its SAID — the
    # most-compact-form invariant (spec-body.md §"Most compact form SAID").
    out = saidify_sad(_acdc_v2())
    compact = copy.deepcopy(out)
    compact["r"] = out["r"]["d"]
    remade = SerderACDC(sad=compact, makify=True)
    assert remade.sad["d"] == out["d"]
