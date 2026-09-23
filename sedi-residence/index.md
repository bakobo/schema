# SEDI Residence

The state issues Residence to the citizen as a separate credential, with independently disclosed street, city, county, state, postcode, and country blocks. Its required `coreIdentity` edge links to Core with `E1E` and `NI2I`. This is [Sam Smith's Residence schema at `ec307cd74`](https://github.com/WebOfTrust/keripy/blob/ec307cd74/tests/sedi/test_sedi.py#L361-L588); Sam Smith is the author. Version `0.1.0` and SAID `EEgFNN1XH90koG5J5pbXKlRNU6TnibizaTQmJcRfEcop` are pinned for the Summit.

[`example.json`](example.json) illustrates the required shape; it is a local structural example, not Sam's issued vector. [`invalid/`](invalid/) holds negative cases.
