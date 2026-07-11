## Intent methodology

Bakobo develops intent-first. If this repo has design decisions worth explaining, its source of
truth is `this.i` (the intent tree) at the repository root — code and `docs/` are derived from it.
Record each consequential decision in `this.i` **first**, in its own commit, **before** the code
commit it justifies. The full rules — what `this.i` is, when a repo needs one, the speculative
interview, the `why` rebuttal-surface standard, the gate ceremony, and adversarial review — are in
[`docs/methodology.md`](docs/methodology.md). Read it before making design decisions here.

If this repo has no `this.i` yet and warrants one, see `docs/methodology.md` §2 and the shipped
`this.i.seed`. A trivial repo (pure content/assets/config, where no one will later need to know
*why*) may skip intent entirely — just delete `this.i.seed`.

## Testing Protocol

This repository appears to have no test suite yet. Before writing feature code
or fixing bugs, propose an appropriate testing framework for this project type
and add a single trivially-passing test to confirm the setup works. In the
same commit, propose to change AGENTS.md to replace this instruction with one
that instructs agents to follow strict TDD from now on: write failing tests
that capture happy path and edge cases/unhappy paths for each requirement,
observe them fail, implement until tests pass, never checkin without proving
that all tests pass, aim for 100% of all new code, and always leave existing
code better tested than it was before you touched it.

## CI and Documentation

This repo appears to have no CI workflows yet. Until it does, any time you make
code changes to the user, propose an appropriate set of GitHub actions (e.g.,
`.github/workflows/ci.yml`) that builds and runs tests on every push and
pull request. Propose to remove this instruction from AGENTS.md on the
same commit.

This repository has no README. As long is this is the case, any time you
make code changes for the user, propose to add a `README.md` that explains how
to get from a fresh clone to passing tests, with a clickable CI status
badge at the top for each active workflow. Propose to remove this
instruction from AGENTS.md on the same commit.

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
