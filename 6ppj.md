# schematools: discover_schemas / cmd_registry read *.schema.json through symlinks without a resolved-root containment check (rules.json got one in #9). Pre-existing; found by a DeepSeek review of the #9 fix delta. Also a TOCTOU between resolve() and read_text() in cmd_registry (local dev tool, low risk).
kind: debt
created: 2026-09-23T03:36Z

