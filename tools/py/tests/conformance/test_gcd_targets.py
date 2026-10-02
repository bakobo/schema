"""GCD 4.0.0: the targets of acts, and who may designate them (`this.i` @yivcussv)."""

import json
from pathlib import Path

import jsonschema
import pytest

from keri.core.coring import DigDex, Matter, PreDex

from schematools.said import compute_schema_said, saidify_sad

ROOT = Path(__file__).resolve().parents[4]
FOLDER = ROOT / "gcd"
ARCHIVE = ROOT / "gcd-3.1.0"
PRIOR_SAID = "EDqAod5ZiCNfQziVHjOALNNRabw2iwpAYqqOsEXUcxm5"
AID = "EC4SuEyzrRwu3FWFrK0Ubd9xejlo5bUwAtGcbBGUk2nL"
PROOF = "EGZ_DdmzryjQOtOdQauTm_YxggbVM7EWelk8IBxsnC-d"  # a placeholder until proof requests exist (~6jpj)
IBAN = "DE89370400440532013000"
ECDSA_AID = "1AAJAsBQkKhR8657x16VpIFI4zf8l98AXPn7VS6Q_1zhHpc5"
MAX_TARGETS, MAX_ENTRY_ACTS, MAX_AIDS, MAX_KIND, MAX_ID, MAX_ACT = 1024, 30, 64, 64, 256, 128
EFFECTS = ["observe", "create", "modify", "preserve", "destroy"]
KINDS = ["info", "record", "commitment", "authority", "resource", "relationship"]
POINTS = [f"{e} {k}" for e in EFFECTS for k in KINDS]  # every point on the grid
assert len(POINTS) == MAX_ENTRY_ACTS


def _schema() -> dict:
    return json.loads((FOLDER / "gcd.schema.json").read_text())


def _load(path: Path) -> dict:
    return json.loads(path.read_text())


def _example() -> dict:
    return _load(FOLDER / "example.json")


def _gallery() -> list[Path]:
    return sorted((FOLDER / "examples").glob("*.json"))


def _errors(instance) -> list[jsonschema.ValidationError]:
    validator = jsonschema.Draft202012Validator(_schema(), format_checker=jsonschema.FormatChecker())
    return list(validator.iter_errors(instance))


def _with_targets(targets) -> dict:
    example = _example()
    example["a"]["constraints"]["targets"] = targets
    return example


def _refused(instance) -> None:
    assert _errors(instance), "the schema accepted an instance it must refuse"


def _accepted(instance) -> None:
    assert not _errors(instance), [e.message for e in _errors(instance)]


def test_the_schema_names_itself_is_registered_and_is_4_0_0() -> None:
    schema = _schema()
    assert compute_schema_said(schema) == schema["$id"]
    assert schema["$id"] != PRIOR_SAID
    registry = _load(ROOT / "registry.json")
    assert registry[schema["$id"]] == "gcd/gcd.schema.json"
    assert schema["version"] == "4.0.0"


def test_3_1_0_is_archived_under_its_own_said() -> None:
    """A MAJOR bump archives its predecessor byte-identical and keeps it resolvable (@r5vk3n)."""
    archived = _load(ARCHIVE / "gcd-3.1.0.schema.json")
    assert archived["$id"] == PRIOR_SAID == compute_schema_said(archived)
    assert archived["version"] == "3.1.0"
    assert _load(ROOT / "registry.json")[PRIOR_SAID] == "gcd-3.1.0/gcd-3.1.0.schema.json"


def test_a_3_1_0_credential_that_carries_acts_is_not_a_4_0_0_one() -> None:
    """The reason this is MAJOR: acts without targets was valid, and is not now (@k3wm7d)."""
    prior = _load(ARCHIVE / "example.json")
    prior["s"] = _schema()["$id"]
    assert "acts" in prior["a"]["constraints"] and "targets" not in prior["a"]["constraints"]
    _refused(prior)
    arm = jsonschema.Draft202012Validator(_schema()["properties"]["a"]["oneOf"][1])
    assert [e.validator for e in arm.iter_errors(prior["a"])] == ["dependentRequired"]


def test_every_positive_example_validates_and_is_saidified() -> None:
    for path in [FOLDER / "example.json", *_gallery()]:
        instance = _load(path)
        _accepted(instance)
        assert instance["s"] == _schema()["$id"], path.name
        assert saidify_sad(instance) == instance, path.name


def test_every_example_that_grants_acts_names_its_targets() -> None:
    for path in [FOLDER / "example.json", *_gallery()]:
        constraints = _load(path)["a"].get("constraints", {})
        if "acts" in constraints:
            assert constraints["targets"], path.name


def test_the_gallery_shows_each_entry_shape() -> None:
    """Named targets, and all three designator forms, each appear somewhere in the gallery."""
    entries = [entry for path in _gallery()
               for entry in _load(path)["a"].get("constraints", {}).get("targets", [])]
    assert any("id" in entry and entry["kind"] == "iban" for entry in entries)
    assert any("id" in entry and "acts" in entry for entry in entries)
    forms = [entry["designatedBy"] for entry in entries if "designatedBy" in entry]
    assert "any" in forms
    assert any(isinstance(form, dict) and "aids" in form for form in forms)
    assert any(isinstance(form, dict) and "proof" in form for form in forms)


def test_the_payments_steward_is_the_confused_deputy_example() -> None:
    constraints = _load(FOLDER / "examples" / "payments-steward.json")["a"]["constraints"]
    named = [entry["id"] for entry in constraints["targets"] if entry["kind"] == "iban" and "id" in entry]
    assert len(named) >= 2
    assert "monetaryLimit" in constraints


# --- what the schema refuses -------------------------------------------------------------------

def test_acts_without_targets_is_refused() -> None:
    example = _example()
    del example["a"]["constraints"]["targets"]
    _refused(example)
    arm = jsonschema.Draft202012Validator(_schema()["properties"]["a"]["oneOf"][1])
    assert [e.validator for e in arm.iter_errors(example["a"])] == ["dependentRequired"]


@pytest.mark.parametrize("targets", [
    pytest.param([], id="empty"),
    pytest.param([{"id": AID}], id="missing-kind"),
    pytest.param([{"kind": "aid"}], id="neither-id-nor-designator"),
    pytest.param([{"kind": "aid", "id": AID, "designatedBy": "any"}], id="both-id-and-designator"),
    pytest.param([{"kind": "*", "id": AID}], id="wildcard-kind-on-a-named-target"),
    pytest.param([{"kind": "iban", "id": "de89 3704 0044 0532 0130 00"}], id="iban-not-canonical"),
    pytest.param([{"kind": "iban", "id": "DE89"}], id="iban-too-short"),
    pytest.param([{"kind": "aid", "id": "not an aid"}], id="aid-malformed"),
    pytest.param([{"kind": "said", "id": "E-too-short"}], id="said-malformed"),
    pytest.param([{"kind": "aid", "id": ""}], id="custom-shaped-empty-id"),
    pytest.param([{"kind": "Not A Kind", "id": "x"}], id="kind-malformed"),
    pytest.param([{"kind": "aid", "designatedBy": "anyone"}], id="designator-unknown-word"),
    pytest.param([{"kind": "aid", "designatedBy": {"roles": ["cfo"]}}], id="designator-unknown-form"),
    pytest.param([{"kind": "aid", "designatedBy": {"aids": []}}], id="designator-empty-aids"),
    pytest.param([{"kind": "aid", "designatedBy": {"aids": [AID], "proof": PROOF}}],
                 id="designator-two-forms"),
    pytest.param([{"kind": "aid", "designatedBy": {"proof": ""}}], id="designator-empty-proof"),
    pytest.param([{"kind": "aid", "id": AID, "acts": ["pay invoice"]}], id="entry-acts-off-grid"),
    pytest.param([{"kind": "aid", "id": AID, "acts": []}], id="entry-acts-empty"),
    pytest.param([{"kind": "aid", "id": AID, "maxAmount": "10 USD"}], id="entry-unknown-key"),
    # qb64: a derivation code this kind admits, and zero pad bits, not just the right length
    pytest.param([{"kind": "aid", "id": "_" * 44}], id="aid-no-derivation-code"),
    pytest.param([{"kind": "said", "id": "_" * 44}], id="said-no-derivation-code"),
    pytest.param([{"kind": "said", "id": "B" + AID[1:]}], id="said-with-a-key-code"),
    pytest.param([{"kind": "aid", "id": "EZ" + AID[2:]}], id="aid-nonzero-pad-bits"),
    pytest.param([{"kind": "aid", "designatedBy": {"aids": ["_" * 44]}}], id="designator-aid-malformed"),
    pytest.param([{"kind": "aid", "designatedBy": {"proof": "D" + PROOF[1:]}}],
                 id="designator-proof-not-a-said"),
    # bounds: cap + 1 at every new collection and string
    pytest.param([{"kind": f"k{n}", "id": "y"} for n in range(MAX_TARGETS + 1)],
                 id="too-many-targets"),
    pytest.param([{"kind": "aid", "designatedBy": {"aids": [f"E{'A' * 42}{c}" for c in
                   "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"] + [ECDSA_AID]}}],
                 id="too-many-designator-aids"),
    pytest.param([{"kind": "acme.ref", "id": "y" * (MAX_ID + 1)}], id="id-too-long"),
])
def test_a_malformed_target_is_refused(targets) -> None:
    instance = _with_targets(targets)
    _refused(instance)
    # The a block is a oneOf of its compact SAID and its expanded form, so the whole-credential
    # error is a oneOf failure. Validate the expanded arm directly to see that each refusal is
    # this fixture's own defect and nothing else.
    arm = jsonschema.Draft202012Validator(_schema()["properties"]["a"]["oneOf"][1])
    errors = list(arm.iter_errors(instance["a"]))
    assert errors
    assert all("targets" in list(e.absolute_path) for e in errors), [e.message for e in errors]


# --- what the schema admits --------------------------------------------------------------------

def test_targets_without_acts_is_admitted() -> None:
    """Any act, but only on these targets: the one constraint, half-specified the safe way."""
    example = _with_targets([{"kind": "aid", "id": AID}])
    del example["a"]["constraints"]["acts"]
    _accepted(example)


@pytest.mark.parametrize("entry", [
    pytest.param({"kind": "iban", "id": IBAN}, id="iban"),
    pytest.param({"kind": "aid", "id": AID}, id="aid"),
    pytest.param({"kind": "said", "id": PROOF}, id="said"),
    pytest.param({"kind": "acme.deploy-service", "id": "billing-api"}, id="gfw-defined-kind"),
    pytest.param({"kind": "*", "designatedBy": "any"}, id="anyone-declared"),
    pytest.param({"kind": "iban", "designatedBy": {"aids": [AID]}}, id="aid-designators"),
    pytest.param({"kind": "*", "designatedBy": {"proof": PROOF}}, id="proof-designator"),
    pytest.param({"kind": "iban", "id": IBAN, "acts": ["create commitment"]}, id="narrowed"),
    pytest.param({"kind": "aid", "id": ECDSA_AID}, id="ecdsa-aid"),
    pytest.param({"kind": "aid", "id": AID, "acts": POINTS}, id="entry-acts-at-cap"),
    pytest.param({"kind": "k" * MAX_KIND, "id": "y" * MAX_ID}, id="kind-and-id-at-cap"),
])
def test_a_well_formed_target_is_admitted(entry) -> None:
    _accepted(_with_targets([entry]))


def test_targets_at_cap_are_admitted() -> None:
    _accepted(_with_targets([{"kind": f"k{n}", "id": "y"} for n in range(MAX_TARGETS)]))


def test_designator_aids_at_cap_are_admitted() -> None:
    aids = [f"E{'A' * 42}{c}" for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"]
    assert len(aids) == MAX_AIDS
    _accepted(_with_targets([{"kind": "aid", "designatedBy": {"aids": aids}}]))


def test_the_schema_says_unknown_kinds_match_nothing() -> None:
    """Fail-closed is the verifier's to enforce (@vy7qoj), so the schema must say it."""
    targets = _schema()["properties"]["a"]["oneOf"][1]["properties"]["constraints"]["properties"]["targets"]
    assert "matches nothing" in targets["description"]
    assert "MUST deny" in targets["description"]


def _codes(dex) -> list[str]:
    return sorted(value for name, value in vars(dex).items() if not name.startswith("_"))


def _vector(code: str, fill: int) -> str:
    """A well-formed qb64 value for this derivation code, made by keri itself."""
    return Matter(raw=bytes([fill]) * Matter._rawSize(code), code=code).qb64


@pytest.mark.parametrize("code", _codes(PreDex))
@pytest.mark.parametrize("fill", [0x00, 0x5A, 0xFF])
def test_every_keri_prefix_code_is_an_aid(code, fill) -> None:
    """The aid kind is exactly keri's PreDex: every code it can derive a prefix with (#13 review)."""
    aid = _vector(code, fill)
    _accepted(_with_targets([{"kind": "aid", "id": aid}]))
    _accepted(_with_targets([{"kind": "aid", "designatedBy": {"aids": [aid]}}]))


@pytest.mark.parametrize("code", _codes(DigDex))
@pytest.mark.parametrize("fill", [0x00, 0x5A, 0xFF])
def test_every_keri_digest_code_is_a_said(code, fill) -> None:
    said = _vector(code, fill)
    _accepted(_with_targets([{"kind": "said", "id": said}]))
    _accepted(_with_targets([{"kind": "*", "designatedBy": {"proof": said}}]))


# Python validators also admit a trailing newline after an anchored pattern (~3b3s).
def test_a_signature_is_not_an_aid() -> None:
    """A qb64 value of the right shape but a code outside PreDex is refused."""
    signature = _vector("0B", 0x5A)  # Ed25519 signature: 88 characters, not a prefix code
    _refused(_with_targets([{"kind": "aid", "id": signature}]))


def _act(length: int) -> str:
    """A valid act point of exactly this length, padded inside its brace enumeration."""
    act = "observe {info," + " " * (length - len("observe {info,record}")) + "record}"
    assert len(act) == length
    return act


#: The two entry shapes, so every bound is proven on both arms of the oneOf (#13 review).
SHAPES = {"named": {"kind": "aid", "id": AID}, "designator": {"kind": "aid", "designatedBy": "any"}}


def _entry(shape: str, **extra) -> dict:
    return {**SHAPES[shape], **extra}


def _refused_for_targets(entry: dict) -> None:
    instance = _with_targets([entry])
    _refused(instance)
    arm = jsonschema.Draft202012Validator(_schema()["properties"]["a"]["oneOf"][1])
    errors = list(arm.iter_errors(instance["a"]))
    assert errors and all("targets" in list(e.absolute_path) for e in errors)


@pytest.mark.parametrize("shape", SHAPES)
def test_entry_bounds_hold_at_the_cap_on_both_shapes(shape) -> None:
    _accepted(_with_targets([_entry(shape, acts=POINTS)]))
    _accepted(_with_targets([_entry(shape, acts=[_act(MAX_ACT)])]))
    _accepted(_with_targets([{**_entry(shape), "kind": "k" * MAX_KIND}]))


@pytest.mark.parametrize("shape", SHAPES)
def test_entry_bounds_refuse_one_past_the_cap_on_both_shapes(shape) -> None:
    _refused_for_targets(_entry(shape, acts=POINTS + ["observe {info, record}"]))
    _refused_for_targets(_entry(shape, acts=[_act(MAX_ACT + 1)]))
    _refused_for_targets({**_entry(shape), "kind": "k" * (MAX_KIND + 1)})
