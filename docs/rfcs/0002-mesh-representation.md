# RFC 0002: Mesh representation

[中文版本](../zh-CN/rfcs/0002-mesh-representation.md)

- Status: Under review
- Decision: pending
- Target milestone: M3

## Problem

Choose representations for individual cells, compatible meshes, and shape-regular
mesh families. The representation must support both abstract error analysis and
concrete affine Lagrange elements without forcing an executable mesh design.

## Ecosystem starting points

- Mathlib `v4.36.0` already defines $n$-simplices (`Affine.Simplex ℝ P n`,
  including `Affine.Triangle`) in `Mathlib.LinearAlgebra.AffineSpace.Simplex.Basic`,
  Euclidean simplex/triangle geometry and incenters in
  `Mathlib.Geometry.Euclidean.{Simplex, Triangle, Incenter.Basic}`, and the
  equality between algebraic simplex volume and Hausdorff/Lebesgue measure of
  `closedInterior` in `Mathlib.Geometry.Euclidean.Volume.MeasureSimplex`.
- Prototypes should evaluate wrapping Mathlib's `Affine.Simplex` on
  `EuclideanSpace ℝ (Fin 2)` rather than reimplementing elementary triangle
  volume and incenter geometry from scratch, placing missing general simplex
  lemmas in `FemLean/ForMathlib/`.

## Questions

- How should we deliver 2D triangular meshes cleanly for M3 while keeping a
  direct generalization path to $d$-dimensional simplices (for instance, using
  `EuclideanSpace ℝ (Fin 2)` rather than separate sup-norm and Euclidean types)?
- Are cells geometric simplices, indices into a vertex array, or both through an
  interface?
- How should nondegeneracy, face compatibility and coverage of one open
  $\Omega$ be expressed so that the Sobolev codomain of reconstruction stays
  fixed across a mesh family?
- How are boundary facets and essential boundary conditions represented?
- Is shape regularity a property of one cell, one mesh, or a family of meshes?
- Which parameters and constants must be explicit in approximation statements?
- Can analytic proofs avoid depending on executable data structures?

## Options to prototype

1. A geometric analytic interface with predicates for admissible meshes.
2. A bundled combinatorial-geometric structure carrying mesh invariants.
3. Separate analytic and executable representations connected by a specification.

## Required prototypes

Prototype the statement of a shape-regular family of triangular meshes and one
local affine pullback formula. Check degenerate triangles, hanging nodes,
nonconforming extensions, and whether higher-dimensional generalization is
artificially blocked.

### Fixed-domain example

For the first Poisson model, fix a bounded polygonal Lipschitz domain
$\Omega$ in the plane. For a finite conforming triangulation, write $S_h$
for the union of its closed triangles. Specify $S_h=\overline{\Omega}$,
$\operatorname{int}(S_h)=\Omega$, and that the closed edges incident to a
single triangle cover exactly $\partial\Omega$. Distinct triangles intersect
in a common face or have empty intersection.

Use two triangulations of the same open unit square. A diagonal gives two
triangles with zero free vertices. Joining the centre to the four corners
gives four triangles with one free vertex. Both reconstructions with
homogeneous boundary data must have codomain $H_0^1(\Omega)$ for the original
$\Omega$ from [RFC 0001](0001-sobolev-representation.md).

## Decision record

**Proposal for review, 2026-11-28.** Use option 2 for the analytic interface.
Keep global vertex IDs and each cell's ordered triple. A single injective
coordinate map and a proof of affine independence produce the Mathlib triangle.
The [Lean prototype](../../experiments/rfc0002/TriangleMesh.lean) uses finite
indices to make incidence computable. It does not prescribe a mesh file format,
storage layout, or an algorithm for finding a containing cell.

- A coordinate-only representation (option 1) would make assembly recover
  shared IDs from equality of points. The indexed representation requires a
  compatibility certificate once at mesh construction and provides these IDs
  directly to assembly. An executable mesh (option 3) can later provide the
  same data and certificate without changing the analytic interface.
- The intersection of distinct closed cells must equal the convex hull of their
  common vertices. A vertex touching the interior of an unsplit neighbouring
  edge violates this equality. Affine independence excludes collinear vertices;
  the unordered vertex sets distinguish cells even under reordering.
- The domain is an external parameter. The family has one shape bound for
  every cell of every mesh. Mathlib supplies the positive inradius, so the
  multiplicative bound is equivalent to the usual diameter/inradius ratio.
  The pullback test transports affine nodal values with barycentric weights.
- On the diagonal and centre-fan connectivities, the prototype derives zero
  and one free vertex respectively by counting incident cells. It also proves
  affine independence for all six triangles with their unit-square coordinates.
  The [unit-square certificates](../../experiments/rfc0002/UnitSquare.lean)
  construct `diagonalTriangulation` and `centreFanTriangulation` at the same
  type `Triangulation unitSquare`. Barycentric weights certify the intersection
  of every cell pair and coverage of the closed square. The edges with exactly
  one incident cell form the frontier, and the interior of the support is the open square.
  Nonconforming **elements** can reuse this mesh with
  different degrees of freedom. Hanging-node **meshes** need a different
  intersection contract. A higher-dimensional version replaces local triples
  and edges with simplex vertices and facets.

Follow-up tasks after independent review are to construct the reference-to-cell affine
equivalence from vertex data, and pass the certified boundary indices to the
Dirichlet reconstruction of RFC 0004. Record the reviewer and accepted choice
here when issue [#9](https://github.com/FormalCompMath/fem-lean/issues/9) is decided.
