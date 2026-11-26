/-
Copyright (c) 2026 FormalCompMath contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: oopjoy
-/
module

public import Mathlib.Analysis.Normed.Operator.Bilinear
public import Mathlib.Analysis.Normed.Operator.NormedSpace
import Mathlib.Basic.Real.Pointwise

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

/-- The error annihilates discrete tests in the second slot of the bilinear form. -/
theorem galerkin_orthogonality {a : V →L[ℝ] V →L[ℝ] ℝ} {ℓ : V →L[ℝ] ℝ}
    {Vh : Submodule ℝ V} {u : V} {uh : Vh}
    (hu : IsWeakSolution a ℓ u) (huh : IsGalerkinSolution a ℓ Vh uh) (vh : Vh) :
    a (u - (uh : V)) (vh : V) = 0 := by
  rw [map_sub, sub_apply, hu, huh vh, sub_self]

/-- Céa's quasi-optimality estimate in the ambient norm (Braess II.4.2). -/
theorem cea {a : V →L[ℝ] V →L[ℝ] ℝ} {ℓ : V →L[ℝ] ℝ}
    {Vh : Submodule ℝ V} {u : V} {uh : Vh} {M α : ℝ}
    (hbound : BoundedBy a M) (hcoer : CoerciveWith a α)
    (hu : IsWeakSolution a ℓ u) (huh : IsGalerkinSolution a ℓ Vh uh) :
    ‖u - (uh : V)‖ ≤ (M / α) * (⨅ vh : Vh, ‖u - (vh : V)‖) := by
  have hratio := div_nonneg hbound.1 hcoer.1.le
  rw [Real.mul_iInf_of_nonneg hratio]
  apply le_ciInf
  intro vh
  let e := u - (uh : V)
  change ‖e‖ ≤ (M / α) * ‖u - (vh : V)‖
  rcases (norm_nonneg e).eq_or_lt with hz | he
  · rw [← hz]
    exact mul_nonneg hratio (norm_nonneg _)
  have orth : a e ((vh : V) - (uh : V)) = 0 :=
    galerkin_orthogonality hu huh (vh - uh)
  have energy : a e e = a e (u - (vh : V)) := calc
    a e e = a e ((u - (vh : V)) + ((vh : V) - (uh : V))) :=
      congrArg (a e) (sub_add_sub_cancel _ _ _).symm
    _ = _ := by rw [map_add, orth, add_zero]
  have bound : (α * ‖e‖) * ‖e‖ ≤ (M * ‖u - (vh : V)‖) * ‖e‖ := calc
    _ ≤ a e e := hcoer.2 e
    _ = _ := energy
    _ ≤ |a e (u - (vh : V))| := le_abs_self _
    _ ≤ M * ‖e‖ * ‖u - (vh : V)‖ := hbound.2 _ _
    _ = _ := mul_right_comm _ _ _
  rw [div_mul_eq_mul_div, le_div_iff₀ hcoer.1, mul_comm ‖e‖]
  exact (mul_le_mul_iff_left₀ he).mp bound

end FemLean.Core.Variational
