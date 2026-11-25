# Roadmap

Progress is measured by complete, reviewed mathematical nodes, not by book-page
percentage, lines of code, or commits.

## M0 — Infrastructure

- [x] Pin Lean and Mathlib versions.
- [x] Add build and smoke-test CI.
- [x] Add namespace-wide axiom auditing.
- [x] Add issue and PR templates.
- [x] Add architecture, review, and contribution policies.
- [x] Generate blueprint and documentation infrastructure.
- [ ] Complete a clean remote build and deploy the project website.
- [ ] Configure branch protection and the live project board.

## M1 — Abstract variational core

Deliver a model-independent Galerkin layer:

- bounded and coercive bilinear forms;
- weak and Galerkin solution specifications;
- Galerkin orthogonality;
- Céa's quasi-optimality theorem;
- concrete compiled examples;
- semantic review and blueprint declaration links.

No mesh or particular PDE is needed for this milestone.

## M2 — Poisson continuous problem

- Select the Sobolev representation through RFC 0001.
- Define the Poisson weak problem with explicit domain and boundary hypotheses.
- Establish or reuse the required Poincaré and Lax–Milgram results.
- Instantiate the abstract Galerkin interface and derive quasi-optimality.

## M3 — Two-dimensional P1 element

- Select the mesh representation through RFC 0002.
- Define reference triangles, affine maps, and nodal basis functions.
- Build shape-regular mesh families and the piecewise-linear space.
- Prove conformity and basic nodal properties.

## M4 — First complete finite element error theorem

- Establish the required interpolation and Bramble–Hilbert results.
- Prove, under explicit regularity and mesh assumptions,
  \(\|u-u_h\|_{H^1(\Omega)} \le C h |u|_{H^2(\Omega)}\).
- Publish the main theorem's assumptions, declaration links, and axiom audit.

## M5 — Research-directed extension

Choose according to current research rather than book order:

- Aubin–Nitsche duality;
- Strang's lemmas and nonconforming methods;
- inf-sup theory and Fortin interpolation;
- a posteriori estimation and adaptivity;
- iterative and multigrid solvers;
- elasticity applications.

Each milestone is complete only when its main results build without placeholders,
pass the axiom audit, receive semantic review, and are exercised downstream.
