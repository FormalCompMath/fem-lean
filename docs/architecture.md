# Architecture

[中文版本](zh-CN/architecture.md)

## Design goal

FemLean should grow by adding modules, not by repeatedly modifying every existing
module. The repository is organized by mathematical dependencies, not by the
order of chapters in Braess's book.

This document defines module responsibilities, import rules, and Mathlib reuse.
The [roadmap](roadmap.md) sets milestone acceptance criteria. Representation
decisions belong in the [RFCs](rfcs/README.md). The
[architecture plan (Chinese)](../fem_lean_architecture_plan.md) maps the book
and the reference implementation to the modules.

## Layers

```text
FemLean/
├── Core/                 abstract variational, saddle-point, and a priori error theory
├── Geometry/             Euclidean simplices, meshes, and shape-regular families
├── Analysis/             Sobolev spaces, traces, inequalities, and regularity interfaces
├── FiniteElement/        Ciarlet triples, concrete elements, and global spaces
├── Approximation/        Bramble–Hilbert, reference scaling, and interpolation bounds
├── Assembly/             local form assembly, coordinate matrices, elimination, condensation
├── Solver/               algebraic iterative methods, Krylov, and multigrid
├── Models/               Poisson, Stokes, elasticity, and their vertical slices
├── Aposteriori/          (M5 on-demand) mesh-dependent a posteriori error and adaptivity
└── ForMathlib/           small general lemmas intended for upstream Mathlib
```

Only the modules needed by current work should exist. Creating an empty tree of
anticipated modules is not a goal. Executable numerical implementations
(floating-point / sparse-matrix computation) are kept outside the core theory
layers as a future downstream concern.

## Scope and progression

- **Core scope**: FemLean focuses on variational and finite element theory.
  Classical PDE maximum principles and finite-difference schemes (Braess
  Chapter I) are intentionally outside the core library scope.
- M4 assumes $H^2$ regularity of the particular weak solution. A bound on the
  solution operator for every load belongs to a separate regularity theorem.
- **2D-first, generalization-friendly**: Initial concrete geometry, Sobolev,
  element, and interpolation milestones target 2D first to complete the first
  end-to-end $P_1$ convergence slice cleanly. Representations should still avoid
  traps that hinder later $d$-dimensional generalization—for example, preferring
  `EuclideanSpace ℝ (Fin 2)` over mixed sup-norm/Euclidean coordinates, and
  expressing domain coverage so fixed-domain mesh families avoid dependent-type
  casts.

## Mathlib reuse boundary (v4.36.0)

Before introducing project-local primitives, reuse existing Mathlib `v4.36.0`
infrastructure directly and place missing general lemmas in `ForMathlib/`:

- **`Core/`**: `Analysis.InnerProductSpace.{Dual, LaxMilgram, Projection}`,
  `Analysis.Normed.Operator.Bilinear`.
- **`Geometry/`**: `LinearAlgebra.AffineSpace.Simplex.Basic` (`Affine.Simplex`,
  `Affine.Triangle`), `Geometry.Euclidean.{Simplex, Triangle, Incenter.Basic,
  Volume.MeasureSimplex}`, and `MeasureTheory.Measure.Haar.*`.
- **`Analysis/`**: `Analysis.Distribution.{TestFunction, Distribution,
  AEEqOfIntegralContDiff}`, `Analysis.Calculus.BumpFunction.{Convolution,
  SmoothApprox}`, `Analysis.Calculus.LineDeriv.IntegrationByParts`, and
  `MeasureTheory.Integral.DivergenceTheorem`. (Mathlib's Fourier-based
  `Analysis.Distribution.Sobolev` does not replace bounded-domain $H^1(\Omega)$
  / $H_0^1(\Omega)$.)
- **`FiniteElement/` & `Approximation/`**: `Algebra.MvPolynomial`, `AffineMap`,
  `LinearAlgebra.Lagrange`, and `Analysis.Calculus.TaylorIntegral`.
- **`Assembly/` & `Solver/`**: `LinearAlgebra.Matrix.{PosDef, SchurComplement,
  BilinearForm}` and `Analysis.InnerProductSpace.Spectrum`.

## Dependency rules

1. `Core` uses Mathlib, general lemmas from `ForMathlib`, and other core modules.
   `ForMathlib` depends only on Mathlib and its own general lemmas.
2. `Geometry` has no PDE or Galerkin dependency.
3. `Analysis` may use `Geometry` Euclidean and measure primitives, but cannot
   depend on meshes or finite elements.
4. `FiniteElement` may use geometry and analysis, but not a concrete model.
5. `Approximation` may use geometry, analysis, and finite element interfaces,
   but not model-specific error theorems.
6. `Assembly` connects discrete variational forms in `Core` with linear algebra
   and coordinate matrices (including boundary elimination and static
   condensation); it must not depend on concrete PDE models or triangle
   internals.
7. `Aposteriori` (added on demand in M5) covers mesh-dependent a posteriori
   error estimation and adaptivity. Model-independent a priori bounds
   (such as Céa, Aubin–Nitsche, Strang, and Brezzi quasi-optimality) remain in
   `Core`.
8. `Solver` should depend on discrete operator and linear algebra interfaces
   (such as `Matrix.PosDef` supplied via `Assembly`), not triangular element
   implementations.
9. `Models` combines general components into concrete results. Generic results
   must not import `Models`.
10. `examples`, `tests`, and `experiments` are leaves. Library modules never
    import them.
11. `FemLean.lean` is a public convenience root. Internal modules import precise
    dependencies instead of that root.

Lean forbids import cycles, but it does not forbid undesirable layer inversions.
Import graph reviews should therefore be part of architecture maintenance.

## Vertical model slices

### Assembly conventions

For trial basis functions $\phi_j$ and test basis functions $\psi_i$, set
$K_{ij}=a(\phi_j,\psi_i)$ and $F_i=\ell(\psi_i)$. Thus the test vector pairs
with $KU$. With the same basis in both slots, Mathlib's
`LinearMap.BilinForm.toMatrix_apply` gives $a(\phi_i,\phi_j)$. Transpose this
matrix to obtain $K$. In the standard basis of the plane, $a(x,y)=x_1y_2$
gives $K_{21}=1$ and $K_{12}=0$ (indices start at one).

`Assembly` proves coordinate equivalence for general bilinear forms. Its
positive-definiteness result uses a symmetric, coercive form and an injective
reconstruction. `Models/Poisson` supplies those hypotheses for the Dirichlet
energy on the boundary-zero space. In Mathlib v4.36.0,
`Matrix.PosDef.fromBlocks₁₁` characterizes **semidefiniteness** via the Schur
complement of an invertible positive-definite block.

### Poisson error estimate

A concrete model may combine several stages without forcing those dependencies
into generic code. For example:

```text
Core variational theory ───────────────┐
                                       │
Analysis and P1 approximation ─────────┼── Models/Poisson/Error.lean
                                       │
Assembly and matrix equivalence ───────┤
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
- adding static condensation or changing a linear solver does not require
  knowing nodal basis functions or triangle geometry;
- generalizing 2D Euclidean/simplex modules to $d$ dimensions does not force
  rewriting `Core`, `Assembly`, or `Solver`;
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
