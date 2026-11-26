# RFC 0004: Finite element interface

[中文版本](../zh-CN/rfcs/0004-finite-element-interface.md)

- Status: Draft
- Decision: pending
- Target milestone: M3

## Problem

Choose the Lean representation for a finite element (Ciarlet triple
$(K, P, \Sigma)$), reference-to-physical element transforms, and the bridge
from local degrees of freedom to global discrete spaces.

M3 targets 2D affine $P_1$ triangles first, while the interface should remain
usable without core rewrites when later milestones add higher-order Lagrange
elements ($P_k$), nonconforming elements (Crouzeix–Raviart), $H(\operatorname{div})$
elements (Raviart–Thomas), or $d$-dimensional simplices.

## Downstream uses

- **M3**: Prove $P_1$ unisolvence, the nodal basis identities and agreement on
  common edges. Reconstruct arbitrary nodal values in $H^1(\Omega)$. Let
  $D_h^0$ be the free vertex coordinates, identified by zero extension with
  nodal data vanishing at boundary vertices. Prove that
  $R_h^0:D_h^0\hookrightarrow H_0^1(\Omega)$ is linear and injective.
  `Models/Poisson` uses its range as the discrete subspace and instantiates
  the coordinate equivalence from `Assembly/`.
- **M4 (`Approximation/`)**: polynomial reproduction, reference interpolation
  operators, and affine pullback scaling.
- **M5 (`FiniteElement/`)**: higher-order $P_k$, edge-average degrees of
  freedom (CR), normal-flux moments (RT with Piola transform), and
  $d$-dimensional generalization.

## Questions

- How should the local shape space $P$ and degree-of-freedom evaluation map
  $\Sigma : P \to (\iota \to \mathbb{R})$ be bundled so unisolvence directly
  yields `P ≃ₗ[ℝ] (ι → ℝ)` and the nodal basis?
- Should local shape functions live on the ambient Euclidean space (as
  polynomials/affine maps restricted to $K$) or on the subtype `K`?
- How should reference-to-physical pullback be factored so affine scalar
  pullback (M3) and covariant/contravariant Piola transforms (M5) share common
  structure without over-engineering M3?
- How does local-to-global degree-of-freedom gathering connect cleanly to both
  global Sobolev conformity (`FiniteElement/GlobalSpace`) and matrix assembly
  (`Assembly/`)?

## Options to prototype

1. A lightweight bundled `FiniteElement` structure carrying reference geometry,
   finite-dimensional local space, linear DOF map, and unisolvence equivalence,
   instantiated first for 2D $P_1$.
2. A typeclass-driven reference element interface parameterized by cell type
   and degree-of-freedom index type.
3. Concrete 2D $P_1$ definitions first with a separate abstraction layer added
   only when a second element family is introduced.

## Required prototypes

Before acceptance, prototype the 2D $P_1$ triangle instance, verify the
Kronecker-delta property of its nodal basis, state affine pullback to a
physical triangle, and sketch how edge-average DOFs (Crouzeix–Raviart) or $P_2$
edge-midpoint DOFs would fit the same interface.

Use the [unit-square meshes](0002-mesh-representation.md#fixed-domain-example)
to distinguish the two global spaces. The unrestricted all-ones data must
reproduce the constant one, including its boundary values. On the four-triangle
mesh the unit free coordinate must reconstruct the centre hat, zero on all
boundary edges. This gives the Poisson assembly test a nonzero trial function.

## Decision record

Pending semantic and Lean API review.
