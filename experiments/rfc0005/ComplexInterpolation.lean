/-
Copyright (c) 2026 FormalCompMath contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: bombeuler
-/
import FemLean.Core.Variational
import Mathlib.Analysis.Complex.Hadamard
import Mathlib.Analysis.InnerProductSpace.ProdL2
import Mathlib.Analysis.InnerProductSpace.Projection.Submodule

/-!
# RFC 0005 statement prototype: complex interpolation and fractional Sobolev scales

This leaf module exercises the proposed interfaces for RFC 0005 (Issue #28):
1. Compatible complex Banach couples and Calderón's strip-based interpolation space `[X₀, X₁]_θ`.
2. Bounded-operator interpolation bounds, both into a fixed Banach target (via Mathlib's
   `Complex.HadamardThreeLines`) and between compatible couples (via entire exponential damping).
3. Canonical Hilbert complexification, avoiding norm-distortion constants when lifting real
   Hilbert spaces such as `H₀¹(Ω)` and `H²(Ω) ∩ H₀¹(Ω)`.
4. The bounded-domain Dirichlet interpolation scale `X_θ`, explicitly decoupled from any
   unproved equivalence with intrinsic fractional Sobolev norms.
5. Fractional-order `P₁` approximation and Galerkin energy-error estimates via
   `FemLean.Core.Variational.cea`, together with endpoint checks at `θ = 0` and `θ = 1`.

This file is a downstream experiment and must never be imported by library modules.
-/

open Complex Complex.HadamardThreeLines MeasureTheory Set
open scoped RealInnerProductSpace

noncomputable section

namespace FemLean.Experiments.RFC0005

/-! ## 1. Compatible complex Banach couples and Calderón interpolation -/

/-- A compatible couple of complex Banach spaces continuously and injectively embedded into
a common complex Banach ambient space `Ambient`.

In the general Calderón construction, `Ambient` models the sum space `X₀ + X₁`. For a nested
couple `X₁ ↪ X₀` (such as `H²(Ω) ∩ H₀¹(Ω) ↪ H₀¹(Ω)`), `Ambient` may be taken directly to be `X₀`
with `embed₀ = id`. -/
structure ComplexBanachCouple where
  X₀ : Type*
  X₁ : Type*
  Ambient : Type*
  [norm₀ : NormedAddCommGroup X₀]
  [space₀ : NormedSpace ℂ X₀]
  [complete₀ : CompleteSpace X₀]
  [norm₁ : NormedAddCommGroup X₁]
  [space₁ : NormedSpace ℂ X₁]
  [complete₁ : CompleteSpace X₁]
  [normA : NormedAddCommGroup Ambient]
  [spaceA : NormedSpace ℂ Ambient]
  [completeA : CompleteSpace Ambient]
  embed₀ : X₀ →L[ℂ] Ambient
  embed₁ : X₁ →L[ℂ] Ambient
  injective_embed₀ : Function.Injective embed₀
  injective_embed₁ : Function.Injective embed₁

attribute [instance] ComplexBanachCouple.norm₀ ComplexBanachCouple.space₀
  ComplexBanachCouple.complete₀ ComplexBanachCouple.norm₁ ComplexBanachCouple.space₁
  ComplexBanachCouple.complete₁ ComplexBanachCouple.normA ComplexBanachCouple.spaceA
  ComplexBanachCouple.completeA

/-- Admissible bounded strip functions `f : ℂ → C.Ambient` for Calderón's complex interpolation
method on the vertical strip `0 ≤ Re z ≤ 1`.

The boundary traces along `Re z = 0` and `Re z = 1` are carried explicitly in `X₀` and `X₁`
as continuous bounded maps, avoiding `Classical.choose` in boundary bounds. -/
structure CalderonStrip (C : ComplexBanachCouple) where
  toFun : ℂ → C.Ambient
  diffContOnCl : DiffContOnCl ℂ toFun (verticalStrip 0 1)
  bdd_strip : BddAbove ((norm ∘ toFun) '' verticalClosedStrip 0 1)
  trace₀ : ℝ → C.X₀
  continuous_trace₀ : Continuous trace₀
  bdd_trace₀ : BddAbove (Set.range fun t : ℝ => ‖trace₀ t‖)
  eq_trace₀ : ∀ t : ℝ, toFun (Complex.I * t) = C.embed₀ (trace₀ t)
  trace₁ : ℝ → C.X₁
  continuous_trace₁ : Continuous trace₁
  bdd_trace₁ : BddAbove (Set.range fun t : ℝ => ‖trace₁ t‖)
  eq_trace₁ : ∀ t : ℝ, toFun (1 + Complex.I * t) = C.embed₁ (trace₁ t)

namespace CalderonStrip

variable {C : ComplexBanachCouple}

/-- The Calderón strip norm `max (sup_t ‖f(it)‖_{X₀}) (sup_t ‖f(1+it)‖_{X₁})`. -/
def stripNorm (f : CalderonStrip C) : ℝ :=
  max (sSup (Set.range fun t : ℝ => ‖f.trace₀ t‖))
      (sSup (Set.range fun t : ℝ => ‖f.trace₁ t‖))

lemma norm_trace₀_le_stripNorm (f : CalderonStrip C) (t : ℝ) :
    ‖f.trace₀ t‖ ≤ f.stripNorm :=
  (le_csSup f.bdd_trace₀ ⟨t, rfl⟩).trans (le_max_left _ _)

lemma norm_trace₁_le_stripNorm (f : CalderonStrip C) (t : ℝ) :
    ‖f.trace₁ t‖ ≤ f.stripNorm :=
  (le_csSup f.bdd_trace₁ ⟨t, rfl⟩).trans (le_max_right _ _)

lemma stripNorm_nonneg (f : CalderonStrip C) : 0 ≤ f.stripNorm :=
  (norm_nonneg (f.trace₀ 0)).trans (f.norm_trace₀_le_stripNorm 0)

lemma stripNorm_le {f : CalderonStrip C} {M : ℝ}
    (h₀ : ∀ t : ℝ, ‖f.trace₀ t‖ ≤ M) (h₁ : ∀ t : ℝ, ‖f.trace₁ t‖ ≤ M) :
    f.stripNorm ≤ M := by
  refine max_le ?_ ?_
  · exact csSup_le (Set.range_nonempty _) (by rintro _ ⟨t, rfl⟩; exact h₀ t)
  · exact csSup_le (Set.range_nonempty _) (by rintro _ ⟨t, rfl⟩; exact h₁ t)

/-- A constant strip function representing an element of the intersection `X₀ ∩ X₁`. -/
def const (x₀ : C.X₀) (x₁ : C.X₁) (h : C.embed₀ x₀ = C.embed₁ x₁) : CalderonStrip C where
  toFun := fun _ => C.embed₀ x₀
  diffContOnCl := diffContOnCl_const
  bdd_strip := ⟨‖C.embed₀ x₀‖, by rintro _ ⟨z, _, rfl⟩; exact le_rfl⟩
  trace₀ := fun _ => x₀
  continuous_trace₀ := continuous_const
  bdd_trace₀ := ⟨‖x₀‖, by rintro _ ⟨_, rfl⟩; exact le_rfl⟩
  eq_trace₀ := fun _ => rfl
  trace₁ := fun _ => x₁
  continuous_trace₁ := continuous_const
  bdd_trace₁ := ⟨‖x₁‖, by rintro _ ⟨_, rfl⟩; exact le_rfl⟩
  eq_trace₁ := fun _ => h

lemma stripNorm_const (x₀ : C.X₀) (x₁ : C.X₁) (h : C.embed₀ x₀ = C.embed₁ x₁) :
    (const x₀ x₁ h).stripNorm = max ‖x₀‖ ‖x₁‖ := by
  apply le_antisymm
  · exact stripNorm_le (fun _ => le_max_left _ _) (fun _ => le_max_right _ _)
  · exact max_le (norm_trace₀_le_stripNorm (const x₀ x₁ h) 0)
      (norm_trace₁_le_stripNorm (const x₀ x₁ h) 0)

end CalderonStrip

/-- Membership in the Calderón complex interpolation space `[X₀, X₁]_θ`. -/
def MemComplexInterp (C : ComplexBanachCouple) (θ : ℝ) (x : C.Ambient) : Prop :=
  ∃ f : CalderonStrip C, f.toFun (θ : ℂ) = x

/-- Carrier subtype for the complex interpolation space `[X₀, X₁]_θ`. -/
abbrev ComplexInterp (C : ComplexBanachCouple) (θ : ℝ) :=
  {x : C.Ambient // MemComplexInterp C θ x}

/-- The Calderón infimum norm `‖x‖_{[X₀, X₁]_θ} = inf { ‖f‖_ℱ : f(θ) = x }`. -/
def complexInterpNorm (C : ComplexBanachCouple) (θ : ℝ) (x : C.Ambient) : ℝ :=
  sInf {r : ℝ | ∃ f : CalderonStrip C, f.toFun (θ : ℂ) = x ∧ r = f.stripNorm}

lemma complexInterpNorm_nonneg (C : ComplexBanachCouple) (θ : ℝ) (x : C.Ambient) :
    0 ≤ complexInterpNorm C θ x := by
  apply Real.sInf_nonneg
  rintro r ⟨f, -, rfl⟩
  exact f.stripNorm_nonneg

lemma complexInterpNorm_le_of_eq {C : ComplexBanachCouple} {θ : ℝ} {x : C.Ambient}
    (f : CalderonStrip C) (hf : f.toFun (θ : ℂ) = x) :
    complexInterpNorm C θ x ≤ f.stripNorm :=
  csInf_le ⟨0, by rintro _ ⟨g, -, rfl⟩; exact g.stripNorm_nonneg⟩ ⟨f, hf, rfl⟩

lemma memComplexInterp_of_inter {C : ComplexBanachCouple} (θ : ℝ)
    (x₀ : C.X₀) (x₁ : C.X₁) (h : C.embed₀ x₀ = C.embed₁ x₁) :
    MemComplexInterp C θ (C.embed₀ x₀) :=
  ⟨CalderonStrip.const x₀ x₁ h, rfl⟩

lemma complexInterpNorm_le_max_of_inter {C : ComplexBanachCouple} (θ : ℝ)
    (x₀ : C.X₀) (x₁ : C.X₁) (h : C.embed₀ x₀ = C.embed₁ x₁) :
    complexInterpNorm C θ (C.embed₀ x₀) ≤ max ‖x₀‖ ‖x₁‖ := by
  calc
    complexInterpNorm C θ (C.embed₀ x₀) ≤ (CalderonStrip.const x₀ x₁ h).stripNorm :=
      complexInterpNorm_le_of_eq _ rfl
    _ = max ‖x₀‖ ‖x₁‖ := CalderonStrip.stripNorm_const x₀ x₁ h

/-! ## 2. Bounded-operator interpolation theorems -/

/-- A compatible bounded linear operator between two complex Banach couples. -/
structure CompatibleOperator (C D : ComplexBanachCouple) where
  T₀ : C.X₀ →L[ℂ] D.X₀
  T₁ : C.X₁ →L[ℂ] D.X₁
  Tamb : C.Ambient →L[ℂ] D.Ambient
  comm₀ : ∀ x₀ : C.X₀, Tamb (C.embed₀ x₀) = D.embed₀ (T₀ x₀)
  comm₁ : ∀ x₁ : C.X₁, Tamb (C.embed₁ x₁) = D.embed₁ (T₁ x₁)

/-- **Operator interpolation into a fixed complex Banach target** via Mathlib's
`Complex.HadamardThreeLines.norm_le_interp_of_mem_verticalClosedStrip₀₁'`.

This handles `M₀ = 0`, `M₁ = 0`, and the endpoints `θ = 0`, `θ = 1` uniformly without division
or logarithms, and directly powers the finite element best-approximation interpolation step. -/
theorem norm_apply_le_interp_fixedTarget {C : ComplexBanachCouple}
    {Y : Type*} [NormedAddCommGroup Y] [NormedSpace ℂ Y]
    (T : C.Ambient →L[ℂ] Y) {M₀ M₁ θ : ℝ}
    (hM₀ : 0 ≤ M₀) (hM₁ : 0 ≤ M₁) (hθ : θ ∈ Set.Icc (0 : ℝ) 1)
    (h₀ : ∀ x₀ : C.X₀, ‖T (C.embed₀ x₀)‖ ≤ M₀ * ‖x₀‖)
    (h₁ : ∀ x₁ : C.X₁, ‖T (C.embed₁ x₁)‖ ≤ M₁ * ‖x₁‖)
    {x : C.Ambient} (hx : MemComplexInterp C θ x) :
    ‖T x‖ ≤ M₀ ^ (1 - θ) * M₁ ^ θ * complexInterpNorm C θ x := by
  have hfactor : 0 ≤ M₀ ^ (1 - θ) * M₁ ^ θ :=
    mul_nonneg (Real.rpow_nonneg hM₀ _) (Real.rpow_nonneg hM₁ _)
  have hnonempty :
      {r : ℝ | ∃ f : CalderonStrip C, f.toFun (θ : ℂ) = x ∧ r = f.stripNorm}.Nonempty := by
    rcases hx with ⟨f, hf⟩
    exact ⟨f.stripNorm, f, hf, rfl⟩
  have hpointwise : ∀ f : CalderonStrip C, f.toFun (θ : ℂ) = x →
      ‖T x‖ ≤ M₀ ^ (1 - θ) * M₁ ^ θ * f.stripNorm := by
    intro f hf
    let g : ℂ → Y := fun z => T (f.toFun z)
    have hgd : DiffContOnCl ℂ g (verticalStrip 0 1) :=
      T.differentiable.diffContOnCl.comp f.diffContOnCl (Set.mapsTo_univ _ _)
    have hgb : BddAbove ((norm ∘ g) '' verticalClosedStrip 0 1) := by
      rcases f.bdd_strip with ⟨B, hB⟩
      refine ⟨‖T‖ * max B 0, ?_⟩
      rintro _ ⟨z, hz, rfl⟩
      calc
        ‖T (f.toFun z)‖ ≤ ‖T‖ * ‖f.toFun z‖ := T.le_opNorm _
        _ ≤ ‖T‖ * max B 0 :=
          mul_le_mul_of_nonneg_left ((hB ⟨z, hz, rfl⟩).trans (le_max_left _ _)) (norm_nonneg _)
    have hga : ∀ z ∈ Complex.re ⁻¹' ({0} : Set ℝ), ‖g z‖ ≤ M₀ * f.stripNorm := by
      intro z hz
      have hre : z.re = 0 := hz
      have hz_eq : z = Complex.I * (z.im : ℂ) := by
        apply Complex.ext <;> simp [hre]
      calc
        ‖T (f.toFun z)‖ = ‖T (C.embed₀ (f.trace₀ z.im))‖ := by
          conv_lhs => rw [hz_eq, f.eq_trace₀]
        _ ≤ M₀ * ‖f.trace₀ z.im‖ := h₀ _
        _ ≤ M₀ * f.stripNorm := mul_le_mul_of_nonneg_left (f.norm_trace₀_le_stripNorm _) hM₀
    have hgb₁ : ∀ z ∈ Complex.re ⁻¹' ({1} : Set ℝ), ‖g z‖ ≤ M₁ * f.stripNorm := by
      intro z hz
      have hre : z.re = 1 := hz
      have hz_eq : z = 1 + Complex.I * (z.im : ℂ) := by
        apply Complex.ext <;> simp [hre]
      calc
        ‖T (f.toFun z)‖ = ‖T (C.embed₁ (f.trace₁ z.im))‖ := by
          conv_lhs => rw [hz_eq, f.eq_trace₁]
        _ ≤ M₁ * ‖f.trace₁ z.im‖ := h₁ _
        _ ≤ M₁ * f.stripNorm := mul_le_mul_of_nonneg_left (f.norm_trace₁_le_stripNorm _) hM₁
    have hzθ : (θ : ℂ) ∈ verticalClosedStrip 0 1 := by
      simpa [verticalClosedStrip] using hθ
    have hhad := norm_le_interp_of_mem_verticalClosedStrip₀₁' g hzθ hgd hgb hga hgb₁
    have hsimp : (M₀ * f.stripNorm) ^ (1 - θ) * (M₁ * f.stripNorm) ^ θ =
        M₀ ^ (1 - θ) * M₁ ^ θ * f.stripNorm := by
      rw [Real.mul_rpow hM₀ f.stripNorm_nonneg, Real.mul_rpow hM₁ f.stripNorm_nonneg]
      calc
        M₀ ^ (1 - θ) * f.stripNorm ^ (1 - θ) * (M₁ ^ θ * f.stripNorm ^ θ)
            = M₀ ^ (1 - θ) * M₁ ^ θ * (f.stripNorm ^ (1 - θ) * f.stripNorm ^ θ) := by ring
        _ = M₀ ^ (1 - θ) * M₁ ^ θ * f.stripNorm := by
          by_cases hfn : f.stripNorm = 0
          · rcases eq_or_lt_of_le hθ.1 with rfl | hθpos
            · simp [hfn]
            · rw [hfn, Real.zero_rpow hθpos.ne', mul_zero, mul_zero]
          · rw [← Real.rpow_add (lt_of_le_of_ne f.stripNorm_nonneg (Ne.symm hfn))]
            simp
    simpa [g, hf, Complex.ofReal_re, hsimp] using hhad
  by_cases hfac0 : M₀ ^ (1 - θ) * M₁ ^ θ = 0
  · rcases hx with ⟨f, hf⟩
    have h0 := hpointwise f hf
    rw [hfac0, zero_mul] at h0 ⊢
    exact h0
  · have hfacpos : 0 < M₀ ^ (1 - θ) * M₁ ^ θ := lt_of_le_of_ne hfactor (Ne.symm hfac0)
    rw [mul_comm, ← div_le_iff₀ hfacpos]
    apply le_csInf hnonempty
    rintro r ⟨f, hf, rfl⟩
    rw [div_le_iff₀ hfacpos, mul_comm]
    exact hpointwise f hf

/-- **Calderón complex operator interpolation** between two compatible Banach couples
(positive endpoint bounds `M₀, M₁ > 0`).

Proved directly by rescaling any admissible strip function `f ∈ ℱ(C)` with the entire weight
`z ↦ exp ((z - θ) * (log M₀ - log M₁))`, giving the exact constant `1` in
`‖T x‖_{[Y₀, Y₁]_θ} ≤ M₀ ^ (1 - θ) * M₁ ^ θ * ‖x‖_{[X₀, X₁]_θ}`. -/
theorem calderon_operator_interpolation {C D : ComplexBanachCouple}
    (T : CompatibleOperator C D) {M₀ M₁ θ : ℝ}
    (hM₀ : 0 < M₀) (hM₁ : 0 < M₁) (_hθ : θ ∈ Set.Icc (0 : ℝ) 1)
    (h₀ : ‖T.T₀‖ ≤ M₀) (h₁ : ‖T.T₁‖ ≤ M₁)
    {x : C.Ambient} (hx : MemComplexInterp C θ x) :
    MemComplexInterp D θ (T.Tamb x) ∧
      complexInterpNorm D θ (T.Tamb x) ≤
        M₀ ^ (1 - θ) * M₁ ^ θ * complexInterpNorm C θ x := by
  let α : ℝ := Real.log M₀ - Real.log M₁
  let φ : ℂ → ℂ := fun z => Complex.exp ((z - (θ : ℂ)) * (α : ℂ))
  have hφ_diff : Differentiable ℂ φ :=
    ((differentiable_id.sub (differentiable_const _)).mul (differentiable_const _)).cexp
  have hφ_norm : ∀ z : ℂ, ‖φ z‖ = Real.exp ((z.re - θ) * α) := by
    intro z
    rw [Complex.norm_exp]
    congr 1
    simp [Complex.mul_re, Complex.sub_re, Complex.ofReal_re, Complex.ofReal_im]
  have hφ_zero : ∀ t : ℝ, ‖φ (Complex.I * t)‖ * M₀ = M₀ ^ (1 - θ) * M₁ ^ θ := by
    intro t
    rw [hφ_norm]
    have hre : (Complex.I * (t : ℂ)).re = 0 := by simp
    rw [hre, zero_sub, Real.rpow_def_of_pos hM₀, Real.rpow_def_of_pos hM₁]
    conv_lhs => rw [← Real.exp_log hM₀]
    rw [← Real.exp_add, ← Real.exp_add]
    congr 1
    simp only [α]
    ring
  have hφ_one : ∀ t : ℝ, ‖φ (1 + Complex.I * t)‖ * M₁ = M₀ ^ (1 - θ) * M₁ ^ θ := by
    intro t
    rw [hφ_norm]
    have hre : (1 + Complex.I * (t : ℂ)).re = 1 := by simp
    rw [hre, Real.rpow_def_of_pos hM₀, Real.rpow_def_of_pos hM₁]
    conv_lhs => rw [← Real.exp_log hM₁]
    rw [← Real.exp_add, ← Real.exp_add]
    congr 1
    simp only [α]
    ring
  have hpush : ∀ f : CalderonStrip C,
      ∃ g : CalderonStrip D, g.toFun (θ : ℂ) = T.Tamb (f.toFun (θ : ℂ)) ∧
        g.stripNorm ≤ M₀ ^ (1 - θ) * M₁ ^ θ * f.stripNorm := by
    intro f
    have hφ_bdd_strip : ∃ K : ℝ, 0 ≤ K ∧ ∀ z ∈ verticalClosedStrip 0 1, ‖φ z‖ ≤ K := by
      refine ⟨max (Real.exp ((0 - θ) * α)) (Real.exp ((1 - θ) * α)),
        (Real.exp_nonneg _).trans (le_max_left _ _), ?_⟩
      intro z hz
      rw [hφ_norm]
      rcases le_total 0 α with hα | hα
      · exact (Real.exp_le_exp.mpr
          (mul_le_mul_of_nonneg_right (sub_le_sub_right hz.2 θ) hα)).trans (le_max_right _ _)
      · exact (Real.exp_le_exp.mpr
          (mul_le_mul_of_nonpos_right (sub_le_sub_right hz.1 θ) hα)).trans (le_max_left _ _)
    let g : CalderonStrip D := {
      toFun := fun z => φ z • T.Tamb (f.toFun z)
      diffContOnCl :=
        hφ_diff.diffContOnCl.smul
          (T.Tamb.differentiable.diffContOnCl.comp f.diffContOnCl (Set.mapsTo_univ _ _))
      bdd_strip := by
        rcases hφ_bdd_strip with ⟨K, hK, hφK⟩
        rcases f.bdd_strip with ⟨B, hB⟩
        refine ⟨K * (‖T.Tamb‖ * max B 0), ?_⟩
        rintro _ ⟨z, hz, rfl⟩
        change ‖φ z • T.Tamb (f.toFun z)‖ ≤ K * (‖T.Tamb‖ * max B 0)
        rw [norm_smul]
        refine mul_le_mul (hφK z hz) ?_ (norm_nonneg _) hK
        calc
          ‖T.Tamb (f.toFun z)‖ ≤ ‖T.Tamb‖ * ‖f.toFun z‖ := T.Tamb.le_opNorm _
          _ ≤ ‖T.Tamb‖ * max B 0 :=
            mul_le_mul_of_nonneg_left ((hB ⟨z, hz, rfl⟩).trans (le_max_left _ _)) (norm_nonneg _)
      trace₀ := fun t => φ (Complex.I * t) • T.T₀ (f.trace₀ t)
      continuous_trace₀ :=
        (hφ_diff.continuous.comp (continuous_const.mul Complex.continuous_ofReal)).smul
          (T.T₀.continuous.comp f.continuous_trace₀)
      bdd_trace₀ := by
        refine ⟨M₀ ^ (1 - θ) * M₁ ^ θ * f.stripNorm, ?_⟩
        rintro _ ⟨t, rfl⟩
        calc
          ‖φ (Complex.I * t) • T.T₀ (f.trace₀ t)‖
              = ‖φ (Complex.I * t)‖ * ‖T.T₀ (f.trace₀ t)‖ := norm_smul _ _
          _ ≤ ‖φ (Complex.I * t)‖ * (M₀ * ‖f.trace₀ t‖) := by
            gcongr
            exact (T.T₀.le_opNorm _).trans (mul_le_mul_of_nonneg_right h₀ (norm_nonneg _))
          _ = (‖φ (Complex.I * t)‖ * M₀) * ‖f.trace₀ t‖ := by ring
          _ = M₀ ^ (1 - θ) * M₁ ^ θ * ‖f.trace₀ t‖ := by rw [hφ_zero t]
          _ ≤ M₀ ^ (1 - θ) * M₁ ^ θ * f.stripNorm := by
            gcongr
            exact f.norm_trace₀_le_stripNorm t
      eq_trace₀ := fun t => by
        simp [f.eq_trace₀, T.comm₀, map_smul]
      trace₁ := fun t => φ (1 + Complex.I * t) • T.T₁ (f.trace₁ t)
      continuous_trace₁ :=
        (hφ_diff.continuous.comp
          (continuous_const.add (continuous_const.mul Complex.continuous_ofReal))).smul
          (T.T₁.continuous.comp f.continuous_trace₁)
      bdd_trace₁ := by
        refine ⟨M₀ ^ (1 - θ) * M₁ ^ θ * f.stripNorm, ?_⟩
        rintro _ ⟨t, rfl⟩
        calc
          ‖φ (1 + Complex.I * t) • T.T₁ (f.trace₁ t)‖
              = ‖φ (1 + Complex.I * t)‖ * ‖T.T₁ (f.trace₁ t)‖ := norm_smul _ _
          _ ≤ ‖φ (1 + Complex.I * t)‖ * (M₁ * ‖f.trace₁ t‖) := by
            gcongr
            exact (T.T₁.le_opNorm _).trans (mul_le_mul_of_nonneg_right h₁ (norm_nonneg _))
          _ = (‖φ (1 + Complex.I * t)‖ * M₁) * ‖f.trace₁ t‖ := by ring
          _ = M₀ ^ (1 - θ) * M₁ ^ θ * ‖f.trace₁ t‖ := by rw [hφ_one t]
          _ ≤ M₀ ^ (1 - θ) * M₁ ^ θ * f.stripNorm := by
            gcongr
            exact f.norm_trace₁_le_stripNorm t
      eq_trace₁ := fun t => by
        simp [f.eq_trace₁, T.comm₁, map_smul]
    }
    refine ⟨g, ?_, ?_⟩
    · change φ (θ : ℂ) • T.Tamb (f.toFun (θ : ℂ)) = T.Tamb (f.toFun (θ : ℂ))
      simp [φ]
    · refine CalderonStrip.stripNorm_le ?_ ?_
      · intro t
        calc
          ‖φ (Complex.I * t) • T.T₀ (f.trace₀ t)‖
              = ‖φ (Complex.I * t)‖ * ‖T.T₀ (f.trace₀ t)‖ := norm_smul _ _
          _ ≤ ‖φ (Complex.I * t)‖ * (M₀ * ‖f.trace₀ t‖) := by
            gcongr
            exact (T.T₀.le_opNorm _).trans (mul_le_mul_of_nonneg_right h₀ (norm_nonneg _))
          _ = (‖φ (Complex.I * t)‖ * M₀) * ‖f.trace₀ t‖ := by ring
          _ = M₀ ^ (1 - θ) * M₁ ^ θ * ‖f.trace₀ t‖ := by rw [hφ_zero t]
          _ ≤ M₀ ^ (1 - θ) * M₁ ^ θ * f.stripNorm := by
            gcongr
            exact f.norm_trace₀_le_stripNorm t
      · intro t
        calc
          ‖φ (1 + Complex.I * t) • T.T₁ (f.trace₁ t)‖
              = ‖φ (1 + Complex.I * t)‖ * ‖T.T₁ (f.trace₁ t)‖ := norm_smul _ _
          _ ≤ ‖φ (1 + Complex.I * t)‖ * (M₁ * ‖f.trace₁ t‖) := by
            gcongr
            exact (T.T₁.le_opNorm _).trans (mul_le_mul_of_nonneg_right h₁ (norm_nonneg _))
          _ = (‖φ (1 + Complex.I * t)‖ * M₁) * ‖f.trace₁ t‖ := by ring
          _ = M₀ ^ (1 - θ) * M₁ ^ θ * ‖f.trace₁ t‖ := by rw [hφ_one t]
          _ ≤ M₀ ^ (1 - θ) * M₁ ^ θ * f.stripNorm := by
            gcongr
            exact f.norm_trace₁_le_stripNorm t
  have hmem : MemComplexInterp D θ (T.Tamb x) := by
    rcases hx with ⟨f, hf⟩
    rcases hpush f with ⟨g, hg, -⟩
    exact ⟨g, by rw [hg, hf]⟩
  refine ⟨hmem, ?_⟩
  have hfacpos : 0 < M₀ ^ (1 - θ) * M₁ ^ θ :=
    mul_pos (Real.rpow_pos_of_pos hM₀ _) (Real.rpow_pos_of_pos hM₁ _)
  have hnonempty :
      {r : ℝ | ∃ f : CalderonStrip C, f.toFun (θ : ℂ) = x ∧ r = f.stripNorm}.Nonempty := by
    rcases hx with ⟨f, hf⟩
    exact ⟨f.stripNorm, f, hf, rfl⟩
  rw [mul_comm, ← div_le_iff₀ hfacpos]
  apply le_csInf hnonempty
  rintro r ⟨f, hf, rfl⟩
  rw [div_le_iff₀ hfacpos, mul_comm]
  rcases hpush f with ⟨g, hg, hgnorm⟩
  exact (complexInterpNorm_le_of_eq g (by rw [hg, hf])).trans hgnorm

/-- Target statement for complex reiteration (Bergh–Löfström Theorem 4.6.1): recorded as an
explicit follow-up proposition rather than assumed in downstream estimates. -/
def ReiterationProperty (C Cmid : ComplexBanachCouple) (θ₀ θ₁ η : ℝ)
    (e : C.Ambient ≃L[ℂ] Cmid.Ambient) : Prop :=
  ∃ (c₁ c₂ : ℝ), 0 < c₁ ∧ 0 < c₂ ∧
    ∀ x : C.Ambient,
      (MemComplexInterp C ((1 - η) * θ₀ + η * θ₁) x ↔ MemComplexInterp Cmid η (e x)) ∧
      c₁ * complexInterpNorm C ((1 - η) * θ₀ + η * θ₁) x ≤
        complexInterpNorm Cmid η (e x) ∧
      complexInterpNorm Cmid η (e x) ≤
        c₂ * complexInterpNorm C ((1 - η) * θ₀ + η * θ₁) x

/-! ## 3. Canonical Hilbert complexification -/

/-- Canonical complexification `H ⊕ i H` of a real Hilbert space, carrying the Euclidean `L²`
product norm `‖(u, v)‖² = ‖u‖² + ‖v‖²`.

For a real Hilbert space, this norm makes `HilbertComplexification H` a complex Banach space
with exact `‖z • p‖ = ‖z‖ * ‖p‖`, embeds `H` isometrically, and preserves operator norms of
real bounded linear maps without any distortion factor. -/
def HilbertComplexification (H : Type*) : Type _ :=
  WithLp 2 (H × H)

namespace HilbertComplexification

variable {H K : Type*}

def re (x : HilbertComplexification H) : H := (WithLp.ofLp x).1
def im (x : HilbertComplexification H) : H := (WithLp.ofLp x).2
def mk' (u v : H) : HilbertComplexification H := WithLp.toLp 2 (u, v)

@[ext]
lemma ext {x y : HilbertComplexification H} (hre : x.re = y.re) (him : x.im = y.im) :
    x = y := by
  apply WithLp.ofLp_injective 2
  exact Prod.ext hre him

@[simp] lemma re_mk' (u v : H) : (mk' u v).re = u := rfl
@[simp] lemma im_mk' (u v : H) : (mk' u v).im = v := rfl

section NormedGroup

variable [NormedAddCommGroup H]

instance : NormedAddCommGroup (HilbertComplexification H) :=
  inferInstanceAs (NormedAddCommGroup (WithLp 2 (H × H)))

instance [CompleteSpace H] : CompleteSpace (HilbertComplexification H) :=
  inferInstanceAs (CompleteSpace (WithLp 2 (H × H)))

lemma norm_sq_eq (x : HilbertComplexification H) :
    ‖x‖ ^ 2 = ‖x.re‖ ^ 2 + ‖x.im‖ ^ 2 :=
  WithLp.prod_norm_sq_eq_of_L2 (x : WithLp 2 (H × H))

@[simp] lemma re_add (x y : HilbertComplexification H) : (x + y).re = x.re + y.re := rfl
@[simp] lemma im_add (x y : HilbertComplexification H) : (x + y).im = x.im + y.im := rfl
@[simp] lemma re_zero : (0 : HilbertComplexification H).re = 0 := rfl
@[simp] lemma im_zero : (0 : HilbertComplexification H).im = 0 := rfl

/-- Isometric real embedding `u ↦ u + 0·i` into `HilbertComplexification H`. -/
def ofReal (u : H) : HilbertComplexification H := mk' u 0

@[simp] lemma norm_ofReal (u : H) : ‖ofReal u‖ = ‖u‖ := by
  have hsq : ‖ofReal u‖ ^ 2 = ‖u‖ ^ 2 := by
    rw [norm_sq_eq]
    simp [ofReal]
  nlinarith [norm_nonneg (ofReal u), norm_nonneg u]

lemma ofReal_injective : Function.Injective (ofReal (H := H)) := by
  intro u v h
  exact congrArg re h

end NormedGroup

section Hilbert

variable [NormedAddCommGroup H] [InnerProductSpace ℝ H]
variable [NormedAddCommGroup K] [InnerProductSpace ℝ K]

instance : SMul ℂ (HilbertComplexification H) where
  smul z x := mk' (z.re • x.re - z.im • x.im) (z.im • x.re + z.re • x.im)

@[simp] lemma re_smul (z : ℂ) (x : HilbertComplexification H) :
    (z • x).re = z.re • x.re - z.im • x.im := rfl

@[simp] lemma im_smul (z : ℂ) (x : HilbertComplexification H) :
    (z • x).im = z.im • x.re + z.re • x.im := rfl

instance : Module ℂ (HilbertComplexification H) where
  one_smul x := by ext <;> simp
  mul_smul z w x := by
    ext
    · simp only [re_smul, im_smul, Complex.mul_re, Complex.mul_im, sub_smul, add_smul,
        smul_sub, smul_add, mul_smul]
      abel
    · simp only [re_smul, im_smul, Complex.mul_re, Complex.mul_im, sub_smul, add_smul,
        smul_sub, smul_add, mul_smul]
      abel
  smul_zero z := by ext <;> simp
  smul_add z x y := by
    ext
    · simp only [re_smul, re_add, im_add, smul_add]
      abel
    · simp only [im_smul, re_add, im_add, smul_add]
      abel
  add_smul z w x := by
    ext
    · simp only [re_smul, re_add, Complex.add_re, Complex.add_im, add_smul]
      abel
    · simp only [im_smul, im_add, Complex.add_re, Complex.add_im, add_smul]
      abel
  zero_smul x := by ext <;> simp

instance : NormedSpace ℂ (HilbertComplexification H) where
  norm_smul_le z x := by
    have hsq : ‖z • x‖ ^ 2 = (‖z‖ * ‖x‖) ^ 2 := by
      rw [norm_sq_eq, mul_pow, norm_sq_eq, re_smul, im_smul,
        norm_sub_sq_real, norm_add_sq_real, Complex.sq_norm, Complex.normSq_apply]
      simp only [norm_smul, Real.norm_eq_abs, inner_smul_left, inner_smul_right,
        RCLike.conj_to_real, mul_pow, sq_abs]
      ring
    nlinarith [norm_nonneg (z • x), mul_nonneg (norm_nonneg z) (norm_nonneg x)]

/-- Complexification of a real bounded linear map between real Hilbert spaces.
Preserves the exact operator norm `‖complexifyCLM T‖ ≤ ‖T‖`. -/
def complexifyCLM (T : H →L[ℝ] K) :
    HilbertComplexification H →L[ℂ] HilbertComplexification K :=
  LinearMap.mkContinuous
    { toFun := fun x => mk' (T x.re) (T x.im)
      map_add' := fun x y => by ext <;> simp [map_add]
      map_smul' := fun z x => by
        ext <;> simp [map_sub, map_add, map_smul] }
    ‖T‖
    (fun x => by
      change ‖mk' (T x.re) (T x.im)‖ ≤ ‖T‖ * ‖x‖
      have hsq : ‖mk' (T x.re) (T x.im)‖ ^ 2 ≤ (‖T‖ * ‖x‖) ^ 2 := by
        rw [norm_sq_eq, mul_pow, norm_sq_eq]
        simp only [re_mk', im_mk']
        have h1 : ‖T x.re‖ ^ 2 ≤ (‖T‖ * ‖x.re‖) ^ 2 :=
          pow_le_pow_left₀ (norm_nonneg _) (T.le_opNorm _) 2
        have h2 : ‖T x.im‖ ^ 2 ≤ (‖T‖ * ‖x.im‖) ^ 2 :=
          pow_le_pow_left₀ (norm_nonneg _) (T.le_opNorm _) 2
        nlinarith
      nlinarith [norm_nonneg (mk' (T x.re) (T x.im)),
        mul_nonneg (norm_nonneg T) (norm_nonneg x)])

@[simp] lemma complexifyCLM_ofReal (T : H →L[ℝ] K) (u : H) :
    complexifyCLM T (ofReal u) = ofReal (T u) := by
  ext <;> simp [complexifyCLM, ofReal]

lemma norm_complexifyCLM_le (T : H →L[ℝ] K) (x : HilbertComplexification H) :
    ‖complexifyCLM T x‖ ≤ ‖T‖ * ‖x‖ := by
  have hsq : ‖complexifyCLM T x‖ ^ 2 ≤ (‖T‖ * ‖x‖) ^ 2 := by
    change ‖mk' (T x.re) (T x.im)‖ ^ 2 ≤ (‖T‖ * ‖x‖) ^ 2
    rw [norm_sq_eq, mul_pow, norm_sq_eq]
    simp only [re_mk', im_mk']
    have h1 : ‖T x.re‖ ^ 2 ≤ (‖T‖ * ‖x.re‖) ^ 2 :=
      pow_le_pow_left₀ (norm_nonneg _) (T.le_opNorm _) 2
    have h2 : ‖T x.im‖ ^ 2 ≤ (‖T‖ * ‖x.im‖) ^ 2 :=
      pow_le_pow_left₀ (norm_nonneg _) (T.le_opNorm _) 2
    nlinarith
  nlinarith [norm_nonneg (complexifyCLM T x), mul_nonneg (norm_nonneg T) (norm_nonneg x)]

lemma complexifyCLM_injective {T : H →L[ℝ] K} (hT : Function.Injective T) :
    Function.Injective (complexifyCLM T) := by
  intro x y h
  ext
  · exact hT (congrArg re h)
  · exact hT (congrArg im h)

end Hilbert

end HilbertComplexification

/-! ## 4. Bounded-domain Dirichlet interpolation scale `X_θ` -/

/-- Endpoint Hilbert spaces for the Dirichlet interpolation scale between `X₀ = H₀¹(Ω)` and
`X₁ = H²(Ω) ∩ H₀¹(Ω)`.

Once RFC 0001 / PR #27 lands, `H01` instantiates directly to `EllipticPdes.H1Graph.H01 volume Ω`
and `H2H01` instantiates to the bounded-domain `H²(Ω) ∩ H₀¹(Ω)` graph Hilbert space. -/
structure DirichletEndpointCouple where
  H01 : Type*
  H2H01 : Type*
  [norm₀ : NormedAddCommGroup H01]
  [inner₀ : InnerProductSpace ℝ H01]
  [complete₀ : CompleteSpace H01]
  [norm₁ : NormedAddCommGroup H2H01]
  [inner₁ : InnerProductSpace ℝ H2H01]
  [complete₁ : CompleteSpace H2H01]
  incl : H2H01 →L[ℝ] H01
  injective_incl : Function.Injective incl

attribute [instance] DirichletEndpointCouple.norm₀ DirichletEndpointCouple.inner₀
  DirichletEndpointCouple.complete₀ DirichletEndpointCouple.norm₁ DirichletEndpointCouple.inner₁
  DirichletEndpointCouple.complete₁

namespace DirichletEndpointCouple

/-- Nested complex Banach couple obtained by canonically complexifying `H²(Ω) ∩ H₀¹(Ω) ↪ H₀¹(Ω)`. -/
def toComplexCouple (E : DirichletEndpointCouple) : ComplexBanachCouple where
  X₀ := HilbertComplexification E.H01
  X₁ := HilbertComplexification E.H2H01
  Ambient := HilbertComplexification E.H01
  embed₀ := ContinuousLinearMap.id ℂ _
  embed₁ := HilbertComplexification.complexifyCLM E.incl
  injective_embed₀ := Function.injective_id
  injective_embed₁ := HilbertComplexification.complexifyCLM_injective E.injective_incl

/-- Membership of a real `H₀¹(Ω)` function in the Dirichlet interpolation scale `X_θ`.
Convention: `θ = 0` corresponds to `H₀¹(Ω)` and `θ = 1` corresponds to `H²(Ω) ∩ H₀¹(Ω)`. -/
def MemScale (E : DirichletEndpointCouple) (θ : ℝ) (u : E.H01) : Prop :=
  MemComplexInterp E.toComplexCouple θ (HilbertComplexification.ofReal u)

/-- The interpolation norm `‖u‖_{X_θ}` defined strictly via Calderón interpolation of the
complexified Dirichlet couple `(H₀¹(Ω)_ℂ, (H²(Ω) ∩ H₀¹(Ω))_ℂ)`. -/
def scaleNorm (E : DirichletEndpointCouple) (θ : ℝ) (u : E.H01) : ℝ :=
  complexInterpNorm E.toComplexCouple θ (HilbertComplexification.ofReal u)

/-- Separate equivalence statement between the interpolation norm `X_θ` and an external intrinsic
fractional Sobolev norm `N_θ` (e.g., Slobodeckij or Bessel restriction). Downstream error theorems
do **not** assume this equivalence; any identification must be proved separately. -/
def IntrinsicNormEquivalence (E : DirichletEndpointCouple) (θ : ℝ)
    (N : E.H01 → ℝ) : Prop :=
  ∃ c₁ c₂ : ℝ, 0 < c₁ ∧ 0 < c₂ ∧
    ∀ u : E.H01, E.MemScale θ u → c₁ * E.scaleNorm θ u ≤ N u ∧ N u ≤ c₂ * E.scaleNorm θ u

/-- Real bounded-operator interpolation on the Dirichlet scale into a real Hilbert target `Y`. -/
theorem real_op_interpolation (E : DirichletEndpointCouple)
    {Y : Type*} [NormedAddCommGroup Y] [InnerProductSpace ℝ Y]
    (T : E.H01 →L[ℝ] Y) {M₀ M₁ θ : ℝ}
    (hM₀ : 0 ≤ M₀) (hM₁ : 0 ≤ M₁) (hθ : θ ∈ Set.Icc (0 : ℝ) 1)
    (h₀ : ∀ u : E.H01, ‖T u‖ ≤ M₀ * ‖u‖)
    (h₁ : ∀ u : E.H2H01, ‖T (E.incl u)‖ ≤ M₁ * ‖u‖)
    {u : E.H01} (hu : E.MemScale θ u) :
    ‖T u‖ ≤ M₀ ^ (1 - θ) * M₁ ^ θ * E.scaleNorm θ u := by
  have hT₀ : ∀ x : HilbertComplexification E.H01,
      ‖HilbertComplexification.complexifyCLM T x‖ ≤ M₀ * ‖x‖ := by
    intro x
    have hsq : ‖HilbertComplexification.complexifyCLM T x‖ ^ 2 ≤ (M₀ * ‖x‖) ^ 2 := by
      change ‖HilbertComplexification.mk' (T x.re) (T x.im)‖ ^ 2 ≤ (M₀ * ‖x‖) ^ 2
      rw [HilbertComplexification.norm_sq_eq, mul_pow, HilbertComplexification.norm_sq_eq]
      simp only [HilbertComplexification.re_mk', HilbertComplexification.im_mk']
      have ha : ‖T x.re‖ ^ 2 ≤ (M₀ * ‖x.re‖) ^ 2 :=
        pow_le_pow_left₀ (norm_nonneg _) (h₀ x.re) 2
      have hb : ‖T x.im‖ ^ 2 ≤ (M₀ * ‖x.im‖) ^ 2 :=
        pow_le_pow_left₀ (norm_nonneg _) (h₀ x.im) 2
      nlinarith
    nlinarith [norm_nonneg (HilbertComplexification.complexifyCLM T x),
      mul_nonneg hM₀ (norm_nonneg x)]
  have hT₁ : ∀ x : HilbertComplexification E.H2H01,
      ‖HilbertComplexification.complexifyCLM T
        (HilbertComplexification.complexifyCLM E.incl x)‖ ≤ M₁ * ‖x‖ := by
    intro x
    have hsq :
        ‖HilbertComplexification.complexifyCLM T
          (HilbertComplexification.complexifyCLM E.incl x)‖ ^ 2 ≤ (M₁ * ‖x‖) ^ 2 := by
      change ‖HilbertComplexification.mk' (T (E.incl x.re)) (T (E.incl x.im))‖ ^ 2 ≤
        (M₁ * ‖x‖) ^ 2
      rw [HilbertComplexification.norm_sq_eq, mul_pow, HilbertComplexification.norm_sq_eq]
      simp only [HilbertComplexification.re_mk', HilbertComplexification.im_mk']
      have ha : ‖T (E.incl x.re)‖ ^ 2 ≤ (M₁ * ‖x.re‖) ^ 2 :=
        pow_le_pow_left₀ (norm_nonneg _) (h₁ x.re) 2
      have hb : ‖T (E.incl x.im)‖ ^ 2 ≤ (M₁ * ‖x.im‖) ^ 2 :=
        pow_le_pow_left₀ (norm_nonneg _) (h₁ x.im) 2
      nlinarith
    nlinarith [norm_nonneg (HilbertComplexification.complexifyCLM T
      (HilbertComplexification.complexifyCLM E.incl x)), mul_nonneg hM₁ (norm_nonneg x)]
  have hbound :=
    norm_apply_le_interp_fixedTarget (C := E.toComplexCouple)
      (HilbertComplexification.complexifyCLM T) hM₀ hM₁ hθ hT₀ hT₁ hu
  calc
    ‖T u‖ = ‖HilbertComplexification.ofReal (T u)‖ := (HilbertComplexification.norm_ofReal _).symm
    _ = ‖HilbertComplexification.complexifyCLM T (HilbertComplexification.ofReal u)‖ := by
      rw [HilbertComplexification.complexifyCLM_ofReal]
    _ ≤ M₀ ^ (1 - θ) * M₁ ^ θ * E.scaleNorm θ u := hbound

end DirichletEndpointCouple

/-! ## 5. Fractional `P₁` approximation, Galerkin energy error, and endpoint checks -/

/-- A fixed-domain family of conforming closed discrete subspaces `V_h ⊆ H₀¹(Ω)` (e.g., `P₁`
spaces on a shape-regular triangulation family with common shape bound `κ`). -/
structure ConformingDiscreteFamily (E : DirichletEndpointCouple) where
  Mesh : Type*
  h : Mesh → ℝ
  h_pos : ∀ T, 0 < h T
  Vh : Mesh → Submodule ℝ E.H01
  [complete_Vh : ∀ T, CompleteSpace (Vh T)]

attribute [instance] ConformingDiscreteFamily.complete_Vh

/-- **Fractional best-approximation estimate from the M4 `H²` endpoint bound alone**.

Using the `H₀¹`-orthogonal projection `P_h : H₀¹(Ω) → V_h`, the error operator `E_h = id - P_h`
automatically has endpoint norm `≤ 1` on `H₀¹(Ω)` and norm `≤ C₁ h` on `H²(Ω) ∩ H₀¹(Ω)` from
M4's nodal `P₁` approximation bound. Complex operator interpolation therefore yields the
fractional `O(h^θ)` approximation estimate without needing a separate quasi-interpolant. -/
theorem fractional_best_approx_of_endpoint_bound {E : DirichletEndpointCouple}
    (F : ConformingDiscreteFamily E) {C₁ θ : ℝ}
    (hC₁ : 0 ≤ C₁) (hθ : θ ∈ Set.Icc (0 : ℝ) 1)
    (hM4 : ∀ (T : F.Mesh) (u : E.H2H01),
      ∃ vh : F.Vh T, ‖E.incl u - (vh : E.H01)‖ ≤ C₁ * F.h T * ‖u‖)
    (T : F.Mesh) {u : E.H01} (hu : E.MemScale θ u) :
    (⨅ vh : F.Vh T, ‖u - (vh : E.H01)‖) ≤
      C₁ ^ θ * (F.h T) ^ θ * E.scaleNorm θ u := by
  let errOp : E.H01 →L[ℝ] E.H01 :=
    ContinuousLinearMap.id ℝ E.H01 - (F.Vh T).starProjection
  have herr₀ : ∀ v : E.H01, ‖errOp v‖ ≤ 1 * ‖v‖ := by
    intro v
    rw [one_mul]
    change ‖v - (F.Vh T).starProjection v‖ ≤ ‖v‖
    rw [(F.Vh T).starProjection_minimal v]
    have h0 := ciInf_le (f := fun vh : F.Vh T => ‖v - (vh : E.H01)‖)
      ⟨0, Set.forall_mem_range.2 fun _ => norm_nonneg _⟩ (0 : F.Vh T)
    simpa using h0
  have herr₁ : ∀ v : E.H2H01, ‖errOp (E.incl v)‖ ≤ (C₁ * F.h T) * ‖v‖ := by
    intro v
    rcases hM4 T v with ⟨vh, hvh⟩
    change ‖E.incl v - (F.Vh T).starProjection (E.incl v)‖ ≤ (C₁ * F.h T) * ‖v‖
    rw [(F.Vh T).starProjection_minimal (E.incl v)]
    exact (ciInf_le ⟨0, Set.forall_mem_range.2 fun _ => norm_nonneg _⟩ vh).trans hvh
  have hinterp := E.real_op_interpolation errOp zero_le_one
    (mul_nonneg hC₁ (F.h_pos T).le) hθ herr₀ herr₁ hu
  have hinf : (⨅ vh : F.Vh T, ‖u - (vh : E.H01)‖) = ‖errOp u‖ :=
    ((F.Vh T).starProjection_minimal u).symm
  calc
    (⨅ vh : F.Vh T, ‖u - (vh : E.H01)‖) = ‖errOp u‖ := hinf
    _ ≤ 1 ^ (1 - θ) * (C₁ * F.h T) ^ θ * E.scaleNorm θ u := hinterp
    _ = C₁ ^ θ * (F.h T) ^ θ * E.scaleNorm θ u := by
      rw [Real.one_rpow, one_mul, Real.mul_rpow hC₁ (F.h_pos T).le]

/-- **Fractional Galerkin energy-error theorem** combining `FemLean.Core.Variational.cea` with
complex interpolation of the orthogonal projection error operator.

Notice that the resulting constant `(M / α) * C₁ ^ θ` tracks its exact dependence on the
ellipticity constants `(M, α)`, the M4 constant `C₁(Ω, κ)`, and `θ` (and is even bounded
uniformly in `θ ∈ [0, 1]` by `(M / α) * max 1 C₁`). -/
theorem fractional_galerkin_energy_error {E : DirichletEndpointCouple}
    (F : ConformingDiscreteFamily E)
    {a : E.H01 →L[ℝ] E.H01 →L[ℝ] ℝ} {ℓ : E.H01 →L[ℝ] ℝ} {M α C₁ θ : ℝ}
    (hbound : Core.Variational.BoundedBy a M)
    (hcoer : Core.Variational.CoerciveWith a α)
    (hC₁ : 0 ≤ C₁) (hθ : θ ∈ Set.Icc (0 : ℝ) 1)
    (hM4 : ∀ (T : F.Mesh) (u : E.H2H01),
      ∃ vh : F.Vh T, ‖E.incl u - (vh : E.H01)‖ ≤ C₁ * F.h T * ‖u‖)
    (T : F.Mesh) {u : E.H01} {uh : F.Vh T}
    (hu_weak : Core.Variational.IsWeakSolution a ℓ u)
    (huh : Core.Variational.IsGalerkinSolution a ℓ (F.Vh T) uh)
    (hu_reg : E.MemScale θ u) :
    ‖u - (uh : E.H01)‖ ≤ (M / α) * C₁ ^ θ * (F.h T) ^ θ * E.scaleNorm θ u := by
  have hcea := Core.Variational.cea hbound hcoer hu_weak huh
  have happ := fractional_best_approx_of_endpoint_bound F hC₁ hθ hM4 T hu_reg
  have hratio : 0 ≤ M / α := div_nonneg hbound.1 hcoer.1.le
  calc
    ‖u - (uh : E.H01)‖ ≤ (M / α) * (⨅ vh : F.Vh T, ‖u - (vh : E.H01)‖) := hcea
    _ ≤ (M / α) * (C₁ ^ θ * (F.h T) ^ θ * E.scaleNorm θ u) :=
      mul_le_mul_of_nonneg_left happ hratio
    _ = (M / α) * C₁ ^ θ * (F.h T) ^ θ * E.scaleNorm θ u := by ring

/-- **Alternative quasi-interpolant formulation** (e.g., Scott–Zhang): given an explicit linear
operator `I_h : H₀¹(Ω) → V_h` with uniform `H₀¹`-stability `C₀` and `H²`-accuracy `C₁ h`,
operator interpolation transfers both endpoint bounds directly into the Galerkin error bound. -/
theorem fractional_galerkin_error_of_quasi_interpolant {E : DirichletEndpointCouple}
    (F : ConformingDiscreteFamily E)
    {a : E.H01 →L[ℝ] E.H01 →L[ℝ] ℝ} {ℓ : E.H01 →L[ℝ] ℝ} {M α C₀ C₁ θ : ℝ}
    (hbound : Core.Variational.BoundedBy a M)
    (hcoer : Core.Variational.CoerciveWith a α)
    (hC₀ : 0 ≤ C₀) (hC₁ : 0 ≤ C₁) (hθ : θ ∈ Set.Icc (0 : ℝ) 1)
    (T : F.Mesh) (Ih : E.H01 →L[ℝ] F.Vh T)
    (hstab₀ : ∀ v : E.H01, ‖v - (Ih v : E.H01)‖ ≤ C₀ * ‖v‖)
    (happ₁ : ∀ v : E.H2H01, ‖E.incl v - (Ih (E.incl v) : E.H01)‖ ≤ C₁ * F.h T * ‖v‖)
    {u : E.H01} {uh : F.Vh T}
    (hu_weak : Core.Variational.IsWeakSolution a ℓ u)
    (huh : Core.Variational.IsGalerkinSolution a ℓ (F.Vh T) uh)
    (hu_reg : E.MemScale θ u) :
    ‖u - (uh : E.H01)‖ ≤
      (M / α) * (C₀ ^ (1 - θ) * C₁ ^ θ) * (F.h T) ^ θ * E.scaleNorm θ u := by
  let errOp : E.H01 →L[ℝ] E.H01 :=
    ContinuousLinearMap.id ℝ E.H01 - (F.Vh T).subtypeL.comp Ih
  have hinterp := E.real_op_interpolation errOp hC₀ (mul_nonneg hC₁ (F.h_pos T).le) hθ
    hstab₀ happ₁ hu_reg
  have hinf : (⨅ vh : F.Vh T, ‖u - (vh : E.H01)‖) ≤ ‖errOp u‖ :=
    ciInf_le ⟨0, Set.forall_mem_range.2 fun _ => norm_nonneg _⟩ (Ih u)
  have hcea := Core.Variational.cea hbound hcoer hu_weak huh
  have hratio : 0 ≤ M / α := div_nonneg hbound.1 hcoer.1.le
  calc
    ‖u - (uh : E.H01)‖ ≤ (M / α) * (⨅ vh : F.Vh T, ‖u - (vh : E.H01)‖) := hcea
    _ ≤ (M / α) * ‖errOp u‖ := mul_le_mul_of_nonneg_left hinf hratio
    _ ≤ (M / α) * (C₀ ^ (1 - θ) * (C₁ * F.h T) ^ θ * E.scaleNorm θ u) :=
      mul_le_mul_of_nonneg_left hinterp hratio
    _ = (M / α) * (C₀ ^ (1 - θ) * C₁ ^ θ) * (F.h T) ^ θ * E.scaleNorm θ u := by
      rw [Real.mul_rpow hC₁ (F.h_pos T).le]
      ring

/-! ### Endpoint checks (`θ = 0` and `θ = 1`) -/

/-- When the `H²` norm dominates the `H¹` norm (`‖E.incl u‖ ≤ ‖u‖`, standard for
`‖u‖_{H²}² = ‖u‖_{H¹}² + |u|_{H²}²`), every `u ∈ H² ∩ H₀¹` lies in every `X_θ` with
`‖u‖_{X_θ} ≤ ‖u‖_{H² ∩ H₀¹}`. -/
lemma scaleNorm_le_of_contractive_incl {E : DirichletEndpointCouple}
    (hcontr : ∀ u : E.H2H01, ‖E.incl u‖ ≤ ‖u‖) (θ : ℝ) (u : E.H2H01) :
    E.MemScale θ (E.incl u) ∧ E.scaleNorm θ (E.incl u) ≤ ‖u‖ := by
  have heq :
      E.toComplexCouple.embed₀ (HilbertComplexification.ofReal (E.incl u)) =
        E.toComplexCouple.embed₁ (HilbertComplexification.ofReal u) := by
    change HilbertComplexification.ofReal (E.incl u) =
      HilbertComplexification.complexifyCLM E.incl (HilbertComplexification.ofReal u)
    exact (HilbertComplexification.complexifyCLM_ofReal E.incl u).symm
  refine ⟨memComplexInterp_of_inter θ _ _ heq, ?_⟩
  calc
    E.scaleNorm θ (E.incl u)
        ≤ max ‖HilbertComplexification.ofReal (E.incl u)‖
              ‖HilbertComplexification.ofReal u‖ :=
      complexInterpNorm_le_max_of_inter θ _ _ heq
    _ = max ‖E.incl u‖ ‖u‖ := by simp
    _ = ‖u‖ := max_eq_right (hcontr u)

/-- **Endpoint check at `θ = 1`**: recovers the exact M4 integer-order `O(h)` Galerkin estimate
without losing any constant factor. -/
example {E : DirichletEndpointCouple} (F : ConformingDiscreteFamily E)
    (hcontr : ∀ u : E.H2H01, ‖E.incl u‖ ≤ ‖u‖)
    {a : E.H01 →L[ℝ] E.H01 →L[ℝ] ℝ} {ℓ : E.H01 →L[ℝ] ℝ} {M α C₁ : ℝ}
    (hbound : Core.Variational.BoundedBy a M)
    (hcoer : Core.Variational.CoerciveWith a α)
    (hC₁ : 0 ≤ C₁)
    (hM4 : ∀ (T : F.Mesh) (u : E.H2H01),
      ∃ vh : F.Vh T, ‖E.incl u - (vh : E.H01)‖ ≤ C₁ * F.h T * ‖u‖)
    (T : F.Mesh) {u : E.H2H01} {uh : F.Vh T}
    (hu_weak : Core.Variational.IsWeakSolution a ℓ (E.incl u))
    (huh : Core.Variational.IsGalerkinSolution a ℓ (F.Vh T) uh) :
    ‖E.incl u - (uh : E.H01)‖ ≤ (M / α) * C₁ * F.h T * ‖u‖ := by
  have ⟨hmem, hnorm⟩ := scaleNorm_le_of_contractive_incl hcontr 1 u
  have h1 := fractional_galerkin_energy_error F hbound hcoer hC₁
    ⟨zero_le_one, le_rfl⟩ hM4 T hu_weak huh hmem
  have hcoeff : 0 ≤ (M / α) * C₁ * F.h T :=
    mul_nonneg (mul_nonneg (div_nonneg hbound.1 hcoer.1.le) hC₁) (F.h_pos T).le
  calc
    ‖E.incl u - (uh : E.H01)‖
        ≤ (M / α) * C₁ ^ (1 : ℝ) * (F.h T) ^ (1 : ℝ) * E.scaleNorm 1 (E.incl u) := h1
    _ = (M / α) * C₁ * F.h T * E.scaleNorm 1 (E.incl u) := by simp
    _ ≤ (M / α) * C₁ * F.h T * ‖u‖ := mul_le_mul_of_nonneg_left hnorm hcoeff

/-- **Endpoint check at `θ = 0`**: recovers the `h`-independent `H₀¹`-stability bound
`‖u - u_h‖ ≤ (M / α) * ‖u‖_{X_0}` (note that identifying `‖u‖_{X_0}` with `‖u‖_{H₀¹}` on all of
`H₀¹` requires density of `H² ∩ H₀¹` in `H₀¹`, which is recorded as a separate endpoint theorem). -/
example {E : DirichletEndpointCouple} (F : ConformingDiscreteFamily E)
    {a : E.H01 →L[ℝ] E.H01 →L[ℝ] ℝ} {ℓ : E.H01 →L[ℝ] ℝ} {M α C₁ : ℝ}
    (hbound : Core.Variational.BoundedBy a M)
    (hcoer : Core.Variational.CoerciveWith a α)
    (hC₁ : 0 ≤ C₁)
    (hM4 : ∀ (T : F.Mesh) (u : E.H2H01),
      ∃ vh : F.Vh T, ‖E.incl u - (vh : E.H01)‖ ≤ C₁ * F.h T * ‖u‖)
    (T : F.Mesh) {u : E.H01} {uh : F.Vh T}
    (hu_weak : Core.Variational.IsWeakSolution a ℓ u)
    (huh : Core.Variational.IsGalerkinSolution a ℓ (F.Vh T) uh)
    (hu_reg : E.MemScale 0 u) :
    ‖u - (uh : E.H01)‖ ≤ (M / α) * E.scaleNorm 0 u := by
  have h0 := fractional_galerkin_energy_error F hbound hcoer hC₁
    ⟨le_rfl, zero_le_one⟩ hM4 T hu_weak huh hu_reg
  simpa using h0

end FemLean.Experiments.RFC0005
