"""Pinned SEDI schema vectors: Sam Smith's current schemas and every revision they displaced.

The current IAR, Core, Residence, Age and Guardian are Sam Smith's at keripy 927c0cb8, the last
planned re-pin before the Summit freeze (`this.i` @3x2jtfxc, @hxqwde3o, @6uxg0vj0); IAR is unchanged
since 9a8b7aa7, and Guardian is new at 927c0cb8.
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
SAM_CURRENT = "https://github.com/WebOfTrust/keripy/blob/927c0cb8/tests/sedi/test_sedi.py"
SAM_ORIGINAL = "https://github.com/WebOfTrust/keripy/blob/ec307cd74/tests/sedi/test_sedi.py"

# Sam's IarSchemaSaid, CoreSchemaSaid, ResidenceSchemaSaid, AgeSchemaSaid and GuardianSchemaSaid at 927c0cb8.
SAM_CURRENT_PINS = {
    "sedi-iar": (
        "EFAB6k77bXHs6bg9PORW7UYF79GD_OuEcEjmBpwhcfRN",
        "4ffecad00c3b4db27b67a18bc621dc19c2a6821c9a58189a06cc468561073b2a",
    ),
    "sedi-core": (
        "EN0JtdzBmFuTUzyJG9CXZhtdu-bW0V6L95bsVBzi-cY-",
        "4f72b46cb8684f8519760633671153a8d5bc5dd929a61f7085a713ceab2c196e",
    ),
    "sedi-residence": (
        "EH5hn7CbtDFxhS3IKioC8P-e4YyZoxqzhRpr4X_e32BD",
        "da7580f32689c223d9931088a1a4f15592aa3a28db9bcc7a9f1f2c6764ba66a0",
    ),
    "sedi-age": (
        "EPqXrwPT6b0_KghrrMuIdmuD68Aytv1XK6jU86EumgJV",
        "dc90a335ef9cba59e69870198779d3c4326d92ac22f4a195a0f05236dc9ef3d1",
    ),
    "sedi-guardian": (
        "EDJzXg34opr6-odFix6lpiccfHF7ksITHuIES_MQRH4b",
        "d6e5e93ad7cdaca607741a073b43b4e0ec61ee8818fa90e01edc38612fe31e3e",
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

# Published Bakobo revisions displaced by the re-pins, kept byte for byte.
DISPLACED = {
    "sedi-core-pre-927c0cb8-0.1.0": (  # Sam's Core at 80f77b73
        "ECxPtf9IpBUT1pRZK4eaLA8O2jlc1oXYioYjcHo09eUC",
        "bf962fae8774169ac4d244f6a97c7e6ffaac4dbc43247ec8e08c825d0bd7dcdd",
    ),
    "sedi-residence-pre-927c0cb8-0.1.0": (  # Sam's Residence at 9a8b7aa7 and 80f77b73
        "EH7ayivQLHwfBKwFhg7mcpOzHEWcvvJ24EO0OyzvPVKQ",
        "e115d4fc8f00cf54d07429f5286574388c5003177c23c0a5376706d00dd90708",
    ),
    "sedi-age-pre-927c0cb8-0.1.0": (  # Sam's Age at 9a8b7aa7 and 80f77b73
        "EH-ZOEzzWm5hw351zL3IBJiEMDnJiKrv17lQp2JFj8Sb",
        "9e8bf1e3f675ff671ce1b01a942f87d8c1daf7e235397f3db75dbdaba1992f20",
    ),
    "sedi-guardian-pre-927c0cb8-3.0.0": (  # Bakobo's guardian profile
        "ECY9m207KdsKfiu3uYUyb02VYmpOP9vDgwKDFPMjoCVp",
        "cd4ee439d334f1947665c1b270c0ebb0c194e78a48cf43c568c00b9c26a8c9df",
    ),
    "sedi-present-county-pre-927c0cb8-2.0.0": (
        "EE6o5cfqMmRAcTu0WfMMOTd9xniPbWVqoL85FlivvOix",
        "e5d0a5eea55f356f117c2af8a025889471568a73f2d25b825686937eba2861d5",
    ),
    "sedi-present-age-portrait-pre-927c0cb8-4.0.0": (
        "EGQpseOOtheu3i-_UCik0QkPT_UZt6W3pE6p-Fdv51mJ",
        "c41ab5ff3f80aa64d7181b3375fa520602361a06ec4196fa8733beded77bcf75",
    ),
    "sedi-ward-authz-pre-927c0cb8-1.0.0": (
        "EJjrclOqob8req1mLuuhg5Q8Ap2qZ2gUL5sk_gb-B8FN",
        "e99d755884a2588d92d7d46ebd88db28d20b99510a501683421af1176d3b6fcd",
    ),
    "sedi-core-pre-guardians-0.1.0": (  # Sam's Core at 9a8b7aa7
        "EAyyREL1r5OL8Z9HGl47df26rn_JRLsC7PVDBH5RtwLs",
        "70784bbf5d317760e0d488733c28b19d5281cd4e3dcdd946b778fb6582c4b934",
    ),
    "sedi-present-county-pre-guardians-2.0.0": (
        "EB8EAlIHO4QP1crmlXMm8a-rt3k4xZPXN0uAixvtvhSA",
        "95b80dcc3bd7f2445be4b3e5c40468dee40b76cfb34af8335d944c7a9655170b",
    ),
    "sedi-present-age-portrait-pre-guardians-4.0.0": (
        "EJa3e-HPIKURXlx9zxw2Wqzgs7wefdQQDX18pNycYz68",
        "82d29e85c608314730ffa9528f1f4e5a92cfcbc6516d4b8f169b7d7e6859619e",
    ),
    "sedi-guardian-pre-guardians-3.0.0": (
        "EGpQePxZPKq9nPF99rI9IawvJgMukfPxjI6WKN8GFVfV",
        "95176689784f1f4db0a8a089cdaf7523a80d7dbdb1e77db895cee2d464be40c1",
    ),
    "sedi-ward-authz-pre-guardians-1.0.0": (
        "EJBGTT5-5SAAWjQloHV69kcvg6vMLgNk-6tjzjEv2SSO",
        "92ef65a839f4e994e8a2fcd119f172e6b0d543483bf98e195f615d7ce92da9b1",
    ),
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
    ("sedi-iar/example.json", "EByqzW5jFrrXhC_b9jYkHJaWAoc3L5GTqmmWUnq4KGQ9",
     "ff5eea6d416e476fe6a907ddb288cd4b11c928ecd43987083981b7b61e4d8ed9"),
    ("sedi-core/example.json", "EGsPyGCyHtDSWP61rVsRh3F8qooP_jrX6qPHqHn7-FOg",
     "5881b42139c1c0e36abdbd5fe602e93e9a5866434d09ae41d4253c89b252e8c4"),
    ("sedi-core/examples/gal.json", "ENIxm13eUECS_QAdqfKTnvIyjL4gI39F4Fo6HQADtfzn",
     "e06fdf9d00d1e662f2260e91fabc1cc41bd486999273c011d3b0947bb27ca3f4"),
    ("sedi-core/examples/wyn-ward.json", "EO2_WbE5hiB3HpwD2XDQShBDXSLsh7cYaIil_pWOBplX",
     "e9db0e3bd2270cbac3ad2de129d193a022e48438b5dd0ab8c29a3084dc6e02d6"),
    ("sedi-residence/example.json", "EBmFqhgpZL_Dc6PLgZBuKtsYfl6ajXYihYLyp7qgcbPb",
     "d013e338befa99d5cdb6cb2464a53d237965df0b83452b05069bde6aab18728f"),
    ("sedi-age/example.json", "ECfZCyLfleF3zA8qsHJ0WZYXW5xyR-aPDC8dl6RfLd27",
     "e63ecdbd3a509d39704d216a4ebc9af188715b7f05329502064756cdd195da49"),
    ("sedi-guardian/example.json", "ENTwQxDFnVXigOTcymAXSHCgl26a0p3POYiRFnTL1lb0",
     "89f86551420578210b148a8ce4631b0ecab11a6093a06b34c26ae5ed47f8aa79"),
    ("sedi-guardian/examples/guy.json", "EONzgE0pcYF7hz1E_VVN4ea9iv75Q_C2ifhsZV1j6uQp",
     "7c97dcfa53d20ba4fcff78c439f483a6ccbfb609766c9bf8fdc318c7800799ee"),
])
def test_the_example_is_sams_issued_vector_byte_for_byte(path: str, said: str, digest: str) -> None:
    """Each is Guy's, Gal's or Wyn's credential from Sam's test_sedi_acdcs at 927c0cb8, unmodified.

    Copilot on #15: the outer SAID alone does not pin the vector, because the linter skips
    aggregate elements (~7v2h) and a partial disclosure keeps its outer SAID. The digest pins
    every byte, including Age's full A section.
    """
    raw = (ROOT / path).read_bytes()
    assert json.loads(raw)["d"] == said, SAM_CURRENT
    assert hashlib.sha256(raw).hexdigest() == digest, SAM_CURRENT
