/-
Copyright (c) 2026 FormalCompMath contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: bombeuler
-/
import EllipticPdes.Poincare.GraphBounded
import FemLean.Core.Variational

/-!
# RFC 0001 downstream prototype using EllipticPDE

This leaf module checks the proposed external representation against the existing
variational interface. It is not imported by the FemLean library.
-/

open MeasureTheory TopologicalSpace
open scoped RealInnerProductSpace

noncomputable section

namespace FemLean.Experiments.RFC0001

abbrev Plane := EuclideanSpace ℝ (Fin 2)

abbrev H1 (Ω : Set Plane) := EllipticPdes.H1Graph.W12 volume Ω

abbrev H01 (Ω : Set Plane) := EllipticPdes.H1Graph.H01 volume Ω

def unitSquare : Opens Plane :=
  ⟨{x : Plane | ∀ i, x i ∈ Set.Ioo (0 : ℝ) 1}, by
    simp only [Set.ofPred_forall]
    exact isOpen_iInter_of_finite fun i =>
      isOpen_Ioo.preimage (EuclideanSpace.proj i).continuous⟩

example (Ω : Set Plane) : CompleteSpace (H01 Ω) := inferInstance

example (Ω : Set Plane) : InnerProductSpace ℝ (H01 Ω) := inferInstance

example (Ω : Set Plane) (hΩ : Bornology.IsBounded Ω) :
    ∃ C : ℝ, 0 ≤ C ∧ ∀ U ∈ EllipticPdes.H1Graph.H01 volume Ω,
      ‖EllipticPdes.H1Graph.fnL U‖ ^ 2 ≤ C * ‖EllipticPdes.H1Graph.gradL U‖ ^ 2 :=
  EllipticPdes.H1Graph.poincare_H01_of_bounded hΩ

/-- The Dirichlet energy on the boundary-zero graph space. -/
def dirichletForm (Ω : Set Plane) : H01 Ω →L[ℝ] H01 Ω →L[ℝ] ℝ := by
  let grad : H01 Ω →L[ℝ] Lp Plane 2 (volume.restrict Ω) :=
    EllipticPdes.H1Graph.gradL.comp (EllipticPdes.H1Graph.H01 volume Ω).subtypeL
  exact (innerSL ℝ).bilinearComp grad grad

@[simp]
lemma dirichletForm_apply (Ω : Set Plane) (u v : H01 Ω) :
    dirichletForm Ω u v =
      ⟪EllipticPdes.H1Graph.gradL (u : EllipticPdes.H1Graph volume Ω),
        EllipticPdes.H1Graph.gradL (v : EllipticPdes.H1Graph volume Ω)⟫ := rfl

lemma dirichletForm_boundedBy (Ω : Set Plane) :
    Core.Variational.BoundedBy (dirichletForm Ω) 1 := by
  refine ⟨zero_le_one, fun u v => ?_⟩
  rw [dirichletForm_apply]
  calc
    |⟪EllipticPdes.H1Graph.gradL (u : EllipticPdes.H1Graph volume Ω),
        EllipticPdes.H1Graph.gradL (v : EllipticPdes.H1Graph volume Ω)⟫|
        ≤ ‖EllipticPdes.H1Graph.gradL (u : EllipticPdes.H1Graph volume Ω)‖ *
          ‖EllipticPdes.H1Graph.gradL (v : EllipticPdes.H1Graph volume Ω)‖ :=
      abs_real_inner_le_norm _ _
    _ ≤ ‖u‖ * ‖v‖ :=
      mul_le_mul (EllipticPdes.H1Graph.norm_gradL_le _)
        (EllipticPdes.H1Graph.norm_gradL_le _) (norm_nonneg _) (norm_nonneg _)
    _ = 1 * ‖u‖ * ‖v‖ := by ring

lemma dirichletForm_symm (Ω : Set Plane) (u v : H01 Ω) :
    dirichletForm Ω u v = dirichletForm Ω v u := by
  change
    ⟪EllipticPdes.H1Graph.gradL (u : EllipticPdes.H1Graph volume Ω),
      EllipticPdes.H1Graph.gradL (v : EllipticPdes.H1Graph volume Ω)⟫ =
    ⟪EllipticPdes.H1Graph.gradL (v : EllipticPdes.H1Graph volume Ω),
      EllipticPdes.H1Graph.gradL (u : EllipticPdes.H1Graph volume Ω)⟫
  exact real_inner_comm
    (EllipticPdes.H1Graph.gradL (v : EllipticPdes.H1Graph volume Ω))
    (EllipticPdes.H1Graph.gradL (u : EllipticPdes.H1Graph volume Ω))

/-- The load associated with an `L²` source. -/
def load (Ω : Set Plane) (f : Lp ℝ 2 (volume.restrict Ω)) : H01 Ω →L[ℝ] ℝ :=
  (innerSL ℝ f).comp (EllipticPdes.H1Graph.embL2 volume Ω)

/-- The Poisson weak equation, expressed through FemLean's existing solution predicate. -/
def IsPoissonWeakSolution (Ω : Set Plane) (f : Lp ℝ 2 (volume.restrict Ω))
    (u : H01 Ω) : Prop :=
  Core.Variational.IsWeakSolution (dirichletForm Ω) (load Ω f) u

example (f : Lp ℝ 2 (volume.restrict (unitSquare : Set Plane)))
    (u : H01 (unitSquare : Set Plane)) :
    IsPoissonWeakSolution (unitSquare : Set Plane) f u ↔
      ∀ v, dirichletForm (unitSquare : Set Plane) u v = load (unitSquare : Set Plane) f v :=
  Iff.rfl

/-- Arbitrary nodal data reconstruct to the weak-gradient space on the same fixed domain. -/
abbrev NodalReconstruction (Ω : Set Plane) (Vertex : Type*) :=
  (Vertex → ℝ) →ₗ[ℝ] H1 Ω

/-- Free Dirichlet coordinates reconstruct to the boundary-zero space on that domain. -/
abbrev DirichletReconstruction (Ω : Set Plane) (FreeVertex : Type*) :=
  (FreeVertex → ℝ) →ₗ[ℝ] H01 Ω

example {n m : ℕ}
    (R : NodalReconstruction (unitSquare : Set Plane) (Fin n))
    (R0 : DirichletReconstruction (unitSquare : Set Plane) (Fin m)) :
    H1 (unitSquare : Set Plane) × H01 (unitSquare : Set Plane) :=
  (R 0, R0 0)

example {n : ℕ} (R : NodalReconstruction (unitSquare : Set Plane) (Fin n))
    (c : Fin n → ℝ) : R c ∈ LinearMap.range R :=
  ⟨c, rfl⟩

end FemLean.Experiments.RFC0001
