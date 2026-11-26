/-
Copyright (c) 2026 FormalCompMath contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: oopjoy
-/
module

public import Mathlib.Analysis.Normed.Operator.Bilinear
public import Mathlib.Analysis.Normed.Operator.NormedSpace

/-!
# Abstract variational problems

This module is the root of the abstract variational layer. It must not depend on
particular meshes, finite elements, or PDE models.
-/

public section

namespace FemLean.Core.Variational

variable {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]

/-- The nonnegative constant `M` bounds the bilinear form in the ambient norm. -/
def BoundedBy (a : V →L[ℝ] V →L[ℝ] ℝ) (M : ℝ) : Prop :=
  0 ≤ M ∧ ∀ u v, |a u v| ≤ M * ‖u‖ * ‖v‖

/-- The positive constant `α` controls the squared ambient norm by the diagonal of the form. -/
def CoerciveWith (a : V →L[ℝ] V →L[ℝ] ℝ) (α : ℝ) : Prop :=
  0 < α ∧ ∀ v, α * ‖v‖ * ‖v‖ ≤ a v v

/-- The pointwise continuity bound is equivalent to an operator-norm bound. -/
theorem boundedBy_iff_opNorm_le (a : V →L[ℝ] V →L[ℝ] ℝ) (M : ℝ) :
    BoundedBy a M ↔ ‖a‖ ≤ M := by
  constructor
  · rintro ⟨hM, h⟩
    exact a.opNorm_le_bound₂ hM (fun u v => by simpa only [Real.norm_eq_abs] using h u v)
  · intro hM
    refine ⟨(norm_nonneg a).trans hM, fun u v => ?_⟩
    rw [← Real.norm_eq_abs]
    exact a.le_of_opNorm₂_le_of_le hM le_rfl le_rfl

/-- Forgetting the chosen coercivity constant recovers Mathlib's predicate. -/
theorem isCoercive_iff_exists_coerciveWith (a : V →L[ℝ] V →L[ℝ] ℝ) :
    IsCoercive a ↔ ∃ α, CoerciveWith a α :=
  Iff.rfl

/-- A weak solution satisfies the variational equation against every test in `V`. -/
def IsWeakSolution (a : V →L[ℝ] V →L[ℝ] ℝ) (ℓ : V →L[ℝ] ℝ) (u : V) : Prop :=
  ∀ v : V, a u v = ℓ v

/-- A Galerkin solution belongs to `Vh` and satisfies the equation against every test in `Vh`. -/
def IsGalerkinSolution (a : V →L[ℝ] V →L[ℝ] ℝ) (ℓ : V →L[ℝ] ℝ)
    (Vh : Submodule ℝ V) (uh : Vh) : Prop :=
  ∀ vh : Vh, a (uh : V) (vh : V) = ℓ (vh : V)

end FemLean.Core.Variational
