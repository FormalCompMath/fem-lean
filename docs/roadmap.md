# Roadmap

[中文版本](zh-CN/roadmap.md)

Progress is measured by complete, reviewed mathematical nodes, not by book-page
percentage, lines of code, or commits.

## M0 — Infrastructure

- [x] Pin Lean and Mathlib versions.
- [x] Add build and smoke-test CI.
- [x] Add namespace-wide axiom auditing.
- [x] Add issue and PR templates.
- [x] Add architecture, review, and contribution policies.
- [x] Generate blueprint and documentation infrastructure.
- [x] Complete a clean remote build and deploy the project website.
- [x] Configure branch protection and the live project board.

## M1 — Abstract variational core (minimal closed loop)

Deliver a minimal, model-independent Galerkin layer first:

- bounded and coercive bilinear forms (`BoundedBy`, `CoerciveWith`);
- weak and Galerkin solution specifications;
- Galerkin orthogonality;
- Céa's quasi-optimality theorem for $M\ge 0$, including $M=0$;
- exactness on the whole space and concrete compiled examples;
- semantic review and blueprint declaration links.

No mesh, assembly, or particular PDE is needed for this milestone. Further
abstract tools (Lax–Milgram, quadratic energy minimization, Aubin–Nitsche,
Strang's lemmas, saddle-point theory, and `Assembly/`) are added incrementally
in later milestones so the M1 core lands cleanly first.

## M2 — Two-dimensional Poisson continuous problem

- Select the Sobolev representation through RFC 0001. Use one open domain
  $\Omega$ for the weak problem and the mesh prototypes in RFC 0002. Start
  with a bounded polygonal Lipschitz domain in the Euclidean plane.
- Add the required Lax–Milgram and Poincaré/Friedrichs results.
- Define the Poisson weak problem with explicit domain and boundary hypotheses.
- Establish boundedness, symmetry, and coercivity of the Dirichlet form in the
  full $H^1$ norm, using Poincaré for coercivity. Use the same result for
  Galerkin quasi-optimality here and reduced-matrix positivity in M3.

## M3 — Two-dimensional P1 element and assembly bridge

- Select the mesh representation through RFC 0002 (2D triangular meshes first,
  with clean fixed-domain coverage and a path to $d$-dimensional simplices) and
  the finite element triple interface through RFC 0004.
- Define reference triangles, affine maps, Ciarlet $P_1$ nodal basis functions,
  and shape-regular mesh families.
- Reconstruct all nodal values in $H^1(\Omega)$. For homogeneous Dirichlet
  data, extend free vertex vectors in $D_h^0$ by zero at boundary vertices.
  Prove the resulting map $R_h^0:D_h^0\hookrightarrow H_0^1(\Omega)$ is
  linear and injective. Its range is the Galerkin trial and test space.
- In `Assembly/` prove local assembly, coordinate equivalence and boundary
  elimination with test rows and trial columns. In `Models/Poisson` prove
  that the reduced stiffness matrix is positive definite and that its
  equation is equivalent to the Galerkin equation for $R_h^0 U$ on that range.
- Exercise elimination on the unit square split into four triangles at its
  centre. For $-\Delta u=1$, the single free value satisfies $4U_c=1/3$.

## M4 — First complete two-dimensional finite element error theorem

- Establish the reference Bramble–Hilbert nodal estimate, affine scaling and
  the sum of cell estimates in `Approximation/`. Justify nodal evaluation via
  the continuous representative and prove that zero trace gives zero boundary
  nodal values. The [blueprint](../blueprint/src/content.tex) records their
  dependencies in the boundary-preserving approximation result.
- For a fixed domain $\Omega$ and common shape bound $\kappa$, give one
  constant $C=C(\Omega,\kappa)$ for all meshes in the family and all
  unit-coefficient Poisson solutions $u\in H^2(\Omega)\cap H_0^1(\Omega)$.
  First prove the Galerkin error bound. Then use the M3 equivalence to obtain the matrix result below,
  with $h$ the maximum cell diameter and $K_0 U=F_0$ the reduced equation.

  $$
  \lVert u-R_h^0 U\rVert_{H^1(\Omega)}
    \le C h\,\lvert u\rvert_{H^2(\Omega)}.
  $$

- Publish the main theorem's assumptions, declaration links, and axiom audit.

## M5 — Method extensions and dimensional generalization

Add extensions incrementally as needed rather than in book order:

- Aubin–Nitsche duality and $L^2$ error estimates;
- Strang's lemmas and nonconforming methods (e.g. Crouzeix–Raviart);
- inf-sup / Babuška–Brezzi theory, Fortin interpolation, Raviart–Thomas, and
  Stokes;
- higher-order Lagrange elements ($P_k$) and static condensation in `Assembly/`
  (reusing Mathlib's `Matrix.SchurComplement` and `Matrix.PosDef`);
- a posteriori error estimation and adaptivity in `Aposteriori/`;
- generalizing 2D geometry, simplices, and Sobolev layers to $d$ dimensions.

## M6 — Fast solvers and elasticity

- `Solver/`: conjugate gradient error bounds, Uzawa saddle-point iterations,
  and multigrid (Galerkin coarse correction, two-grid, and V/W-cycle
  convergence; algebraic solver work can proceed in parallel once `Assembly/`
  matrix interfaces exist).
- `Models/Elasticity/`: 3D vector-valued Sobolev spaces, linearized strain and
  isotropic Hooke energy, Korn's inequality, and locking-free mixed methods.

Classical finite-difference methods (Braess Chapter I) remain outside the core
roadmap. Each milestone is complete only when its main results build without
placeholders, pass the axiom audit, receive semantic review, and are exercised
downstream.
