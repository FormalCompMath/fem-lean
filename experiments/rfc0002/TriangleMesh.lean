/-
Copyright (c) 2026 FormalCompMath contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: oopjoy
-/
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Geometry.Euclidean.Incenter.Basic
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Linarith

/-! RFC 0002 prototype. Global vertex IDs identify shared nodes; affine independence
certifies each geometric cell. The open domain is a parameter shared by all meshes. -/

namespace FemLean.Experiments.RFC0002

abbrev Plane := EuclideanSpace ℝ (Fin 2)
abbrev Triangle := Affine.Triangle ℝ Plane

/-- An ordered triple of global vertex IDs per cell. -/
abbrev Connectivity (nv nc : ℕ) := Fin nc → Fin 3 → Fin nv

namespace Connectivity

variable {nv nc : ℕ} (c : Connectivity nv nc)

def vertices (t : Fin nc) : Finset (Fin nv) := Finset.univ.image (c t)

/-- An unordered global edge key, opposite local vertex i. -/
def edge (t : Fin nc) (i : Fin 3) : Finset (Fin nv) :=
  (Finset.univ.erase i).image (c t)

def incident (e : Finset (Fin nv)) : Finset (Fin nc) :=
  Finset.univ.filter fun t => ∃ i, c.edge t i = e

def freeVertices : Finset (Fin nv) :=
  Finset.univ.filter fun v =>
    ∀ t i, v ∈ c.edge t i → (c.incident (c.edge t i)).card ≠ 1

end Connectivity

/-- Geometry and index agreement. Every global vertex occurs, and two differently
ordered copies of one cell cannot count as distinct cells. -/
structure Cells (nv nc : ℕ) where
  conn : Connectivity nv nc
  point : Fin nv ↪ Plane
  used : ∀ v, ∃ t i, conn t i = v
  distinct : Function.Injective conn.vertices
  independent : ∀ t, AffineIndependent ℝ (fun i => point (conn t i))

namespace Cells

variable {nv nc : ℕ} (c : Cells nv nc)

def triangle (t : Fin nc) : Triangle :=
  ⟨fun i => c.point (c.conn t i), c.independent t⟩

noncomputable def support : Set Plane := ⋃ t, (c.triangle t).closedInterior

def boundaryEdges : Set Plane :=
  {x | ∃ t i, (c.conn.incident (c.conn.edge t i)).card = 1 ∧
    x ∈ ((c.triangle t).faceOpposite i).closedInterior}

end Cells

/-- For a pair of distinct triangles the convex hull of their common vertices
is empty, a point, or a full edge. This excludes hanging nodes and overlaps. -/
structure Triangulation (Ω : TopologicalSpace.Opens Plane) where
  nv : ℕ
  nc : ℕ
  cells : Cells nv nc
  meet : ∀ t s, t ≠ s →
    (cells.triangle t).closedInterior ∩ (cells.triangle s).closedInterior =
    convexHull ℝ (cells.point '' (↑(cells.conn.vertices t ∩ cells.conn.vertices s) : Set (Fin nv)))
  cover : cells.support = closure (Ω : Set Plane)
  interior_eq : interior cells.support = (Ω : Set Plane)
  boundary_eq : cells.boundaryEdges = frontier (Ω : Set Plane)

/-- The bound is uniform in both the mesh index and the cell index. -/
def ShapeRegular {ι : Type*} {Ω : TopologicalSpace.Opens Plane}
    (mesh : ι → Triangulation Ω) (κ : ℝ) : Prop :=
  0 < κ ∧ ∀ j t,
    let T := (mesh j).cells.triangle t
    Metric.diam T.closedInterior ≤ κ * T.inradius

example (T : Triangle) (κ : ℝ) :
    Metric.diam T.closedInterior / T.inradius ≤ κ ↔
      Metric.diam T.closedInterior ≤ κ * T.inradius :=
  div_le_iff₀ T.inradius_pos

/-- Pull back a physical affine scalar field along the reference-to-cell map.
The same barycentric weights multiply its physical nodal values. -/
theorem pullback_affine (ref : Triangle) (F : Plane ≃ᵃ[ℝ] Plane)
    (u : Plane →ᵃ[ℝ] ℝ) (w : Fin 3 → ℝ) (hw : Finset.univ.sum w = 1) :
    u (F (Finset.univ.affineCombination ℝ ref.points w)) =
      Finset.univ.affineCombination ℝ (fun i => u (F (ref.points i))) w :=
  Finset.univ.map_affineCombination ref.points w hw (u.comp F.toAffineMap)

example (ref : Triangle) (e : Equiv.Perm (Fin 3)) :
    (ref.reindex e).closedInterior = ref.closedInterior ∧
      (ref.reindex e).inradius = ref.inradius := by simp

/-- Vertices 0–3 run cyclically around the unit square, and 4 is its centre.
These tests exercise incidence independently of geometric coverage certificates. -/
def diagonal : Connectivity 4 2 := ![![0, 1, 2], ![0, 2, 3]]

def centreFan : Connectivity 5 4 :=
  ![![0, 1, 4], ![1, 2, 4], ![2, 3, 4], ![3, 0, 4]]

example : diagonal.edge 0 1 = diagonal.edge 1 2 := by decide
example : (diagonal.incident (diagonal.edge 0 1)).card = 2 := by decide
example : diagonal.freeVertices = ∅ := by decide
example : centreFan.freeVertices = {4} := by decide

def xy (x y : ℝ) : Plane := WithLp.toLp 2 ![x, y]

def corner : Fin 4 → Plane := ![xy 0 0, xy 1 0, xy 1 1, xy 0 1]

noncomputable def fanPoint : Fin 5 → Plane :=
  ![corner 0, corner 1, corner 2, corner 3, xy (1/2) (1/2)]

/-- Check a specific triple by the two coordinate equations and the sum of weights. -/
private lemma independent_of_coordinates (p : Fin 3 → Plane)
    (check : ∀ w : Fin 3 → ℝ, w 0 + w 1 + w 2 = 0 →
      (∀ k : Fin 2, w 0 * p 0 k + w 1 * p 1 k + w 2 * p 2 k = 0) →
      ∀ i, w i = 0) : AffineIndependent ℝ p := by
  apply (affineIndependent_iff_of_fintype ℝ p).2
  intro w hsum hv
  rw [Finset.univ.weightedVSub_eq_linear_combination hsum, Fin.sum_univ_three] at hv
  apply check w (by simpa only [Fin.sum_univ_three] using hsum)
  intro k
  simpa only [PiLp.add_apply, PiLp.smul_apply, smul_eq_mul, PiLp.zero_apply] using
    congrArg (fun x : Plane => x k) hv

theorem diagonal_independent (t : Fin 2) : AffineIndependent ℝ (fun i => corner (diagonal t i)) := by
  apply independent_of_coordinates
  intro w hs hxy i
  have hx := hxy 0
  have hy := hxy 1
  fin_cases t <;> fin_cases i <;> norm_num [corner, diagonal, xy] at hx hy ⊢ <;> linarith

theorem centreFan_independent (t : Fin 4) : AffineIndependent ℝ (fun i => fanPoint (centreFan t i)) := by
  apply independent_of_coordinates
  intro w hs hxy i
  have hx := hxy 0
  have hy := hxy 1
  fin_cases t <;> fin_cases i <;> norm_num [fanPoint, corner, centreFan, xy] at hx hy ⊢ <;>
    linarith

end FemLean.Experiments.RFC0002
