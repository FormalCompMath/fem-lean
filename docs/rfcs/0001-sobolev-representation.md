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

- Mathlib `v4.36.0` provides bundled compactly supported smooth test functions
  `Mathlib.Analysis.Distribution.TestFunction` (`𝓓(Ω, F)`), distributions
  `Mathlib.Analysis.Distribution.Distribution` (`𝓓'(Ω, F)`), the fundamental
  lemma `Mathlib.Analysis.Distribution.AEEqOfIntegralContDiff`, mollification
  via `Mathlib.Analysis.Calculus.BumpFunction.{Convolution, SmoothApprox}`, and
  whole-space integration by parts in
  `Mathlib.Analysis.Calculus.LineDeriv.IntegrationByParts`.
- Mathlib's `Mathlib.Analysis.Distribution.Sobolev` defines Fourier-based
  Bessel potential spaces on full Euclidean spaces, and
  `Mathlib.Analysis.FunctionalSpaces.SobolevInequality` proves
  Gagliardo–Nirenberg–Sobolev bounds for compactly supported $C^1$ maps;
  neither directly provides bounded-domain $H^1(\Omega)$ or $H_0^1(\Omega)$.
- [EllipticPDE](https://github.com/alejandro-soto-franco/EllipticPDE) develops a
  weak-derivative Sobolev layer and elliptic Dirichlet theory on top of Mathlib.
- A project-local layer may be needed, but duplicating an incompatible Sobolev
  hierarchy has a high downstream cost; missing general lemmas belong in
  `FemLean/ForMathlib/`.

## Options to prototype

1. Reuse an existing external development through a pinned dependency and expose
   a small FemLean adapter.
2. Build on current Mathlib definitions, adding bounded-domain weak derivatives
   where necessary.
3. Develop a project-local weak-derivative interface with explicit equivalence
   or translation results to ecosystem definitions.

## Evaluation criteria

- Support for a **2D-first delivery in M2** without blocking later
  generalization to $d$ dimensions (`EuclideanSpace ℝ (Fin d)`) and
  vector-valued spaces ($H^1(\Omega; \mathbb{R}^d)$, $H(\operatorname{div})$);
  in particular, avoid mixing sup-norm product spaces (`ℝ × ℝ`) with Euclidean
  norms.
- Expressiveness for bundled \(H^1(\Omega)\), graph-closure \(H_0^1(\Omega)\),
  \(H^2(\Omega)\), traces, and piecewise finite element functions on bounded
  domains.
- Availability of Poincaré/Friedrichs, Rellich–Kondrachov, and Lax–Milgram
  infrastructure.
- Ease of integrating existing proofs without hiding their assumptions.
- Maintenance and toolchain compatibility.
- Quality of downstream error-estimate statements (including keeping elliptic
  regularity as an explicit hypothesis rather than baking it into space
  definitions).

## Required prototypes

For each candidate, type-check the Poisson weak equation with
`Ω : TopologicalSpace.Opens (EuclideanSpace ℝ (Fin 2))`. Record the inner
product and source of completeness used to apply Lax–Milgram on $H_0^1(\Omega)$.

Use the open unit square and the two triangulations in
[RFC 0002](0002-mesh-representation.md#fixed-domain-example) to compare the
reconstruction signatures. For each mesh the unrestricted map takes values
in $H^1(\Omega)$ and the boundary-zero map takes values in the same
$H_0^1(\Omega)$. M2 checks these types with $\Omega$ fixed. M3 supplies the
meshes and proves conformity.

## Decision record

Pending semantic and Lean API review.
