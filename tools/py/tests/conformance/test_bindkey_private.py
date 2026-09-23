"""bindkey-private: a holder's P-256 key for derivation, private by design (`this.i` @kakslwv3)."""

import copy
import json
from pathlib import Path

import jsonschema
import pytest

from schematools.said import compute_schema_said, saidify_sad

ROOT = Path(__file__).resolve().parents[4]
FOLDER = ROOT / "bindkey-private"
P256_CESR = "1AAJAuBSkn5k-UPN2j0AlGEKubynLlishzclvlZw0cSWPdrS"
ED25519_CESR = "DA7Fm_kxxP4ZXb7iuVQoJJdTZkcn0vafa8KdcMjpS0Wy"


def _schema() -> dict:
    return json.loads((FOLDER / "bindkey-private.schema.json").read_text())


def _example() -> dict:
    return json.loads((FOLDER / "example.json").read_text())


def _validate(instance: dict) -> None:
    jsonschema.Draft202012Validator(_schema()).validate(instance)


def _refused(instance: dict) -> None:
    with pytest.raises(jsonschema.ValidationError):
        _validate(instance)


def test_the_schema_names_itself_and_is_registered() -> None:
    schema = _schema()
    assert compute_schema_said(schema) == schema["$id"]
    registry = json.loads((ROOT / "registry.json").read_text())
    assert registry[schema["$id"]] == "bindkey-private/bindkey-private.schema.json"
    assert schema["version"] == "1.0.0"


def test_the_example_is_self_issued_nonced_and_saidified() -> None:
    example = _example()
    _validate(example)
    assert example["i"] == example["a"]["i"], "issuer and issuee are the holder AID"
    assert example["u"] and example["a"]["u"], "nonces in both slots"
    assert example["s"] == _schema()["$id"]
    assert saidify_sad(example) == example


def test_the_jwk_example_carries_only_a_public_p256_key() -> None:
    key = _example()["a"]["pubkey"]
    assert _example()["a"]["keyFormat"] == "jwk"
    assert (key["kty"], key["crv"]) == ("EC", "P-256") and "d" not in key


def test_a_cesr_p256_key_is_accepted() -> None:
    for code in ("1AAJ", "1AAI"):
        instance = _example()
        instance["a"]["keyFormat"] = "cesr"
        instance["a"]["pubkey"] = code + P256_CESR[4:]
        _validate(instance)


@pytest.mark.parametrize("mutate", [
    lambda a: a["pubkey"].update(crv="P-384"),
    lambda a: a["pubkey"].update(kty="OKP"),
    lambda a: a["pubkey"].update(d="c2VjcmV0c2VjcmV0c2VjcmV0c2VjcmV0c2VjcmV0c2U"),
    lambda a: a["pubkey"].pop("y"),
    lambda a: a.update(keyFormat="cesr"),
    lambda a: a.update(keyFormat="cesr", pubkey=ED25519_CESR),
    lambda a: a.update(keyFormat="jwk", pubkey=P256_CESR),
    lambda a: a.update(keyFormat="pem"),
    lambda a: a.update(purpose="ssh"),
    lambda a: a.pop("validUntil"),
    lambda a: a.pop("dt"),
    lambda a: a.pop("i"),
    lambda a: a.pop("u"),
    lambda a: a.update(extra=True),
], ids=["p384", "okp", "private-member", "no-y", "cesr-with-jwk-object", "ed25519-cesr",
        "jwk-with-cesr-string", "pem", "wrong-purpose", "no-validuntil", "no-dt", "no-issuee",
        "no-block-nonce", "extra-attribute"])
def test_anything_but_a_public_p256_holder_binding_is_refused(mutate) -> None:
    instance = copy.deepcopy(_example())
    mutate(instance["a"])
    _refused(instance)


@pytest.mark.parametrize("field", ["rd", "u", "r", "a"])
def test_top_level_required(field: str) -> None:
    instance = _example()
    del instance[field]
    _refused(instance)


@pytest.mark.parametrize("section", ["a", "r"])
def test_compact_sections_validate(section: str) -> None:
    instance = _example()
    instance[section] = instance[section]["d"]
    _validate(instance)


def test_rules_are_the_published_rules_document() -> None:
    rules = json.loads((FOLDER / "rules.json").read_text())
    assert saidify_sad(rules) == rules
    assert _example()["r"] == rules
    assert {"privateToTheReissuer", "bindsForDerivationOnly", "keyNotAssertedSound",
            "bindingEndsOnHorizonOrRevocation"} <= set(rules)


def test_every_negative_fixture_is_refused_and_pins_this_schema() -> None:
    fixtures = sorted((FOLDER / "invalid").glob("*.json"))
    assert len(fixtures) >= 8
    for path in fixtures:
        instance = json.loads(path.read_text())
        assert instance["s"] == _schema()["$id"], path.name
        _refused(instance)
