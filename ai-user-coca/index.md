## AI User Code of Conduct Attestation (ai-user-coca)

### Purpose
This verifiable data attests that the issuer is committed to abide by a specific code of conduct in relation to their personal use of AI. It is a public declaration, not a credential. However, it may be cited as evidence that justifies credentials such as an [AI coder license](../ai-coder/index.md). 

### Suggested visual
![suggested visual](scroll-256.png)<br>
[640 px](scroll-640.png) | [256 px](scroll-256.png) | [64 px](scroll-64.png) | [32 px](scroll-32.png)
<br>Image credit: <a href="https://www.kindpng.com/imgv/hRbmxmh_scroll-icon-png-transparent-png/" target="_blank">Иконки Для Сторис @kindpng.com</a>

### Schema

The schema is in [`ai-user-coca.schema.json`](ai-user-coca.schema.json), its governance framework in [`rules.json`](rules.json), and a SAID-verified instance in [`example.json`](example.json). The [`invalid/`](invalid) directory holds the should-reject corpus.

The attribute block is two fields: `dt` (when the declaration was made) and `coc` (the code of conduct). `coc` SHOULD hold the SAID of a document published elsewhere, or HTML encoded as a data URL. It MAY hold an ordinary URL, in which case the issuer commits to whatever is published at that location rather than to specific content, since that content can change after the issuance date — the `referencedCodeMayChange` rule says so in the credential itself, and a verifier relying on such a declaration has to fetch the code and judge it.

One recommended code of conduct is in [`coc1.json`](coc1.json). To reference it, place its SAID `EMwE-XevWy8DkCf2oXSsDRjAUuQOXeuVSdKx8BRpCH-g` in `coc`. Note that `coc1.json` is the code of conduct itself, not an example credential.

### Public and self-issued

This is a declaration the issuer makes about itself, so 2.0.0 drops the attributes-block `i` that 1.0.0 required: there is no issuee, and the party committing is the issuer named at the top level. (1.0.0's field was described as "AID of issuee (award recipient)", which was copy-paste from the award credential.)

Like [bindkey](../bindkey/index.md), it carries no privacy nonce in either slot. A declaration nobody can see does no work, so being confirmable by anyone is the function rather than a leak.

`rd` is required. A public commitment that cannot be withdrawn outlives the issuer's willingness to stand behind it, and someone who stops committing needs a way to say so.

### Governance framework

Three Ricardian clauses travel with every instance. `commitmentNotCompliance` says this is a declaration of intent, not evidence of having abided by anything. `referencedCodeMayChange` carries the URL caveat above. `selfAsserted` says the declaration carries no third-party vetting, and whatever weight it has comes from the issuer being publicly accountable for having made it.

Version 1.0.0 is preserved at [`ai-user-coca-1.0.0/`](../ai-user-coca-1.0.0) and stays resolvable under its original SAID.
