# RFC 0003 — Bounded and coercive bilinear forms

[中文版本](../zh-CN/rfcs/0003-bilinear-form-interface.md)

- **Status** Draft
- **Milestone** M1
- **Issue** [#3](https://github.com/FormalCompMath/fem-lean/issues/3)

## Intended use

Céa's estimate uses the ratio of a chosen continuity bound to a chosen
coercivity constant, both for the same norm. The reference is Braess,
third English edition, Chapter II, §4, Lemma 4.2, p. 55. The weak and
Galerkin specifications in #4 are the first consumers of the bundled form.

## Options

1. Use Mathlib's continuous linear maps for the bilinear form and express the
   continuity bound as an operator-norm inequality. Use Mathlib's existential
   `IsCoercive` and choose a witness when a downstream result needs one.
2. Use the same bundled form and add predicates with explicit bound arguments.
   Keep the bridges to Mathlib so existence proofs can extract or forget a
   witness and error estimates can retain the caller's chosen constants.
3. Define a structure that stores the form, both constants, and their proofs.
   This would commit to particular bounds when constructing the form and
   require a new bundle to change them.

## Proposed interface

The branch implements option 2 in [the variational module](../../FemLean/Core/Variational.lean).
The form has type `V →L[ℝ] V →L[ℝ] ℝ`. The first argument is the trial
argument and the second is the test argument. `BoundedBy a M` includes
$0\le M$ and the pointwise bound. `CoerciveWith a α` includes
$0<\alpha$ and the diagonal bound. Both use the ambient norm. Neither
predicate assumes symmetry, completeness, or an inner product.

The definitions therefore apply to real normed spaces, which include the
Hilbert spaces in the source. The operator-norm equivalence uses Mathlib's
bilinear norm inequalities. The existential coercivity equivalence is
definitional with the product form of the squared norm.

The [smoke tests](../../tests/Smoke.lean) exercise real multiplication, the
zero continuity bound, failure of coercivity for the zero form on $\mathbb R$,
and coercivity on the zero-dimensional subspace.

## Decision

Pending independent semantic review. Confirm the explicit-constant API and
the normed-space assumptions before downstream issues build on this interface.
