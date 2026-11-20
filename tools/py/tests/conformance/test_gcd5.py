"""GCD 5.0.0: grounded in agency law, with its two companions (`this.i` @3w3rkmt3 and children).

The schema-level oracles for @0yxjpld6 (principal, agentOfRecord, durable, grantText; a closed
facet), @39eu7enh (reservedPowers), @8tpzdyl5 (gcd-disclosure before the grant, gcd-acceptance
after it) and @8u06glee (complete, superseding rules; parent, disclosure and execution edges;
governing law; the delegate prose duty and the seven baseline duties), with the light path of
@2fgsylgz (rules revision 5: no agent of record, no disclosure, no acceptance credential).
"""

import copy
import json
from pathlib import Path

import jsonschema
import pytest

from keri.core.coring import Diger, MtrDex

from schematools.said import compute_schema_said, saidify_sad

ROOT = Path(__file__).resolve().parents[4]
GCD = ROOT / "gcd"
DISCLOSURE = ROOT / "gcd-disclosure"
ACCEPTANCE = ROOT / "gcd-acceptance"
ARCHIVE = ROOT / "gcd-4.0.0"
PRIOR_SAID = "ELDiEui48xsASGvDcNdsOwPptW0v4i-oN6-75_I1d60c"
VECTOR = Path(__file__).resolve().parents[1] / "vectors" / "cqt3.17-ai-purchasing-agent.json"

AID = "EC4SuEyzrRwu3FWFrK0Ubd9xejlo5bUwAtGcbBGUk2nL"
SAID = "EGZ_DdmzryjQOtOdQauTm_YxggbVM7EWelk8IBxsnC-d"
RESERVED = ["substitute", "redirectNotice", "selfDeal", "gift", "trust", "survivorship",
            "beneficiary", "waiveAnnuity", "fiduciaryPowers", "disclaim"]
OLD_RULE_KEYS = ["noRoleSemanticsWithoutGfw", "issuerNotResponsibleOutsideConstraints",
                 "noConstraintOutsideConstraints", "onlyDelegateHeldAuthority"]
RULE_KEYS = ["scope", "bindingParties", "machineGate", "useStdIfPossible", "governanceFramework",
             "relianceWithinConstraints", "subjectToLaw", "onlyHeldAuthority", "reservedPowers",
             "subDelegation", "acceptance", "disclosure", "termination", "humanReview",
             "grantTextStatus", "governingLaw", "delegateWarranty", "dutyConflicts"]
BASELINE_DUTIES = ["timelyReviewAndRevoke", "actWithinScope", "loyalty", "care", "confidentiality",
                   "keepRecords", "escalate"]


def _load(path: Path) -> dict:
    return json.loads(path.read_text())


def _gcd_schema() -> dict:
    return _load(GCD / "gcd.schema.json")


def _rules() -> dict:
    return _load(GCD / "rules.json")


def _example() -> dict:
    return _load(GCD / "example.json")


def _gallery() -> dict[str, dict]:
    return {path.stem: _load(path) for path in sorted((GCD / "examples").glob("*.json"))}


def _all_gcd_examples() -> dict[str, dict]:
    return {"example": _example(), **_gallery()}


def _errors(schema: dict, instance) -> list[jsonschema.ValidationError]:
    validator = jsonschema.Draft202012Validator(schema, format_checker=jsonschema.FormatChecker())
    return list(validator.iter_errors(instance))


def _accepted(instance, schema=None) -> None:
    errors = _errors(schema or _gcd_schema(), instance)
    assert not errors, [e.message for e in errors]


def _refused(instance, schema=None) -> None:
    assert _errors(schema or _gcd_schema(), instance), "the schema accepted an instance it must refuse"


def _arm(schema: dict, section: str) -> dict:
    return schema["properties"][section]["oneOf"][1]


def _failing_sections(schema: dict, instance: dict) -> set[str]:
    """Which parts of an instance fail: each expanded section alone, then the envelope around them.

    The whole-credential error on a section is a oneOf failure that hides its cause, so each
    expanded arm is validated directly. A fixture one mutation from valid fails in one place.
    """
    failing = set()
    for section in ("a", "e", "r"):
        if isinstance(instance.get(section), dict) and section in schema["properties"]:
            if _errors(_arm(schema, section), instance[section]):
                failing.add(section)
    envelope = {key: value for key, value in schema.items() if key != "properties"}
    envelope["properties"] = {key: ({} if key in ("a", "e", "r") else value)
                              for key, value in schema["properties"].items()}
    if _errors(envelope, instance):
        failing.add("envelope")
    return failing


def _with(path: list, value, base: dict | None = None) -> dict:
    instance = copy.deepcopy(base or _example())
    node = instance
    for key in path[:-1]:
        node = node.setdefault(key, {})
    node[path[-1]] = value
    return instance


def _without(path: list, base: dict | None = None) -> dict:
    instance = copy.deepcopy(base or _example())
    node = instance
    for key in path[:-1]:
        node = node[key]
    del node[path[-1]]
    return instance


# --- identity, archive, registry ----------------------------------------------------------------

def test_gcd_is_5_0_0_names_itself_and_is_registered() -> None:
    schema = _gcd_schema()
    assert schema["version"] == "5.0.0"
    assert compute_schema_said(schema) == schema["$id"] != PRIOR_SAID
    assert _load(ROOT / "registry.json")[schema["$id"]] == "gcd/gcd.schema.json"


def test_4_0_0_is_archived_byte_identical_under_its_own_said() -> None:
    archived = _load(ARCHIVE / "gcd-4.0.0.schema.json")
    assert archived["$id"] == PRIOR_SAID == compute_schema_said(archived)
    assert archived["version"] == "4.0.0"
    assert _load(ROOT / "registry.json")[PRIOR_SAID] == "gcd-4.0.0/gcd-4.0.0.schema.json"
    assert _load(ARCHIVE / "example.json")["s"] == PRIOR_SAID
    assert "gcd-4.0.0/index.md" in (ROOT / "zensical.toml").read_text()


@pytest.mark.parametrize("folder", ["gcd-disclosure", "gcd-acceptance"])
def test_each_companion_is_1_0_0_names_itself_and_is_registered(folder) -> None:
    schema = _load(ROOT / folder / f"{folder}.schema.json")
    assert schema["version"] == "1.0.0"
    assert compute_schema_said(schema) == schema["$id"]
    registry = _load(ROOT / "registry.json")
    assert registry[schema["$id"]] == f"{folder}/{folder}.schema.json"
    rules = _load(ROOT / folder / "rules.json")
    assert registry[rules["d"]] == f"{folder}/rules.json"
    assert f"{folder}/index.md" in (ROOT / "zensical.toml").read_text()
    assert (ROOT / folder / "index.md").is_file()


def test_the_companions_pin_each_other_in_issuance_order() -> None:
    """Disclosure before the grant, acceptance after it, so each pins only what already exists."""
    disclosure = _load(DISCLOSURE / "gcd-disclosure.schema.json")["$id"]
    edges = _arm(_gcd_schema(), "e")["properties"]
    assert edges["disclosure"]["properties"]["s"]["const"] == disclosure
    acceptance = _arm(_load(ACCEPTANCE / "gcd-acceptance.schema.json"), "e")["properties"]
    assert acceptance["gcd"]["properties"]["s"]["const"] == _gcd_schema()["$id"]


# --- facet (@0yxjpld6) -------------------------------------------------------------------------

def test_the_facet_is_closed_and_names_roles_not_liability() -> None:
    facet = _arm(_gcd_schema(), "a")["properties"]["facet"]
    assert facet["additionalProperties"] is False
    assert set(facet["properties"]) == {"role", "relationType", "principal", "agentOfRecord",
                                        "presentsAs", "exerciseMode", "durable", "grantText"}
    assert "defaults to the issuer" in facet["properties"]["principal"]["description"]
    description = facet["properties"]["agentOfRecord"]["description"]
    assert "own software" in description
    assert "law" in description


def test_agent_of_record_describes_the_light_and_heavy_paths() -> None:
    """@2fgsylgz: required for a third-party operator, optional for a legal person acting for itself."""
    description = _arm(_gcd_schema(), "a")["properties"]["facet"]["properties"]["agentOfRecord"]["description"]
    assert "Required when a third party operates the delegate" in description
    assert "Optional for a delegate that is a legal person acting for itself" in description
    assert "accepts by admitting this credential" in description
    assert "no one other than the principal or the delegate itself operates the delegate" in description
    assert "is named here as its own agent of record" not in description
    top = _gcd_schema()["description"]
    assert "@2fgsylgz" in top and "light path" in top and "heavy path" in top


def test_acceptance_capacity_describes_an_optional_self_naming() -> None:
    capacity = _arm(_acceptance_schema(), "a")["properties"]["capacity"]["description"]
    assert "chose to name itself" in capacity
    assert "accepts by admitting the GCD" in capacity


@pytest.mark.parametrize("key,value", [
    pytest.param("liableParty", AID, id="liable-party"),
    pytest.param("seat", "vendor", id="unknown-key"),
    pytest.param("principal", "not an aid", id="principal-malformed"),
    pytest.param("agentOfRecord", "_" * 44, id="agent-of-record-malformed"),
    pytest.param("durable", "true", id="durable-string"),
    pytest.param("grantText", {"digest": "EIehA1qcOpFPJrEqM6NYSAoUHt8kdjonoc7lTCPunC0V",
                               "canon": "cqt3.16"}, id="canon-not-cqt3.17"),
    pytest.param("grantText", {"digest": "E" + "A" * 42, "canon": "cqt3.17"}, id="digest-too-short"),
    pytest.param("grantText", {"digest": "B" + "A" * 43, "canon": "cqt3.17"}, id="digest-not-blake3"),
    pytest.param("grantText", {"digest": "EZ" + "A" * 42, "canon": "cqt3.17"}, id="digest-pad-bits"),
    pytest.param("grantText", {"canon": "cqt3.17"}, id="digest-missing"),
    pytest.param("grantText", {"digest": SAID}, id="canon-missing"),
    pytest.param("grantText", {"digest": SAID, "canon": "cqt3.17", "drafter": "lawyer"}, id="drafter-unknown"),
    pytest.param("grantText", {"digest": SAID, "canon": "cqt3.17", "text": "inline"}, id="grant-text-open"),
])
def test_a_bad_facet_is_refused_for_its_facet_only(key, value) -> None:
    """On the heavy example, so naming an agent of record never trips the disclosure-edge condition."""
    instance = _with(["a", "facet", key], value, _heavy())
    _refused(instance)
    assert _failing_sections(_gcd_schema(), instance) == {"a"}


@pytest.mark.parametrize("key,value", [
    pytest.param("principal", AID, id="principal"),
    pytest.param("agentOfRecord", AID, id="agent-of-record"),
    pytest.param("durable", True, id="durable"),
    pytest.param("durable", False, id="not-durable"),
    pytest.param("grantText", {"digest": SAID, "canon": "cqt3.17"}, id="grant-text-minimal"),
    *[pytest.param("grantText", {"digest": SAID, "canon": "cqt3.17", "drafter": d}, id=f"drafter-{d}")
      for d in ("principal", "agentOfRecord", "delegate", "other")],
])
def test_a_well_formed_facet_field_is_admitted(key, value) -> None:
    _accepted(_with(["a", "facet", key], value, _heavy()))


def test_the_cqt_vector_is_the_blake3_digest_of_its_canonical_text() -> None:
    vector = _load(VECTOR)
    assert vector["canon"] == "cqt3.17"
    assert Diger(ser=vector["canonical"].encode("utf-8"), code=MtrDex.Blake3_256).qb64 == vector["digest"]


# --- constraints: reserved powers and reviewers (@39eu7enh, @8u06glee) --------------------------

def test_reserved_powers_is_exactly_the_closed_vocabulary() -> None:
    field = _arm(_gcd_schema(), "a")["properties"]["constraints"]["properties"]["reservedPowers"]
    assert field["items"]["enum"] == RESERVED
    assert field["minItems"] == 1 and field["uniqueItems"] is True
    assert "absent" in field["description"].lower()


@pytest.mark.parametrize("code", RESERVED)
def test_each_reserved_power_is_admitted(code) -> None:
    _accepted(_with(["a", "constraints", "reservedPowers"], [code]))


@pytest.mark.parametrize("value", [
    pytest.param([], id="empty"),
    pytest.param(["substitute", "substitute"], id="duplicate"),
    pytest.param(["narrow"], id="unknown"),
    pytest.param(["revoke"], id="protective-act-is-not-a-reserved-power"),
    pytest.param("substitute", id="not-an-array"),
])
def test_a_bad_reserved_powers_value_is_refused(value) -> None:
    instance = _with(["a", "constraints", "reservedPowers"], value)
    _refused(instance)
    assert _failing_sections(_gcd_schema(), instance) == {"a"}


def test_human_review_requires_reviewers() -> None:
    instance = _with(["a", "constraints", "humanReview"], "A person approves each act.")
    _refused(instance)
    assert _failing_sections(_gcd_schema(), instance) == {"a"}
    instance["a"]["constraints"]["reviewers"] = [{"aids": [AID]}]
    _accepted(instance)


@pytest.mark.parametrize("reviewers", [
    pytest.param([{"aids": [AID]}], id="aids"),
    pytest.param([{"proof": SAID}], id="proof"),
    pytest.param([{"aids": [AID]}, {"proof": SAID}], id="or-set"),
])
def test_well_formed_reviewers_are_admitted(reviewers) -> None:
    instance = _with(["a", "constraints", "humanReview"], "A person approves each act.")
    _accepted(_with(["a", "constraints", "reviewers"], reviewers, instance))


@pytest.mark.parametrize("reviewers", [
    pytest.param([], id="empty"),
    pytest.param([{"aids": []}], id="empty-aids"),
    pytest.param([{"aids": ["not an aid"]}], id="aid-malformed"),
    pytest.param([{"proof": "D" + SAID[1:]}], id="proof-not-a-said"),
    pytest.param([{"aids": [AID], "proof": SAID}], id="two-forms"),
    pytest.param([{"roles": ["cfo"]}], id="unknown-form"),
    pytest.param(["any"], id="anyone-is-no-reviewer"),
])
def test_malformed_reviewers_are_refused(reviewers) -> None:
    instance = _with(["a", "constraints", "humanReview"], "A person approves each act.")
    instance = _with(["a", "constraints", "reviewers"], reviewers, instance)
    _refused(instance)
    assert _failing_sections(_gcd_schema(), instance) == {"a"}


def test_constraints_stay_open_to_custom_keys() -> None:
    """@vy7qoj: the verifier fails closed on an unknown key; the schema admits it."""
    constraints = _arm(_gcd_schema(), "a")["properties"]["constraints"]
    assert constraints["additionalProperties"] is True
    assert _gallery()["ai-deploy-agent"]["a"]["constraints"]["maxDeploysPerDay"] == 5


# --- edges (@8u06glee, @8tpzdyl5) --------------------------------------------------------------

def _edge(name: str, edge: dict, base: dict | None = None) -> dict:
    return _with(["e", name], edge, base)


@pytest.mark.parametrize("name,edge", [
    pytest.param("parent", {"n": SAID, "o": "I2I"}, id="parent"),
    pytest.param("parent", {"n": SAID, "s": PRIOR_SAID, "o": "I2I"}, id="parent-with-schema"),
    pytest.param("execution", {"n": SAID, "o": "NI2I"}, id="execution"),
    pytest.param("execution", {"n": SAID, "s": SAID, "o": "NI2I"}, id="execution-with-schema"),
])
def test_well_formed_optional_edges_are_admitted(name, edge) -> None:
    _accepted(_edge(name, edge))


def test_a_disclosure_edge_pins_the_disclosure_schema() -> None:
    disclosure = _load(DISCLOSURE / "gcd-disclosure.schema.json")["$id"]
    _accepted(_edge("disclosure", {"n": SAID, "s": disclosure, "o": "NI2I"}))
    for bad in ({"n": SAID, "s": SAID, "o": "NI2I"}, {"n": SAID, "s": disclosure, "o": "I2I"},
                {"n": SAID, "o": "NI2I"}):
        instance = _edge("disclosure", bad)
        _refused(instance)
        assert _failing_sections(_gcd_schema(), instance) == {"e"}


@pytest.mark.parametrize("name,edge", [
    pytest.param("parent", {"n": SAID, "o": "NI2I"}, id="parent-wrong-operator"),
    pytest.param("parent", {"o": "I2I"}, id="parent-missing-n"),
    pytest.param("parent", {"n": "not a said", "o": "I2I"}, id="parent-n-malformed"),
    pytest.param("parent", {"n": SAID, "o": "I2I", "w": 1}, id="parent-open"),
    pytest.param("execution", {"n": SAID, "o": "I2I"}, id="execution-wrong-operator"),
    pytest.param("execution", {"n": SAID}, id="execution-missing-operator"),
    pytest.param("sibling", {"n": SAID, "o": "I2I"}, id="unknown-edge"),
])
def test_a_bad_edge_is_refused_for_its_edges_only(name, edge) -> None:
    instance = _edge(name, edge)
    _refused(instance)
    assert _failing_sections(_gcd_schema(), instance) == {"e"}


def _heavy() -> dict:
    return _gallery()["ai-purchasing-agent"]


def test_an_agent_of_record_requires_a_disclosure_edge() -> None:
    """Rules revision 3: the disclosure rule makes the edge mandatory wherever agentOfRecord is named."""
    _accepted(_heavy())
    for instance in (_without(["e", "disclosure"], _heavy()), _without(["e"], _heavy()),
                     _with(["a", "facet", "agentOfRecord"], AID)):
        _refused(instance)
        assert _failing_sections(_gcd_schema(), instance) == {"envelope"}


def test_a_light_path_gcd_validates_without_agent_of_record_or_disclosure() -> None:
    """@2fgsylgz: omitting agentOfRecord needs no disclosure edge, and no edges block at all."""
    light = _example()
    assert "agentOfRecord" not in light["a"]["facet"]
    assert "disclosure" not in light["e"]
    _accepted(light)
    _accepted(_without(["e"], light))


def test_the_disclosure_condition_ignores_compact_sections() -> None:
    """A compacted a or e block cannot be inspected, so the condition neither fires nor fails on it."""
    _accepted(_with(["a"], _heavy()["a"]["d"], _without(["e", "disclosure"], _heavy())))
    _accepted(_with(["e"], _heavy()["e"]["d"], _heavy()))


def test_the_parent_edge_says_its_schema_must_be_a_gcd() -> None:
    parent = _arm(_gcd_schema(), "e")["properties"]["parent"]
    assert "const" not in parent["properties"].get("s", {})
    assert "GCD" in parent["description"]


# --- rules (@8u06glee) ---------------------------------------------------------------------------

def test_rules_json_carries_exactly_the_5_0_0_clauses_in_order() -> None:
    rules = _rules()
    assert saidify_sad(rules) == rules
    assert list(rules) == ["d", *RULE_KEYS, "duties"]
    assert [duty["rule"] for duty in rules["duties"]] == BASELINE_DUTIES
    assert not set(OLD_RULE_KEYS) & set(rules)


def test_the_rules_are_revision_5_with_the_light_path() -> None:
    """@2fgsylgz: a legal-person delegate binds itself by admitting; omitting agentOfRecord is no longer
    a representation that the principal operates the delegate."""
    rules = _rules()
    assert "A delegate that is a legal person is bound by admitting it." in rules["bindingParties"]
    assert "or, where none is named, by a delegate that is a legal person" in rules["bindingParties"]
    assert "accepts by admitting this credential" in rules["acceptance"]
    assert "is named as its own agent of record" not in rules["acceptance"]
    assert "the principal itself operates the delegate" not in rules["acceptance"]
    prose = _arm(_gcd_schema(), "r")["properties"]["duties"]["items"]["oneOf"][1]["description"]
    assert "where none is named, by a delegate that is a legal person" in prose


def test_the_schema_requires_every_clause_verbatim_in_either_form() -> None:
    arm = _arm(_gcd_schema(), "r")
    assert list(arm["properties"]) == ["d", *RULE_KEYS, "duties"]
    assert arm["required"] == ["d", *RULE_KEYS, "duties"]
    assert arm["additionalProperties"] is False
    rules = _rules()
    for key in RULE_KEYS:
        compact, detail = arm["properties"][key]["oneOf"][:2]
        assert compact["const"] == rules[key], key
        assert detail["properties"]["l"]["const"] == rules[key], key


@pytest.mark.parametrize("key", RULE_KEYS)
def test_each_clause_is_admitted_in_its_detail_form_and_refused_altered_or_absent(key) -> None:
    text = _rules()[key]
    _accepted(_with(["r", key], {"l": text}))
    for instance in (_with(["r", key], text + " "), _with(["r", key], {"l": text[:-1]}), _without(["r", key])):
        _refused(instance)
        assert _failing_sections(_gcd_schema(), instance) == {"r"}


@pytest.mark.parametrize("key", OLD_RULE_KEYS)
def test_a_4_0_0_rule_key_is_refused(key) -> None:
    instance = _with(["r", key], "anything")
    _refused(instance)
    assert _failing_sections(_gcd_schema(), instance) == {"r"}


@pytest.mark.parametrize("law", [["US-CA"], ["DE"], ["GB", "IN-TN"]])
def test_governing_law_is_admitted_in_the_clause_detail_form(law) -> None:
    _accepted(_with(["r", "governingLaw"], {"l": _rules()["governingLaw"], "law": law}))


@pytest.mark.parametrize("entry", [
    pytest.param({"law": ["us-ca"]}, id="lowercase-code"),
    pytest.param({"law": ["California"]}, id="not-a-code"),
    pytest.param({"law": []}, id="empty"),
    pytest.param({"law": ["US-CA"], "forum": "San Francisco"}, id="forum-not-admitted"),
])
def test_a_bad_governing_law_is_refused(entry) -> None:
    instance = _with(["r", "governingLaw"], {"l": _rules()["governingLaw"], **entry})
    _refused(instance)
    assert _failing_sections(_gcd_schema(), instance) == {"r"}


def _duties(*extra: dict) -> list[dict]:
    return [*_rules()["duties"], *extra]


@pytest.mark.parametrize("rule", BASELINE_DUTIES)
def test_each_baseline_duty_is_required_exactly(rule) -> None:
    baseline = [duty for duty in _rules()["duties"] if duty["rule"] != rule]
    missing = _with(["r", "duties"], baseline)
    _refused(missing)
    assert _failing_sections(_gcd_schema(), missing) == {"r"}
    original = next(duty for duty in _rules()["duties"] if duty["rule"] == rule)
    for altered in ({**original, "l": original["l"] + " "}, {**original, "priority": original["priority"] + 1}):
        instance = _with(["r", "duties"], [*baseline, altered])
        _refused(instance)
        assert _failing_sections(_gcd_schema(), instance) == {"r"}


@pytest.mark.parametrize("duty", [
    pytest.param({"bearer": "delegate", "effect": "create", "goal": "pay.invoice", "priority": 2,
                  "cadence": "daily"}, id="structured"),
    pytest.param({"bearer": "delegate", "effect": "create", "goal": "pay.invoice", "priority": 2,
                  "acme.channel": "pager"}, id="structured-custom-key"),
    pytest.param({"bearer": "delegate", "rule": "reportWeekly", "l": "Report weekly to the principal.",
                  "priority": 2}, id="prose"),
    pytest.param({"bearer": "delegate", "rule": "reportWeekly", "l": "Report weekly.", "priority": 2,
                  "acme.channel": "email"}, id="prose-custom-key"),
    pytest.param({"bearer": "issuer", "rule": "annualAudit", "priority": 1}, id="issuer"),
])
def test_each_duty_shape_is_admitted(duty) -> None:
    _accepted(_with(["r", "duties"], _duties(duty)))


@pytest.mark.parametrize("duty", [
    pytest.param({"bearer": "delegate", "rule": "reportWeekly", "priority": 2}, id="prose-missing-l"),
    pytest.param({"bearer": "delegate", "l": "Report weekly.", "priority": 2}, id="prose-missing-rule"),
    pytest.param({"bearer": "delegate", "effect": "create", "goal": "pay.invoice", "rule": "x",
                  "priority": 2}, id="effect-and-rule"),
    pytest.param({"bearer": "delegate", "effect": "create", "goal": "pay.invoice", "l": "x",
                  "priority": 2}, id="effect-and-l"),
    pytest.param({"bearer": "delegate", "rule": "x", "l": "y", "goal": "pay.invoice", "priority": 2},
                 id="prose-with-goal"),
    pytest.param({"bearer": "delegate", "effect": "create", "priority": 2}, id="structured-missing-goal"),
    pytest.param({"bearer": "delegate", "rule": "x", "l": "y"}, id="prose-missing-priority"),
    pytest.param({"bearer": "delegate", "rule": "x", "l": "y", "priority": "high"}, id="priority-not-integer"),
    pytest.param({"bearer": "notary", "rule": "x", "l": "y", "priority": 1}, id="unknown-bearer"),
])
def test_a_malformed_duty_is_refused(duty) -> None:
    instance = _with(["r", "duties"], _duties(duty))
    _refused(instance)
    assert _failing_sections(_gcd_schema(), instance) == {"r"}


def test_duty_priority_never_resolves_a_protective_conflict() -> None:
    items = _arm(_gcd_schema(), "r")["properties"]["duties"]["items"]["oneOf"]
    for shape in items:
        description = shape["properties"]["priority"]["description"]
        assert "loyalty, confidentiality or escalate is never resolved by priority" in description


# --- the examples -------------------------------------------------------------------------------

@pytest.mark.parametrize("name", list(_all_gcd_examples()))
def test_every_gcd_example_is_valid_saidified_and_carries_the_full_rules(name) -> None:
    instance = _all_gcd_examples()[name]
    _accepted(instance)
    assert instance["s"] == _gcd_schema()["$id"]
    assert saidify_sad(instance) == instance
    rules = _rules()
    for key in RULE_KEYS:
        clause = instance["r"][key]
        assert (clause if isinstance(clause, str) else clause["l"]) == rules[key], key
    for duty in rules["duties"]:
        assert duty in instance["r"]["duties"], duty["rule"]
    facet = instance["a"].get("facet", {})
    assert "liableParty" not in facet
    assert facet.get("principal") != instance["i"], "principal is set only where it differs"
    assert "escalateTo" not in json.dumps(instance)


def test_the_gallery_has_the_5_0_0_examples() -> None:
    assert set(_gallery()) == {
        "ai-deploy-agent", "guardian-of-minor", "iot-fleet-controller", "payments-steward",
        "platform-manager", "real-estate-agent", "ai-purchasing-agent", "durable-financial-poa",
        "sub-delegated-assistant", "tax-information-reader", "exec-assistant-ai"}


LIGHT = {"example", "platform-manager", "guardian-of-minor", "tax-information-reader", "ai-deploy-agent",
         "payments-steward", "sub-delegated-assistant", "exec-assistant-ai"}
SELF_NAMED = {"real-estate-agent", "iot-fleet-controller", "durable-financial-poa"}
THIRD_PARTY = {"ai-purchasing-agent"}


def test_who_is_named_agent_of_record() -> None:
    """@2fgsylgz: light examples name no agent of record; heavy ones name a third party or themselves."""
    examples = _all_gcd_examples()
    assert LIGHT | SELF_NAMED | THIRD_PARTY == set(examples)
    for name in LIGHT:
        assert "agentOfRecord" not in examples[name]["a"]["facet"], name
        assert "disclosure" not in examples[name].get("e", {}), name
    for name in SELF_NAMED:
        assert examples[name]["a"]["facet"]["agentOfRecord"] == examples[name]["a"]["i"], name
    for name in THIRD_PARTY:
        gcd = examples[name]
        assert gcd["a"]["facet"]["agentOfRecord"] not in (gcd["i"], gcd["a"]["i"]), name


def test_every_heavy_gcd_example_has_an_acceptance() -> None:
    accepted = {acceptance["e"]["gcd"]["n"] for acceptance in
                [_load(ACCEPTANCE / "example.json"), *map(_load, sorted((ACCEPTANCE / "examples").glob("*.json")))]}
    for name, instance in _all_gcd_examples().items():
        assert (instance["d"] in accepted) == ("agentOfRecord" in instance["a"]["facet"]), name


def test_every_agent_of_record_disclosed_to_the_principal_before_the_grant() -> None:
    disclosures = {d["d"]: d for d in [_load(DISCLOSURE / "example.json"),
                                       *map(_load, sorted((DISCLOSURE / "examples").glob("*.json")))]}
    used = set()
    for name, instance in _all_gcd_examples().items():
        facet = instance["a"]["facet"]
        if "agentOfRecord" not in facet:
            continue
        disclosure = disclosures[instance["e"]["disclosure"]["n"]]
        used.add(disclosure["d"])
        assert disclosure["i"] == facet["agentOfRecord"], name
        assert disclosure["a"]["i"] == facet.get("principal", instance["i"]), name
        assert disclosure["a"]["dt"] < instance["a"]["dt"], name
        _accepted(disclosure, _disclosure_schema())
        assert saidify_sad(disclosure) == disclosure
    assert used == set(disclosures), "every disclosure example backs some GCD example"


def test_every_acceptance_example_accepts_a_gallery_gcd_after_it() -> None:
    by_said = {instance["d"]: instance for instance in _all_gcd_examples().values()}
    acceptances = [_load(ACCEPTANCE / "example.json"), *map(_load, sorted((ACCEPTANCE / "examples").glob("*.json")))]
    assert len(acceptances) >= 2
    for acceptance in acceptances:
        _accepted(acceptance, _acceptance_schema())
        assert saidify_sad(acceptance) == acceptance
        gcd = by_said[acceptance["e"]["gcd"]["n"]]
        assert acceptance["i"] == gcd["a"]["facet"]["agentOfRecord"]
        assert acceptance["a"]["i"] == gcd["i"] and acceptance["a"]["dt"] > gcd["a"]["dt"]
        expected = "delegate" if gcd["a"]["facet"]["agentOfRecord"] == gcd["a"]["i"] else "agentOfRecord"
        assert acceptance["a"]["capacity"] == expected


def test_humans_review_only_where_reviewers_are_named() -> None:
    reviewed = [name for name, instance in _all_gcd_examples().items()
                if "humanReview" in instance["a"].get("constraints", {})]
    assert {"ai-deploy-agent", "guardian-of-minor"} <= set(reviewed)
    for name in reviewed:
        assert _all_gcd_examples()[name]["a"]["constraints"]["reviewers"], name


def test_the_guardian_example_names_the_individual_as_principal() -> None:
    guardian = _gallery()["guardian-of-minor"]
    facet = guardian["a"]["facet"]
    assert facet["principal"] not in (guardian["i"], guardian["a"]["i"])
    assert "agentOfRecord" not in facet, "the court-appointed guardian accepts by admitting the credential"
    assert "disclosure" not in guardian["e"]
    assert guardian["e"]["execution"]["o"] == "NI2I"


def test_the_exec_assistant_is_an_in_house_instrument_colleagues_honor() -> None:
    """@2fgsylgz: X delegates scheduling to X's own AI assistant Y, with no agent of record."""
    gcd = _gallery()["exec-assistant-ai"]
    facet, constraints = gcd["a"]["facet"], gcd["a"]["constraints"]
    assert gcd["e"]["issuer"]["o"] == "I2I" and set(gcd["e"]) == {"d", "issuer"}
    assert gcd["a"]["i"] != gcd["i"]
    assert "agentOfRecord" not in facet and "principal" not in facet
    assert facet["relationType"] == "delegation" and facet["exerciseMode"] == "act"
    assert facet["presentsAs"] not in (gcd["i"], gcd["a"]["i"])
    assert constraints["acts"] == ["observe {info, commitment}", "create commitment"]
    assert len(constraints["targets"]) == 1
    target = constraints["targets"][0]
    assert set(target["designatedBy"]) == {"proof"}
    assert target["acts"] == ["observe commitment", "create commitment"]
    assert constraints["domains"] and "reservedPowers" not in constraints
    assert constraints["monetaryLimit"].split()[1] and float(constraints["monetaryLimit"].split()[0]) <= 100
    start, end = constraints["validFrom"], constraints["validUntil"]
    assert start < end and int(end[:4]) * 12 + int(end[5:7]) - int(start[:4]) * 12 - int(start[5:7]) <= 12


def test_the_purchasing_agent_is_greenwoods_sentence_made_concrete() -> None:
    gcd = _gallery()["ai-purchasing-agent"]
    facet, constraints = gcd["a"]["facet"], gcd["a"]["constraints"]
    vector = _load(VECTOR)
    assert facet["agentOfRecord"] not in (gcd["i"], gcd["a"]["i"])
    assert facet["grantText"] == {"digest": vector["digest"], "canon": "cqt3.17", "drafter": "agentOfRecord"}
    assert constraints["acts"] == ["create commitment"]
    assert len(constraints["targets"]) == 1 and "id" in constraints["targets"][0]
    assert constraints["monetaryLimit"] == "400 USD"
    assert constraints["validUntil"] and gcd["a"]["terminatingEvents"]

    disclosure = _load(DISCLOSURE / "example.json")
    assert gcd["e"]["disclosure"]["n"] == disclosure["d"]
    assert disclosure["i"] == facet["agentOfRecord"] and disclosure["a"]["i"] == gcd["i"]
    assert disclosure["a"]["dt"] < gcd["a"]["dt"]

    acceptance = _load(ACCEPTANCE / "example.json")
    assert acceptance["e"]["gcd"]["n"] == gcd["d"]
    assert acceptance["i"] == facet["agentOfRecord"] and acceptance["a"]["i"] == gcd["i"]
    assert acceptance["a"]["capacity"] == "agentOfRecord"
    assert acceptance["a"]["dt"] > gcd["a"]["dt"]


def test_the_durable_poa_survives_incapacity_under_named_law() -> None:
    poa = _gallery()["durable-financial-poa"]
    assert poa["a"]["facet"]["durable"] is True
    assert poa["e"]["execution"]["o"] == "NI2I"
    assert poa["a"]["terminatingEvents"]
    assert poa["r"]["governingLaw"]["law"] == ["US-CA"]
    assert poa["a"]["constraints"]["reservedPowers"] == ["substitute"]


def test_the_sub_delegated_assistant_sits_strictly_inside_its_parent() -> None:
    parent, child = _gallery()["platform-manager"], _gallery()["sub-delegated-assistant"]
    assert child["e"]["parent"] == {"n": parent["d"], "s": parent["s"], "o": "I2I"}
    assert child["i"] == parent["a"]["i"], "I2I: the child's issuer is the parent's issuee"
    assert "substitute" in parent["a"]["constraints"]["reservedPowers"]
    assert "reservedPowers" not in child["a"]["constraints"]
    pc, cc = parent["a"]["constraints"], child["a"]["constraints"]
    assert set(cc["domains"]) < set(pc["domains"])
    assert pc["validFrom"] <= cc["validFrom"] and cc["validUntil"] <= pc["validUntil"]


def test_the_tax_information_reader_only_observes() -> None:
    constraints = _gallery()["tax-information-reader"]["a"]["constraints"]
    points = constraints["acts"] + [act for entry in constraints["targets"] for act in entry.get("acts", [])]
    assert points and all(point.startswith("observe ") for point in points)


# --- the 5.0.0 negative corpus --------------------------------------------------------------------

GCD_FIXTURES = {
    "facet-liable-party": "a",
    "grant-text-bad-canon": "a",
    "grant-text-digest-malformed": "a",
    "durable-not-boolean": "a",
    "reserved-powers-unknown-code": "a",
    "human-review-without-reviewers": "a",
    "parent-edge-wrong-operator": "e",
    "governing-law-bad-code": "r",
    "duty-prose-missing-l": "r",
    "duty-effect-and-rule": "r",
    "baseline-duty-missing": "r",
    "old-rule-key": "r",
    "agent-of-record-without-disclosure": "envelope",
}


@pytest.mark.parametrize("name,section", GCD_FIXTURES.items())
def test_each_new_fixture_fails_for_its_own_defect_only(name, section) -> None:
    fixture = _load(GCD / "invalid" / f"{name}.json")
    assert fixture["s"] == _gcd_schema()["$id"]
    _refused(fixture)
    assert _failing_sections(_gcd_schema(), fixture) == {section}


def test_every_gcd_fixture_points_at_5_0_0() -> None:
    for path in sorted((GCD / "invalid").glob("*.json")):
        fixture = _load(path)
        if "s" in fixture:
            assert fixture["s"] == _gcd_schema()["$id"], path.name


# --- gcd-disclosure (@8tpzdyl5) -----------------------------------------------------------------

def _disclosure_schema() -> dict:
    return _load(DISCLOSURE / "gcd-disclosure.schema.json")


def _disclosure() -> dict:
    return _load(DISCLOSURE / "example.json")


def test_the_disclosure_example_validates_and_is_saidified() -> None:
    example = _disclosure()
    _accepted(example, _disclosure_schema())
    assert example["s"] == _disclosure_schema()["$id"]
    assert saidify_sad(example) == example
    assert example["a"]["compensation"] and example["a"]["conflicts"]


def test_the_disclosure_records_its_selective_disclosure_choice() -> None:
    schema = _disclosure_schema()
    assert "selective disclosure" in schema["description"]
    assert "constraint credential" in schema["description"]
    assert {"d", "u"} <= set(_arm(schema, "a")["required"])


def test_the_disclosure_rule_is_verbatim() -> None:
    clause = ("The issuer states in this disclosure all compensation it expects from any party, and every "
              "material conflict of interest it has, in connection with acting for the issuee under any "
              "credential that references this disclosure, and it will disclose any change before acting on it.")
    rules = _load(DISCLOSURE / "rules.json")
    assert saidify_sad(rules) == rules
    assert list(rules.values())[1:] == [clause]
    assert _disclosure()["r"]["completeDisclosure"] == clause


@pytest.mark.parametrize("mutate", [
    pytest.param(lambda a: a.pop("compensation") and a.pop("conflicts"), id="neither-content"),
    pytest.param(lambda a: a.update(compensation=[]), id="compensation-empty"),
    pytest.param(lambda a: a["compensation"][0].pop("basis"), id="compensation-missing-basis"),
    pytest.param(lambda a: a["compensation"][0].update(amount="4 USD"), id="compensation-open"),
    pytest.param(lambda a: a.update(conflicts=[""]), id="conflict-empty-string"),
    pytest.param(lambda a: a.update(fees="none"), id="extra-attribute"),
    pytest.param(lambda a: a.pop("u"), id="missing-nonce"),
    pytest.param(lambda a: a.update(u="short"), id="short-nonce"),
    pytest.param(lambda a: a.pop("dt"), id="missing-dt"),
])
def test_a_bad_disclosure_is_refused_for_its_attributes_only(mutate) -> None:
    instance = _disclosure()
    mutate(instance["a"])
    _refused(instance, _disclosure_schema())
    assert _failing_sections(_disclosure_schema(), instance) == {"a"}


@pytest.mark.parametrize("keep", ["compensation", "conflicts"])
def test_either_kind_of_disclosure_alone_is_admitted(keep) -> None:
    instance = _disclosure()
    instance["a"].pop("conflicts" if keep == "compensation" else "compensation")
    _accepted(instance, _disclosure_schema())


# --- gcd-acceptance (@8tpzdyl5) -----------------------------------------------------------------

def _acceptance_schema() -> dict:
    return _load(ACCEPTANCE / "gcd-acceptance.schema.json")


def _acceptance() -> dict:
    return _load(ACCEPTANCE / "example.json")


def test_the_acceptance_example_validates_and_is_saidified() -> None:
    example = _acceptance()
    _accepted(example, _acceptance_schema())
    assert example["s"] == _acceptance_schema()["$id"]
    assert saidify_sad(example) == example


def test_the_acceptance_rule_is_verbatim() -> None:
    clause = ("The issuer of this acceptance accepts, without qualification, appointment under the referenced "
              "credential and the rules that credential carries, which were available to it in full before it "
              "issued this acceptance, and undertakes as its own the duties whose bearer is the delegate.")
    rules = _load(ACCEPTANCE / "rules.json")
    assert saidify_sad(rules) == rules
    assert list(rules.values())[1:] == [clause]
    assert _acceptance()["r"]["unqualifiedAcceptance"] == clause


@pytest.mark.parametrize("path,value,section", [
    pytest.param(["a", "capacity"], "vendor", "a", id="capacity-unknown"),
    pytest.param(["a", "conditions"], "only on weekdays", "a", id="qualified-acceptance"),
    pytest.param(["e", "gcd", "s"], PRIOR_SAID, "e", id="gcd-edge-pins-4.0.0"),
    pytest.param(["e", "gcd", "o"], "I2I", "e", id="gcd-edge-wrong-operator"),
    pytest.param(["e", "gcd", "n"], "not a said", "e", id="gcd-edge-n-malformed"),
    pytest.param(["r", "unqualifiedAcceptance"], "I accept, subject to conditions.", "r", id="rule-altered"),
])
def test_a_bad_acceptance_is_refused_where_it_is_bad(path, value, section) -> None:
    instance = _with(path, value, _acceptance())
    _refused(instance, _acceptance_schema())
    assert _failing_sections(_acceptance_schema(), instance) == {section}


def test_an_acceptance_must_carry_its_edge() -> None:
    _refused(_without(["e"], _acceptance()), _acceptance_schema())
    _refused(_without(["e", "gcd"], _acceptance()), _acceptance_schema())


@pytest.mark.parametrize("folder", ["gcd-disclosure", "gcd-acceptance"])
def test_each_companion_ships_fixtures_that_its_schema_refuses(folder) -> None:
    schema = _load(ROOT / folder / f"{folder}.schema.json")
    fixtures = sorted((ROOT / folder / "invalid").glob("*.json"))
    assert len(fixtures) >= 3
    for path in fixtures:
        assert _errors(schema, _load(path)), path.name
