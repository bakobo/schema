# SEDI Identity Assurance Receipt

The proofing agent issues this receipt to the citizen after identity proofing. It is signed without a registry anchor; its `u` is the challenge the citizen anchors in their KEL. The schema is reproduced from [Sam Smith's SEDI test module at `ec307cd74`](https://github.com/WebOfTrust/keripy/blob/ec307cd74/tests/sedi/test_sedi.py#L26-L136). Sam Smith is the schema author. Version `0.1.0` and SAID `EHp3Ik9q-6-sT0IFaLRJDEjd-j3zMRdy1aN6O6awCsZd` are pinned for the Summit.

[`example.json`](example.json) illustrates the required shape. Files in [`invalid/`](invalid/) exercise missing attributes and a forbidden extra envelope field. These examples are local structural examples, not Sam's issued test vectors.
