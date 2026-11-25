# RFC 0002: Mesh representation

[中文版本](../zh-CN/rfcs/0002-mesh-representation.md)

- Status: Under review
- Decision: pending
- Target milestone: M3

## Problem

Choose representations for individual cells, compatible meshes, and shape-regular
mesh families. The representation must support both abstract error analysis and
concrete affine Lagrange elements without forcing an executable mesh design.

## Questions

- Are cells geometric simplices, indices into a vertex array, or both through an
  interface?
- How are nondegeneracy, compatibility of intersections, and domain coverage
  expressed?
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

## Decision record

Pending semantic and Lean API review.
