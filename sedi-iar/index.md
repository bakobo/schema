# SEDI Identity Assurance Receipt

The proofing agent issues this receipt to the citizen after identity proofing. It is signed without a registry anchor; its `u` is the challenge the citizen anchors in their KEL. This is [Sam Smith's IAR schema at keripy `9a8b7aa7`](https://github.com/WebOfTrust/keripy/blob/9a8b7aa7/tests/sedi/test_sedi.py#L34-L146), reproduced byte for byte with SAID `EFAB6k77bXHs6bg9PORW7UYF79GD_OuEcEjmBpwhcfRN`. Sam Smith is the author. Since his earlier revision it gains a required `nameSuffix`, which may be empty. The [earlier IAR at `ec307cd74`](../sedi-iar-pre-sam-repin-0.1.0/) remains resolvable.

[`example.json`](example.json) is Guy's IAR from Sam's `test_sedi_acdcs` at `9a8b7aa7`, unmodified. Files in [`invalid/`](invalid/) exercise a missing attribute section and a forbidden extra envelope field. `this.i` `@3x2jtfxc` records the re-pin.
