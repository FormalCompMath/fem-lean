/-
Copyright (c) 2026 FormalCompMath contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: oopjoy
-/
import experiments.rfc0002.TriangleMesh

/-! Two conforming triangulations of the same open Euclidean unit square. -/

namespace FemLean.Experiments.RFC0002

noncomputable section

private def box (I : Set ℝ) : Set Plane :=
  (PiLp.homeomorph 2 (fun _ : Fin 2 => ℝ)) ⁻¹' Set.univ.pi (fun _ => I)

/-- Both triangulations have this very same open domain as their index. -/
def unitSquare : TopologicalSpace.Opens Plane :=
  ⟨{x : Plane | ∀ i, x i ∈ Set.Ioo (0 : ℝ) 1}, by
    simp only [Set.ofPred_forall]
    exact isOpen_iInter_of_finite fun i => isOpen_Ioo.preimage (EuclideanSpace.proj i).continuous⟩

private theorem square_as_box : (unitSquare : Set Plane) = box (Set.Ioo 0 1) := by
  ext x
  change (∀ i, x i ∈ Set.Ioo 0 1) ↔ (∀ i ∈ (Set.univ : Set (Fin 2)), x i ∈ Set.Ioo 0 1)
  simp

private theorem square_closure : closure (unitSquare : Set Plane) = box (Set.Icc 0 1) := by
  rw [square_as_box]
  simp only [box, ← Homeomorph.preimage_closure, closure_pi_set, closure_Ioo zero_ne_one]

private theorem square_interior : interior (box (Set.Icc 0 1)) = (unitSquare : Set Plane) := by
  rw [square_as_box]
  simp only [box, ← Homeomorph.preimage_interior, interior_pi_set Set.finite_univ, interior_Icc]

private theorem mem_box (I : Set ℝ) (x : Plane) :
    x ∈ box I ↔ x 0 ∈ I ∧ x 1 ∈ I := by
  change (∀ i : Fin 2, i ∈ (Set.univ : Set (Fin 2)) → x i ∈ I) ↔ _
  simp [Fin.forall_fin_succ]

private lemma corner_inj : Function.Injective corner := by
  intro i j h
  have hx := congrArg (fun p : Plane => p 0) h
  have hy := congrArg (fun p : Plane => p 1) h
  fin_cases i <;> fin_cases j <;> norm_num [corner, xy] at *

private lemma fanPoint_inj : Function.Injective fanPoint := by
  intro i j h
  have hx := congrArg (fun p : Plane => p 0) h
  have hy := congrArg (fun p : Plane => p 1) h
  fin_cases i <;> fin_cases j <;> norm_num [fanPoint, corner, xy] at *

private def diagonalCells : Cells 4 2 where
  conn := diagonal
  point := ⟨corner, corner_inj⟩
  used := by decide
  distinct := by
    intro i j
    exact (by decide : ∀ i j, diagonal.vertices i = diagonal.vertices j → i = j) i j
  independent := diagonal_independent

private def fanCells : Cells 5 4 where
  conn := centreFan
  point := ⟨fanPoint, fanPoint_inj⟩
  used := by decide
  distinct := by
    intro i j
    exact (by decide : ∀ i j, centreFan.vertices i = centreFan.vertices j → i = j) i j
  independent := centreFan_independent

/-- Barycentric coordinates in every cell, defined on the entire plane. -/
private structure Coordinates {n m : ℕ} (c : Cells n m) where
  w : Fin m → Plane → Fin 3 → ℝ
  sum_one : ∀ t x, ∑ i, w t x i = 1
  reconstruct : ∀ t x, ∑ i, w t x i • (c.triangle t).points i = x

namespace Coordinates

variable {n m : ℕ} {c : Cells n m} (b : Coordinates c)

private theorem affine_eq (t : Fin m) (x : Plane) :
    Finset.univ.affineCombination ℝ (c.triangle t).points (b.w t x) = x := by
  rw [Finset.affineCombination_eq_linear_combination _ _ _ (b.sum_one t x), b.reconstruct]

private theorem mem_cell (t : Fin m) (x : Plane) :
    x ∈ (c.triangle t).closedInterior ↔ ∀ i, 0 ≤ b.w t x i := by
  have h := (c.triangle t).affineCombination_mem_closedInterior_iff (b.sum_one t x)
  rw [b.affine_eq] at h
  refine h.trans ⟨fun H i => (H i).1, fun H i => ⟨H i, ?_⟩⟩
  rw [← b.sum_one t x]
  exact Finset.single_le_sum (fun j _ => H j) (Finset.mem_univ i)

private theorem mem_edge (t : Fin m) (i : Fin 3) (x : Plane) :
    x ∈ ((c.triangle t).faceOpposite i).closedInterior ↔
    (∀ j, 0 ≤ b.w t x j) ∧ b.w t x i = 0 := by
  have h := (c.triangle t).affineCombination_mem_closedInterior_face_iff_nonneg
    (fs := {i}ᶜ) (m := 1) (by simp [Finset.card_compl]) (b.sum_one t x)
  rw [b.affine_eq] at h
  change x ∈ ((c.triangle t).face (fs := {i}ᶜ) (m := 1) _).closedInterior ↔ _
  rw [h]
  simp only [Finset.mem_compl, Finset.mem_singleton, not_not, forall_eq]
  grind

/-- A point common to both cells is in the shared hull if its barycentric
weights on all unshared vertices vanish. The converse follows from convexity. -/
private theorem meet (t s : Fin m)
    (vanish : ∀ x, (∀ i, 0 ≤ b.w t x i) → (∀ i, 0 ≤ b.w s x i) →
      ∀ i, c.conn t i ∉ c.conn.vertices s → b.w t x i = 0) :
    (c.triangle t).closedInterior ∩ (c.triangle s).closedInterior =
    convexHull ℝ (c.point '' (↑(c.conn.vertices t ∩ c.conn.vertices s) : Set (Fin n))) := by
  apply Set.Subset.antisymm
  · rintro x ⟨ht, hs⟩
    have pos := (b.mem_cell t x).mp ht
    have off := vanish x pos ((b.mem_cell s x).mp hs)
    let shared := Finset.univ.filter fun i => c.conn t i ∈ c.conn.vertices s
    have hz (i) (hi : i ∉ shared) : b.w t x i = 0 := off i (by simpa [shared] using hi)
    have sum_eq := Finset.sum_subset (Finset.subset_univ shared) (fun i _ hi => hz i hi)
    have vec_eq := Finset.sum_subset (Finset.subset_univ shared)
      (fun i _ hi => show b.w t x i • (c.triangle t).points i = 0 by rw [hz i hi, zero_smul])
    rw [← b.reconstruct t x, ← vec_eq]
    apply (convex_convexHull ℝ _).sum_mem (fun i _ => pos i) (sum_eq.trans (b.sum_one t x))
    intro i hi
    apply subset_convexHull ℝ _
    refine ⟨c.conn t i, Finset.mem_inter.mpr ⟨?_, (Finset.mem_filter.mp hi).2⟩, rfl⟩
    exact Finset.mem_image.mpr ⟨i, Finset.mem_univ _, rfl⟩
  · rw [← (c.triangle t).convexHull_eq_closedInterior, ← (c.triangle s).convexHull_eq_closedInterior]
    apply Set.subset_inter
    all_goals
      apply convexHull_mono
      rintro _ ⟨v, hv, rfl⟩
    · obtain ⟨i, _, rfl⟩ := Finset.mem_image.mp (Finset.mem_inter.mp hv).1
      exact ⟨i, rfl⟩
    · obtain ⟨i, _, rfl⟩ := Finset.mem_image.mp (Finset.mem_inter.mp hv).2
      exact ⟨i, rfl⟩

end Coordinates

private def diagonalWeights (t : Fin 2) (p : Plane) : Fin 3 → ℝ :=
  let x := p 0
  let y := p 1
  ![![1 - x, x - y, y], ![1 - y, x, y - x]] t

private def fanWeights (t : Fin 4) (p : Plane) : Fin 3 → ℝ :=
  let x := p 0
  let y := p 1
  ![![1 - x - y, x - y, 2 * y], ![x - y, x + y - 1, 2 * (1 - x)],
    ![x + y - 1, y - x, 2 * (1 - y)], ![y - x, 1 - x - y, 2 * x]] t

private def diagonalCoords : Coordinates diagonalCells where
  w := diagonalWeights
  sum_one t x := by fin_cases t <;> simp [diagonalWeights, Fin.sum_univ_three]
  reconstruct t x := by
    ext k
    fin_cases t <;> fin_cases k <;>
      norm_num [diagonalWeights, Cells.triangle, diagonalCells, diagonal, corner, xy, Fin.sum_univ_three]

private def fanCoords : Coordinates fanCells where
  w := fanWeights
  sum_one t x := by fin_cases t <;> simp [fanWeights, Fin.sum_univ_three] <;> ring
  reconstruct t x := by
    ext k
    fin_cases t <;> fin_cases k <;>
      norm_num [fanWeights, Cells.triangle, fanCells, centreFan, fanPoint, corner, xy, Fin.sum_univ_three] <;> ring

private theorem diagonal_meet (t s : Fin 2) (hne : t ≠ s) :
    (diagonalCells.triangle t).closedInterior ∩ (diagonalCells.triangle s).closedInterior =
      convexHull ℝ (diagonalCells.point '' (↑(diagonal.vertices t ∩ diagonal.vertices s) : Set (Fin 4))) := by
  apply diagonalCoords.meet
  intro x ht hs i hi
  fin_cases t <;> fin_cases s <;> try exact (hne rfl).elim
  all_goals
    fin_cases i <;> try exact (hi (by decide)).elim
  all_goals
    simp [diagonalCoords, diagonalWeights, Fin.forall_fin_succ] at ht hs ⊢
    linarith

private theorem fan_meet (t s : Fin 4) (hne : t ≠ s) :
    (fanCells.triangle t).closedInterior ∩ (fanCells.triangle s).closedInterior =
      convexHull ℝ (fanCells.point '' (↑(centreFan.vertices t ∩ centreFan.vertices s) : Set (Fin 5))) := by
  apply fanCoords.meet
  -- On adjacent sectors one weight vanishes; on opposite sectors only the centre remains.
  intro x ht hs i hi
  fin_cases t <;> fin_cases s <;> try exact (hne rfl).elim
  all_goals
    fin_cases i <;> try exact (hi (by decide)).elim
  all_goals
    simp [fanCoords, fanWeights, Fin.forall_fin_succ] at ht hs ⊢
    linarith

private theorem diagonal_support : diagonalCells.support = box (Set.Icc 0 1) := by
  ext x
  simp only [Cells.support, Set.mem_iUnion, diagonalCoords.mem_cell, mem_box, Set.mem_Icc]
  simp [diagonalCoords, diagonalWeights, Fin.exists_fin_succ, Fin.forall_fin_succ]
  grind

private theorem fan_support : fanCells.support = box (Set.Icc 0 1) := by
  ext x
  simp only [Cells.support, Set.mem_iUnion, fanCoords.mem_cell, mem_box, Set.mem_Icc]
  simp [fanCoords, fanWeights, Fin.exists_fin_succ, Fin.forall_fin_succ]
  grind

private theorem mem_square_frontier (x : Plane) : x ∈ frontier (unitSquare : Set Plane) ↔
    ((0 ≤ x 0 ∧ x 0 ≤ 1) ∧ (0 ≤ x 1 ∧ x 1 ≤ 1)) ∧
      ¬ ((0 < x 0 ∧ x 0 < 1) ∧ (0 < x 1 ∧ x 1 < 1)) := by
  rw [frontier, square_closure, unitSquare.isOpen.interior_eq, square_as_box]
  exact and_congr (mem_box _ _) (not_congr (mem_box _ _))

private theorem diagonal_boundary : diagonalCells.boundaryEdges = frontier (unitSquare : Set Plane) := by
  have exterior : ∀ (t : Fin 2) (i : Fin 3),
      (diagonal.incident (diagonal.edge t i)).card = 1 ↔
        (t = 0 ∧ i ≠ 1) ∨ (t = 1 ∧ i ≠ 2) := by decide
  ext x
  change (∃ t i, (diagonal.incident (diagonal.edge t i)).card = 1 ∧
    x ∈ ((diagonalCells.triangle t).faceOpposite i).closedInterior) ↔ _
  simp only [exterior, diagonalCoords.mem_edge, mem_square_frontier]
  norm_num [Fin.exists_fin_succ, Fin.forall_fin_succ, diagonalCoords, diagonalWeights]
  grind

private theorem fan_boundary : fanCells.boundaryEdges = frontier (unitSquare : Set Plane) := by
  -- In each fan cell the face opposite vertex 2 (the centre) is a side of the square.
  have exterior : ∀ (t : Fin 4) (i : Fin 3),
      (centreFan.incident (centreFan.edge t i)).card = 1 ↔ i = 2 := by decide
  ext x
  change (∃ t i, (centreFan.incident (centreFan.edge t i)).card = 1 ∧
    x ∈ ((fanCells.triangle t).faceOpposite i).closedInterior) ↔ _
  simp only [exterior, fanCoords.mem_edge, mem_square_frontier, exists_eq_left]
  norm_num [Fin.exists_fin_succ, Fin.forall_fin_succ, fanCoords, fanWeights]
  grind

/-- Split the unit square along the diagonal from (0,0) to (1,1). -/
def diagonalTriangulation : Triangulation unitSquare where
  nv := 4
  nc := 2
  cells := diagonalCells
  meet := diagonal_meet
  cover := diagonal_support.trans square_closure.symm
  interior_eq := diagonal_support ▸ square_interior
  boundary_eq := diagonal_boundary

/-- Join the centre of the same square to each of its four corners. -/
def centreFanTriangulation : Triangulation unitSquare where
  nv := 5
  nc := 4
  cells := fanCells
  meet := fan_meet
  cover := fan_support.trans square_closure.symm
  interior_eq := fan_support ▸ square_interior
  boundary_eq := fan_boundary

end
end FemLean.Experiments.RFC0002
