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
