/-
Copyright (c) 2026 FormalCompMath contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: oopjoy
-/
import FemLean
import Mathlib.Analysis.Normed.Operator.Mul
import Mathlib.Tactic.NormNum

/-! This file is built in CI as a smoke test for the public library root. -/

open FemLean.Core.Variational

example : BoundedBy (ContinuousLinearMap.mul ℝ ℝ) 1 := by
  refine ⟨by norm_num, fun u v => ?_⟩
  change |u * v| ≤ 1 * ‖u‖ * ‖v‖
  simp [abs_mul, Real.norm_eq_abs]

example : CoerciveWith (ContinuousLinearMap.mul ℝ ℝ) 1 := by
  refine ⟨by norm_num, fun v => ?_⟩
  change 1 * ‖v‖ * ‖v‖ ≤ v * v
  rw [one_mul, Real.norm_eq_abs, ← pow_two, sq_abs, pow_two]

example : BoundedBy (0 : ℝ →L[ℝ] ℝ →L[ℝ] ℝ) 0 := by
  refine ⟨le_rfl, fun u v => ?_⟩
  simp

example : ¬ IsCoercive (0 : ℝ →L[ℝ] ℝ →L[ℝ] ℝ) := by
  intro h
  obtain ⟨α, hα, hdiag⟩ := (isCoercive_iff_exists_coerciveWith _).mp h
  have hone := hdiag 1
  simp at hone
  exact (not_le_of_gt hα) hone

example : CoerciveWith (0 : (⊥ : Submodule ℝ ℝ) →L[ℝ] (⊥ : Submodule ℝ ℝ) →L[ℝ] ℝ) 1 := by
  refine ⟨by norm_num, fun v => ?_⟩
  have hv : v = 0 := Subsingleton.elim _ _
  simp [hv]

-- On the whole space the two predicates give exactly the same equation.
example {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
    (a : V →L[ℝ] V →L[ℝ] ℝ) (ℓ : V →L[ℝ] ℝ) (u : V) :
    IsGalerkinSolution a ℓ ⊤ ⟨u, Submodule.mem_top⟩ ↔ IsWeakSolution a ℓ u := by
  constructor
  · intro h v
    exact h ⟨v, Submodule.mem_top⟩
  · intro h vh
    exact h (vh : V)

-- For a(x,y) = x₁ y₂ on the plane, reversing the slots changes the answer.
-- The load is the second coordinate and the discrete space is the horizontal axis.
example :
    let ℓ := ContinuousLinearMap.snd ℝ ℝ ℝ
    let a := (ContinuousLinearMap.fst ℝ ℝ ℝ).smulRight ℓ
    let u : ℝ × ℝ := (1, 1)
    let vh : ℓ.ker := ⟨(1, 0), rfl⟩
    a (u - ((0 : ℓ.ker) : ℝ × ℝ)) vh = 0 ∧ a vh (u - ((0 : ℓ.ker) : ℝ × ℝ)) = 1 := by
  intro ℓ a u vh
  have hu : IsWeakSolution a ℓ u := fun v => one_mul v.2
  have huh : IsGalerkinSolution a ℓ ℓ.ker 0 := by
    intro v
    change 0 * (v : ℝ × ℝ).2 = (v : ℝ × ℝ).2
    rw [zero_mul]
    exact v.property.symm
  refine ⟨galerkin_orthogonality hu huh vh, ?_⟩
  change 1 * (1 - 0 : ℝ) = 1
  norm_num

-- The zero form on a zero-dimensional ambient space admits M = 0 and α = 1.
example :
    let V := (⊥ : Submodule ℝ ℝ)
    let S : Submodule ℝ V := ⊤
    ‖(0 : V) - ((0 : S) : V)‖ ≤ (0 / 1 : ℝ) * (⨅ w : S, ‖(0 : V) - (w : V)‖) := by
  intro V S
  let a : V →L[ℝ] V →L[ℝ] ℝ := 0
  have hb : BoundedBy a 0 := ⟨le_rfl, fun x y => by simp [a]⟩
  have hc : CoerciveWith a 1 := by
    refine ⟨zero_lt_one, fun v => ?_⟩
    rw [Subsingleton.elim v 0]
    simp [a]
  exact cea (ℓ := 0) hb hc (fun _ => rfl) (fun _ => rfl)
