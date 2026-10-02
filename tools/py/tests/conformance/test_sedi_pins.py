"""Pinned SEDI schema vectors: Sam Smith's current schemas and every revision they displaced.

The current IAR, Core, Residence and Age are Sam Smith's at keripy 9a8b7aa7 (`this.i` @3x2jtfxc).
The byte hashes also catch edits to formatting or key order that a schema SAID, which is computed
over canonical JSON, cannot detect.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

import pytest

from schematools.said import compute_schema_said

ROOT = Path(__file__).resolve().parents[4]
SAM_CURRENT = "https://github.com/WebOfTrust/keripy/blob/9a8b7aa7/tests/sedi/test_sedi.py"
SAM_ORIGINAL = "https://github.com/WebOfTrust/keripy/blob/ec307cd74/tests/sedi/test_sedi.py"

# Sam's IarSchemaSaid, CoreSchemaSaid, ResidenceSchemaSaid and AgeSchemaSaid at 9a8b7aa7.
SAM_CURRENT_PINS = {
    "sedi-iar": (
        "EFAB6k77bXHs6bg9PORW7UYF79GD_OuEcEjmBpwhcfRN",
        "4ffecad00c3b4db27b67a18bc621dc19c2a6821c9a58189a06cc468561073b2a",
    ),
    "sedi-core": (
        "EAyyREL1r5OL8Z9HGl47df26rn_JRLsC7PVDBH5RtwLs",
        "70784bbf5d317760e0d488733c28b19d5281cd4e3dcdd946b778fb6582c4b934",
    ),
    "sedi-residence": (
        "EH7ayivQLHwfBKwFhg7mcpOzHEWcvvJ24EO0OyzvPVKQ",
        "e115d4fc8f00cf54d07429f5286574388c5003177c23c0a5376706d00dd90708",
    ),
    "sedi-age": (
        "EH-ZOEzzWm5hw351zL3IBJiEMDnJiKrv17lQp2JFj8Sb",
        "9e8bf1e3f675ff671ce1b01a942f87d8c1daf7e235397f3db75dbdaba1992f20",
    ),
}

# Sam's schemas at ec307cd74, the Summit's previous pin.
SAM_ORIGINAL_PINS = {
    "sedi-iar-pre-sam-repin-0.1.0": (
        "EHp3Ik9q-6-sT0IFaLRJDEjd-j3zMRdy1aN6O6awCsZd",
        "1ad44ebf935f69d2a0dfad37ba0fa4f8f563fec6d357ef8ac67e570d4c002afc",
    ),
    "sedi-core-0.1.0": (
        "ED7zRxzpuvv89c6jDwgyBNOoW06Ut0wm_8jJQRqKYv_5",
        "543ffc58f48bf6d04dc3f49f9967ae36e586c863798bd67eefe2ff3485ef3a4e",
    ),
    "sedi-residence-0.1.0": (
        "EEgFNN1XH90koG5J5pbXKlRNU6TnibizaTQmJcRfEcop",
        "a9c23887bcd8d436a70367ccd1f683cb78305bb281d047bfad19e0f7bb6d4227",
    ),
}

# Published Bakobo revisions displaced by the re-pin, kept byte for byte.
DISPLACED = {
    "sedi-core-0.2.0": (
        "ELNhZbCUiafPrMFnL2vRGEjylRu8zug-3M-goUft8bfh",
        "fecf18fcffc622820783e5cc8cc66653a61bf1ea6797a0d6ef5b46965b092cb9",
    ),
    "sedi-residence-0.2.0": (
        "EDg5tBqnVFoGILBgIknKs-0CHv3au4GczuPgjf4jx1X2",
        "2bfe9f3ab0836714554f90bc971cb2723306453ad0f953825dc22459ffa9797d",
    ),
    "sedi-age-3.0.0": (
        "EOZgLvehWuTl_lOJjEX7sEqsif1jrk9f_H10_p85r65H",
        "7fd2fde375155015d98937b89e1ebadc734b9c93075fe1e3c861df5f39c547f3",
    ),
    "sedi-present-county-pre-sam-repin-2.0.0": (
        "EOkso5ZxAnIOO4j8D8zsfxx2ECn0MB0Ml8A0sZx-6qT0",
        "e003416f2456502bbfd1b7fe9fd45dfdc3d68a07de1dba1f95217f539a8ef2ea",
    ),
    "sedi-present-age-portrait-pre-sam-repin-4.0.0": (
        "EHcc2Ow86VVg37zhILHFz942GEYfQ8PGTwKb2h4KdJFU",
        "b5566a70f707316dbac2be6aa626e84889f022ea6eaaae7362fb1595e31ce284",
    ),
    "sedi-guardian-pre-sam-repin-3.0.0": (
        "EMQmtKXdW2bAgtzn9sUJ8VcWwasXvkL5JneYwU83m6Eh",
        "acc7931b601f1cda130a7527d9367b45c1295da7ae68195f5d2b7b16cbacba63",
    ),
    "sedi-ward-core-pre-sam-repin-1.0.0": (
        "EHM6a9atXNYYta67ZKp8VknJ0KiQ8m5BU6RkMWoK5_1Y",
        "65f38245e2b4fbcca128ac141e6f35a73d3b612466deed81a4a994346cb2a5d3",
    ),
    "sedi-ward-authz-pre-sam-repin-1.0.0": (
        "EPtKrKbreCiM9b0pY5aKk3d8qfRwCq7x7wVc2A70jKVF",
        "ac0eba4c16f63421552f8a83785910f78494b21d17a0e8809c18d8aa6559621b",
    ),
}


def _check(name: str, expected_said: str, expected_sha256: str, source: str) -> None:
    relative = f"{name}/{name}.schema.json"
    raw = (ROOT / relative).read_bytes()
    schema = json.loads(raw)
    registry = json.loads((ROOT / "registry.json").read_text())
    assert schema["$id"] == expected_said, source
    assert compute_schema_said(schema) == expected_said, source
    assert hashlib.sha256(raw).hexdigest() == expected_sha256, source
    assert registry[expected_said] == relative


@pytest.mark.parametrize("name", SAM_CURRENT_PINS)
def test_sam_current_schema_pin(name: str) -> None:
    _check(name, *SAM_CURRENT_PINS[name], SAM_CURRENT)


@pytest.mark.parametrize("name", SAM_ORIGINAL_PINS)
def test_sam_original_schema_pin(name: str) -> None:
    _check(name, *SAM_ORIGINAL_PINS[name], SAM_ORIGINAL)


@pytest.mark.parametrize("name", DISPLACED)
def test_displaced_revision_stays_resolvable_byte_for_byte(name: str) -> None:
    _check(name, *DISPLACED[name], "published revision displaced by @3x2jtfxc")


@pytest.mark.parametrize("path,said,digest", [
    ("sedi-iar/example.json", "EOci_-BIIESmZ_TbIkc4UZO2ic0e-_RqGzVxAMYNvnO_",
     "e49f57deed688664e054ea17c2b16ad3b713810a0750c665ab8c7a472cf057d2"),
    ("sedi-core/example.json", "ENOVdsuMryEUCyZ1qQ26VSqtIMEzgOdyqZ2WCx2S11Nf",
     "bda729b474bf5cf829b854aca700f241d6569beb0b677ad9e754c8b1ed849b87"),
    ("sedi-core/examples/gal.json", "EA4iEqsUF-Fu6aT1DgBkqPWeT3Rw0W367veAkYSCkRMV",
     "d7d361e78218b641e639b68067df0e164310218671e877ab16a6c857d4c80bca"),
    ("sedi-residence/example.json", "EPb1xxIaIvPTckSE80yTOsKwECWvTYW_stqpzWvpI2PH",
     "42015f6b68bb043e6bcbd0ebe631ee76a4b34695e6543a7fd8d639e295d0001c"),
    ("sedi-age/example.json", "EL_TknAe1H0HFAO3GiFL3OFLDVCyIbo5e9C978_sKPwI",
     "040ee58a78af4dbe640955986397268fbb362131b32e7b5020773f509b17cb1f"),
])
def test_the_example_is_sams_issued_vector_byte_for_byte(path: str, said: str, digest: str) -> None:
    """Each is Guy's or Gal's credential from Sam's test_sedi_acdcs at 9a8b7aa7, unmodified.

    Copilot on #15: the outer SAID alone does not pin the vector, because the linter skips
    aggregate elements (~7v2h) and a partial disclosure keeps its outer SAID. The digest pins
    every byte, including Age's full A section.
    """
    raw = (ROOT / path).read_bytes()
    assert json.loads(raw)["d"] == said, SAM_CURRENT
    assert hashlib.sha256(raw).hexdigest() == digest, SAM_CURRENT
