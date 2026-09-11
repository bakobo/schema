# Contributing to schema

Thanks for considering it. This document is what you need to make a change here land; it stands on its own and assumes no access to anything private.

Before a large change, open an issue and describe what you want to do. Small fixes — a bug, a typo, a failing edge case — need no preamble; open the pull request.

## Getting to passing tests

```sh
cd tools/py
uv sync
uv run pytest
```

Every dependency is public. If a step asks you for a credential, that is a bug in our setup and we want to hear about it.

## How a change lands

Branch, push the branch, open a pull request against `main`. `test` must pass. Maintainers merge with a **merge commit or a rebase, never a squash** — the individual commits are the record, and collapsing them loses the per-commit history and the sign-off chain.

Direct pushes to `main` are blocked by a repository ruleset. Organization admins can bypass it, and that exists for the case where the process itself is broken, not as a shortcut.

## Sign off your commits

Every commit needs a `Signed-off-by:` trailer:

```sh
git commit -s -m "..."
```

That trailer is the [Developer Certificate of Origin](https://developercertificate.org/) — you are certifying you wrote the change, or have the right to contribute it under this repository's license. It is not a copyright assignment and there is no CLA to sign. The name and email must match the commit author.

If you forget, `git commit --amend --signoff` fixes the last commit and `git rebase --signoff <base>` fixes a branch. Never strip an existing trailer when amending.

## Tests are the specification, and coverage is a gate

Write the failing test first, watch it fail, then make it pass. **New code needs 100% branch coverage**, and CI enforces it rather than suggesting it — a pull request that lowers coverage does not merge.

This is stricter than most projects, so two clarifications. It applies to lines your change adds, not to the whole repository retroactively. And a branch you genuinely cannot reach from a test is a signal the branch should not exist; if you disagree, say so in the pull request and argue it, rather than reaching for a coverage pragma.

Test the unhappy paths. A test suite that only proves the happy path passes is the kind that stays green while the thing breaks.

## Why the change, not just what

This repo records its reasoning in `this.i` at the root — an intent tree of goals, constraints and decisions, each carrying a `why`. Code and `docs/` are derived from it. The rule internally is *a decision not in `this.i` is not yet made*, which exists because source code expresses instructions but not the human context they serve, and that context otherwise rots in comments and people's heads.

**You are not expected to author intent to contribute.** A bug fix, a new test, a doc correction, a port to another platform — none of those need a node. But if your change alters *what this software decides to do* — a new behavior, a different tradeoff, a rejected alternative that deserves recording — then say so in the pull request description and a maintainer will write the node with you. What we ask is that the reasoning reaches us in some form, not that you learn our format.

If you want to read it, `this.i` is plain YAML and the `why` fields are prose. It is the fastest way to understand why the code looks the way it does.

## Errors are part of the interface

Every error this software raises carries a stable symbolic code, says whether retrying could help, and reads as a complete plain sentence. Codes look like `e.state.conflict.r` or `e.input.range.f`: a sorter, a descriptor, and a trailing disposition token where `.r` means retrying could help and `.f` means it will not. They are classified by *what the obstacle was*, never by which component raised it, so a caller can prefix-match a whole branch of meaning.

Practically: if you add a failure path, give it a code in the existing style rather than raising a bare exception, and write the message as a sentence a user could act on. "Something went wrong" is not an error message.

## Using AI to write your contribution

That is fine, and we do it too. Two conditions.

**Say so in the pull request.** Not as a confession — as information a reviewer needs to know where to look.

**Own what you submit.** You are the author of your contribution regardless of what helped you write it, and you are signing the DCO over it. Be able to explain why the code does what it does, because a reviewer will ask and "the model wrote it" does not answer the question. An AI-assisted change that you understand is welcome; one you cannot defend is a change nobody can maintain.

Do not paste generated analysis of *other people's* projects into an issue here.

## Reporting a vulnerability

Do not open a public issue. Use the *Report a vulnerability* button under this repository's **Security** tab, or email `security@bakobo.com`. `SECURITY.md` has the detail: what to include, how fast we answer, scope, and safe harbour.

We would rather hear a false alarm than not hear a real one.

## Code of conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). Report unacceptable behaviour to `conduct@bakobo.com`.

## Things you will notice

**No `reviews/` directory.** Bakobo runs adversarial review panels over its repos and keeps the output permanently, but for a public repo that evidence lives in a private archive rather than in the tree — a security review is a map of a running system's weak points, and publishing one helps the wrong reader most. Its absence is not an absence of review.

**`AGENTS.md` links to a repository you cannot open.** It points at `bakobo/dev`, which is private. Everything in it that governs *your* contribution is restated in this file; if you find a rule enforced by CI that is not explained here, that is our bug — open an issue and we will fix this document.

**Commits with no `Co-Authored-By` trailer on AI-assisted work.** Deliberate. The DCO wants a sign-off for each author, and a tool cannot sign off, so the trailer would leave an author in the chain who certified nothing.

## License

By contributing, you agree your contribution is licensed under this repository's license — see `LICENSE`.
