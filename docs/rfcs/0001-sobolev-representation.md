# RFC 0001: Sobolev space representation

[中文版本](../zh-CN/rfcs/0001-sobolev-representation.md)

- Status: Under review
- Decision: pending
- Target milestone: M2

## Problem

Choose the primary weak-derivative Sobolev space interface used by Poisson weak
forms, traces, conformity, interpolation, and error estimates. The choice must
support bounded domains and \(H_0^1\), not only Fourier-based spaces on Euclidean
space.

## Ecosystem starting points

- Mathlib's `Mathlib.Analysis.Distribution.Sobolev` defines Bessel potential
  spaces through the Fourier transform.
- [EllipticPDE](https://github.com/alejandro-soto-franco/EllipticPDE) develops a
  weak-derivative Sobolev layer and elliptic Dirichlet theory on top of Mathlib.
- A project-local layer may be needed, but duplicating an incompatible Sobolev
  hierarchy has a high downstream cost.

## Options to prototype

1. Reuse an existing external development through a pinned dependency and expose
   a small FemLean adapter.
2. Build on current Mathlib definitions, adding bounded-domain weak derivatives
   where necessary.
3. Develop a project-local weak-derivative interface with explicit equivalence
   or translation results to ecosystem definitions.

## Evaluation criteria

- Expressiveness for \(H^1(\Omega)\), \(H_0^1(\Omega)\), traces, and piecewise
  finite element functions on bounded Lipschitz domains.
- Availability of Poincaré, Rellich–Kondrachov, and Lax–Milgram infrastructure.
- Ease of integrating existing proofs without hiding their assumptions.
- Maintenance and toolchain compatibility.
- Quality of downstream error-estimate statements.

## Required prototypes

Before acceptance, write the intended Poisson weak statement and a conforming
piecewise-polynomial membership statement using each serious candidate. Compare
the actual Lean types, not only their informal descriptions.

## Decision record

Pending semantic and Lean API review.

## Compiled prototype: EllipticPDE with a FemLean adapter

The prototype pins EllipticPDE at
`d25bc25df4289edc13cb4fa6b79a7d88cbe5b12b` and uses the root project's
Mathlib `v4.36.0`. Although the pinned external package declares `v4.35.0`, its
`EllipticPdes.Sobolev.Graph` module builds successfully with `v4.36.0`. The
Mathlib `require` must come last in `lakefile.toml`, so the root project
controls transitive dependency revisions. The external repository uses
`subDir = "lean"`.

The following checks succeeded without changing the Lean toolchain or raising
heartbeat limits:

```bash
lake build EllipticPdes.Poincare.GraphBounded
lake env lean experiments/rfc0001/EllipticPDE.lean
```

The [prototype](../../experiments/rfc0001/EllipticPDE.lean) checks these actual
Lean types on `Plane := EuclideanSpace ℝ (Fin 2)`:

```lean
EllipticPdes.H1Graph volume Ω
EllipticPdes.H1Graph.W12 volume Ω
EllipticPdes.H1Graph.H01 volume Ω
(Vertex → ℝ) →ₗ[ℝ] EllipticPdes.H1Graph.W12 volume Ω
(FreeVertex → ℝ) →ₗ[ℝ] EllipticPdes.H1Graph.H01 volume Ω
```

Here `W12` is the closed weak-gradient graph subspace and `H01` is the closure
of test-function graphs. Both have the inherited real Hilbert structure, and
`H01` has an inferred `CompleteSpace` instance. Function and gradient
projections are continuous linear maps `fnL` and `gradL`.

The prototype defines the Dirichlet form directly from `gradL`, proves
`Core.Variational.BoundedBy (dirichletForm Ω) 1` and symmetry, constructs an
`L²` load through `embL2`, and states the Poisson equation using the existing
`Core.Variational.IsWeakSolution`. No duplicate weak-solution predicate or
custom axiom is introduced.

The fixed open unit square is represented by one open set in `Plane`. Both
reconstruction signatures use the same `Ω`; no equality recursor or dependent
cast between domain representations is needed. Its openness proof uses finite
coordinate intersections rather than the linear-order `Set.Ioo` API, which is
inapplicable to the coordinate partial order on `Plane`.

## Poincaré and existence path

The external graph interface already provides
`EllipticPdes.H1Graph.poincare_H01_of_bounded`: boundedness of `Ω` gives a
nonnegative constant controlling the squared `L²` norm of the function part by
that of the gradient on `H01`. This yields an explicit coercivity constant for
the Dirichlet form. `EllipticPdes.DivForm.FullEllipticOp` also demonstrates the
intended Lax–Milgram path through Mathlib's
`IsCoercive.existsUnique_apply_eq`.

For M2, FemLean should instantiate these results for the unit-coefficient
Poisson form and expose `BoundedBy` and `CoerciveWith` with explicit constants.
There is no need to reprove the graph-space Poincaré inequality locally.

## Comparison after prototyping

1. **Pinned EllipticPDE plus a small adapter — preferred.** It reuses the
   completed graph-space, weak-derivative, `H01`, density and Poincaré layers.
   The adapter can expose short FemLean names and connect the existing
   variational predicates without introducing a parallel hierarchy.
2. **Mathlib-only local construction — not recommended for M2.** Current
   Mathlib supplies test functions, distributions and Fourier-based Bessel
   potential spaces, but not the bounded-domain graph construction. Repeating
   the external `H1Graph`, `W12`, `H01` and Poincaré proofs would create a large
   compatibility burden before finite element work could begin.
3. **A separate project-local Sobolev hierarchy — rejected unless reuse becomes
   infeasible.** The prototype shows no need for a second representation.
   Small FemLean adapters are still appropriate, but they should retain the
   external graph types and their instances rather than hide them behind a new
   interface with no downstream benefit.

The cost is a pinned external dependency and additional compile surface.
Mathlib upgrades must include an EllipticPDE compatibility check. The pin and
`subDir` setting are therefore part of the proposed interface decision, not an
untracked local experiment.

## Proposed decision and follow-up work

Propose **Option 1**, with the compiled adapter as the M2 starting point. This
remains a proposal until independent semantic and Lean API review.

The external dependency does not eliminate the finite-element-specific work.
In particular, no general boundary-trace operator was found in the pinned
revision. Follow-up issues should cover:

- a minimal `FemLean/Analysis/Sobolev` adapter, not a duplicate hierarchy;
- explicit Poisson coercivity and the Lax–Milgram instantiation;
- bounded-domain `H²`, the required continuous-representative and trace
  interface, and their relation to `H1Graph.W12` / `H01`;
- conformity of piecewise affine functions and the zero-boundary reconstruction
  into `H01`;
- affine pullback, interpolation and the `H²` seminorm needed for M4.
