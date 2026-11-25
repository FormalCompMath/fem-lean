# Architecture

[中文版本](zh-CN/architecture.md)

## Design goal

FemLean should grow by adding modules, not by repeatedly modifying every existing
module. The repository is organized by mathematical dependencies, not by the
order of chapters in Braess's book.

## Layers

```text
FemLean/
├── Core/                 abstract variational and mixed formulations
├── Analysis/             Sobolev spaces, traces, inequalities, regularity
├── Geometry/             simplices, meshes, and shape-regular mesh families
├── FiniteElement/        elements independent of particular PDE models
├── Approximation/        interpolation and approximation theory
├── Error/                reusable abstract and a posteriori error results
├── Models/               Poisson, Stokes, elasticity, and their vertical slices
├── Solver/               algebraic iterative methods and multigrid
└── Computation/          executable implementations and their verification
```

Only the modules needed by current work should exist. Creating an empty tree of
anticipated modules is not a goal.

## Dependency rules

1. `Core` depends only on Mathlib and other core modules. It cannot import a
   mesh, element, or concrete model.
2. `Geometry` has no PDE or Galerkin dependency.
3. `FiniteElement` may use geometry and analysis, but not a concrete model.
4. `Approximation` may use finite element interfaces, but not model-specific
   error theorems.
5. `Solver` should depend on discrete operator and linear algebra interfaces,
   not triangular element implementations.
6. `Models` combines general components into concrete results. Generic results
   must not import `Models`.
7. `examples`, `tests`, and `experiments` are leaves. Library modules never
   import them.
8. `FemLean.lean` is a public convenience root. Internal modules import precise
   dependencies instead of that root.

Lean forbids import cycles, but it does not forbid undesirable layer inversions.
Import graph reviews should therefore be part of architecture maintenance.

## Vertical model slices

A concrete model may combine several stages without forcing those dependencies
into generic code. For example:

```text
Core variational theory ───────────────┐
                                       │
Analysis and P1 approximation ─────────┼── Models/Poisson/Error.lean
                                       │
Poisson weak formulation ──────────────┘
```

`Models/Poisson/Weak.lean`, `Models/Poisson/P1.lean`, and
`Models/Poisson/Error.lean` can have different precise imports. A new Stokes
model should not reuse a Poisson-specific proof merely for convenience.

## Extension tests

The architecture is working when:

- adding a higher-order Lagrange element does not change Céa's lemma;
- adding Stokes does not require importing Poisson's concrete error theorem;
- proving multigrid convergence does not require knowing nodal basis functions;
- a paper-specific experiment does not require a core change unless it exposes
  a genuinely reusable abstraction gap.

## Lean environment scalability

- Prefer `scoped` notation and local experimental instances.
- Avoid unnecessary global coercions and orphan instances.
- A global `simp` lemma should have a clear normal-form justification.
- Do not routinely hide expensive proof search by increasing heartbeats.
- Avoid accumulating unrelated declarations in `Util`, `Misc`, or giant `Basic`
  files.
- Split modules when declarations have independent consumers, not according to
  an arbitrary line limit.
- Keep `ForMathlib` entries small, general, and tracked for upstreaming or local
  integration.

## Repository scaling

Start with one repository and one Lake package. Multiple repositories create a
toolchain and dependency-version matrix. Paper-specific repositories may depend
on a tagged FemLean release and later upstream reusable results. Split core
mathematical components only after independent release requirements justify the
coordination cost.

## Stable and experimental code

Core representations evolve through RFCs and reviewed migration notes. Peripheral
elements and models can iterate in ordinary PRs. Experiments make no stability
promise but must not destabilize the main library. Releases and changelogs record
breaking changes, deprecations, and mathematical statement changes.
