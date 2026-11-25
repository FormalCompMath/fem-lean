# Contributing to FemLean

FemLean uses GitHub as the authoritative record for tasks, mathematical design,
review, and progress. Quick chat is welcome, but decisions affecting definitions,
interfaces, or milestones must be copied to an issue, PR, or RFC.

## Set up a development environment

Install `elan`, then run:

```bash
git clone https://github.com/FormalCompMath/fem-lean.git
cd fem-lean
lake exe cache get
lake build
lake env lean tests/Smoke.lean
```

Do not hand-edit `lake-manifest.json`. Update dependencies in a dedicated PR and
record the reason for the update.

## Choose and claim a task

1. Pick an issue marked `status: ready` and assign yourself, or outline the work
   in a comment before starting.
2. Check the linked dependency issues and blueprint nodes.
3. Keep the task small: one definition, one mathematical result, or one focused
   infrastructure change per PR.
4. Use a short-lived branch. Do not maintain a long-running private version of
   the library.

A task that is blocked should be marked `status: blocked` and should name the
exact definition, theorem, or decision it awaits.

## Use statement-first pull requests

For mathematical work, open a Draft PR early with:

- the informal statement and precise source;
- proposed definitions and theorem statements;
- assumptions and differences from the source;
- a concrete intended use;
- links to issues and blueprint nodes.

A proof placeholder may be used temporarily in a Draft PR. It must never reach
`main`. Request `status: statement review` before investing in a long proof.
After semantic approval, complete the proof and request final review.

## Pull request requirements

Every PR must:

- pass the Lean build, smoke tests, and axiom audit;
- preserve a working `main` branch;
- update blueprint nodes and declaration links when relevant;
- include compiling examples for new mathematical interfaces;
- separate mathematical changes from unrelated refactors and dependency updates;
- receive at least one non-author approval.

Changes under `FemLean/Core`, shared geometry or finite element interfaces, and
accepted RFCs require particular care. A breaking core change normally needs an
RFC, two approvals, and a migration note in the PR.

## Review responsibilities

The Lean kernel checks proofs. It does not check that a definition represents
the intended mathematical object. Review definitions and statements before
proof tactics. See [docs/review.md](docs/review.md).

When reviewing a proof whose statement has not changed, CI establishes proof
correctness. Focus on maintainability, unnecessary global instances or notation,
library reuse, and dependency direction.

## Dependency and module rules

Read [docs/architecture.md](docs/architecture.md). In particular:

- abstract variational code cannot import concrete meshes, elements, or models;
- finite elements cannot depend on a particular PDE model;
- algebraic solvers should not depend on geometric element implementations;
- examples and experiments are downstream leaves and are never imported by the
  library;
- internal modules import precise dependencies rather than the convenience root.

## Design discussions and RFCs

Use GitHub Discussions for exploratory questions. Convert a question to an issue
once it has concrete acceptance criteria. Use `docs/rfcs` for decisions that are
expensive to reverse, especially Sobolev, mesh, and finite element representations.

An RFC records the problem, options, small prototypes, trade-offs, decision, and
migration consequences. The final decision must not exist only in chat.

## Blueprint

The blueprint is the mathematical source of truth for progress; GitHub Projects
tracks task flow. Useful local commands are:

```bash
python3 -m venv .venv
.venv/bin/pip install leanblueprint
.venv/bin/leanblueprint pdf
.venv/bin/leanblueprint web
lake build
.venv/bin/leanblueprint checkdecls
```

Use `\lean{...}` to associate a node with Lean declarations, `\leanok` only when
the corresponding definition or proof is complete, and `\uses{...}` for semantic
dependencies. Do not mark a node complete merely because its statement compiles.

## Meetings and coordination

A short recurring meeting should resolve blocked reviews, core design decisions,
and the next set of parallelizable issues. Ongoing work should remain asynchronous
and visible on GitHub. New contributors should start with examples, documentation,
or independent lemmas before changing core representations.
