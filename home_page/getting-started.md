---
layout: default
title: Getting Started
nav_order: 2
permalink: /getting-started/
---

# Getting Started

This page covers local setup. For task selection, statement review, proof review,
and merge rules, read the complete
[contribution guide](https://github.com/FormalCompMath/fem-lean/blob/main/CONTRIBUTING.md).

## Prerequisites

Install [elan](https://leanprover.github.io/lean4/doc/quickstart.html), which manages
the Lean toolchain. The repository pins Lean 4.36.0 and Mathlib 4.36.0.

## Clone and build

```bash
git clone https://github.com/FormalCompMath/fem-lean.git
cd fem-lean
lake exe cache get
lake build
lake env lean tests/Smoke.lean
```

Do not hand-edit `lake-manifest.json`. Dependency upgrades belong in dedicated PRs.

## Start a mathematical task

1. Claim an issue marked `status: ready` on the
   [task board](https://github.com/orgs/FormalCompMath/projects/1).
2. Create a short-lived branch from the latest `main`.
3. Open a Draft PR with definitions, theorem statements, sources, and examples.
4. Request independent semantic review before completing a long proof.
5. Remove every proof placeholder and request final review.

The first available mathematical task is the abstract bilinear-form interface in
[issue #3](https://github.com/FormalCompMath/fem-lean/issues/3).

## Documentation commands

```bash
python3 -m venv .venv
.venv/bin/pip install leanblueprint
.venv/bin/leanblueprint pdf
.venv/bin/leanblueprint web
lake build
.venv/bin/leanblueprint checkdecls
```

See the [Chinese documentation]({{ '/zh-CN/' | relative_url }}) for 中文项目说明.
