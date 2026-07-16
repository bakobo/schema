## Bakobo engineering standards

How every Bakobo repo builds is governed by cross-cutting standards, canonical in the sibling
[`bakobo/dev`](../dev) repo. If `../dev` is not checked out beside this one, clone it before design
work: `git clone --depth 1 https://github.com/bakobo/dev`. Always on:

- **Intent-first** development and **strict TDD at 100% branch coverage of new code** — see the
  sections below and [`dev/methodology.md`](../dev/methodology.md).
- **Fail closed.** Untrusted input never carries authority; when something can't be checked, the
  effect does not land ([`org` principle 8](../org/design/purpose-and-principles.md)).
- **High-quality errors.** Every error carries a stable symbolic code, says whether retrying could
  help (permanent vs. transient), and reads as complete, plain sentences in the house voice — never
  "something went wrong." Full standard: [`dev/standards/error-handling.md`](../dev/standards/error-handling.md).
- **Tasks and tech debt in `tick`** — see the tick stanza below, not an external tracker.

## Intent methodology

Bakobo develops intent-first. If this repo has design decisions worth explaining, its source of
truth is `this.i` (the intent tree) at the repository root — code and `docs/` are derived from it.
Record each consequential decision in `this.i` **first**, in its own commit, **before** the code
commit it justifies. The full rules — what `this.i` is, when a repo needs one, the speculative
interview, the `why` rebuttal-surface standard, the gate ceremony, and adversarial review — are in
[`dev/methodology.md`](../dev/methodology.md), in the sibling `bakobo/dev` repo. Read it before
making design decisions here.

If this repo has no `this.i` yet and warrants one, see [`dev/methodology.md`](../dev/methodology.md)
§2 and the shipped `this.i.seed`. A trivial repo (pure content/assets/config, where no one will
later need to know *why*) may skip intent entirely — just delete `this.i.seed`.

## Design notes (reusable principles)

Repo-specific decisions live in `this.i`; reusable *design principles* distilled from them live as
derived docs under [`docs/`](docs) (they also render into the published site). Read these before
authoring a schema so you don't re-derive them:

- [`docs/choosing-attribute-vs-aggregate.md`](docs/choosing-attribute-vs-aggregate.md) — when to use an
  attribute (`a`) section vs an aggregate (`A`) section for graduated disclosure.
- [`docs/style.md`](docs/style.md) — schema field house style.

## Testing Protocol

This repo follows **strict TDD**. For each requirement, write failing tests that
capture the happy path and the edge/unhappy cases *first*, watch them fail, then
implement until they pass. Never check in without proving all tests pass. Target
**100% branch coverage of new code** — enforced in CI via `--cov-fail-under=100`
— and always leave existing code better tested than you found it. The test
command is `uv run pytest`, run in [`tools/py`](tools/py); see
[`tools/py/README.md`](tools/py/README.md) for the full command set. A gap from
the coverage target requires an approved `deviation:` node (see the methodology).

## CI and Documentation

CI is active: [`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs the
test suite (with the 100%-branch-coverage gate) on every push to `main` and
every pull request. Keep it green; add jobs as new toolchains land.

The repository [`README.md`](README.md) explains how to get from a fresh clone
to passing tests and carries the CI status badge at the top — keep it current as
workflows change.

When writing or modifying GitHub Actions workflows, always use the latest
stable release of each action. Avoid versions pinned to Node.js 16 or
Node.js 20 (both deprecated by GitHub). In 2026, this meant to prefer Node.js
24-compatible versions, but the standard may evolve over time. Check the GitHub
Marketplace for each action's current release.

<!-- >>> tick stanza >>> (managed by `tick init`) -->

## Task tracking: `tick`

This repo tracks tasks, tech debt, and ideas in a local [`tick`](https://github.com/dhh1128/tick)
ledger (an orphan `tick` branch; the `tick` CLI is the interface). Reads are plain
files — do **not** use an external API for task tracking.

- **First, if a `tick` command says the repo isn't initialized**, run `tick init`
  once to connect this clone to the ledger — it adopts the existing remote ledger
  if a colleague already set one up, or creates a new one otherwise.
- **A tick mark is the sigil `~` immediately followed by a digit-first 4-char
  base32 id** (the id part looks like `4mz3`, so the full mark is that id with a
  leading `~`). It pins a tick to a code location.
- **Before editing a file**, grep it for marks and read what they reference:
  `rg '~[2-7][a-z2-7]{3}\b' <file>` then `tick show <id>`. A mark means recorded
  context exists for that spot — read it first.
- **Search** existing ticks with `tick grep <text>`; **list** with `tick ls`.
- **Capture** new work with `tick add "<title>"` and place the printed mark
  (`~` + the new id) at the relevant code spot.
- When your change **resolves** a tick, run `tick off <id>` and **delete the
  mark(s)** it reports still in the code.

<!-- <<< tick stanza <<< -->
