# RFC 0005: Complex interpolation and fractional Sobolev scales

[中文版本](../zh-CN/rfcs/0005-complex-interpolation-fractional-sobolev.md)

- **Status:** Draft
- **Decision:** pending
- **Target milestone:** M5 (research-directed extension; independent of M4)
- **Issue:** [#28](https://github.com/FormalCompMath/fem-lean/issues/28)
- **Dependencies:** Blocked by the integer-order Sobolev representation decision in
  [#8](https://github.com/FormalCompMath/fem-lean/issues/8) (RFC 0001) and
  [#27](https://github.com/FormalCompMath/fem-lean/pull/27). This work must not block
  the integer-order M4 error theorem.

## Problem and downstream use cases

Design a reusable complex-interpolation layer and bounded-domain fractional Sobolev
scale supporting fractional-order finite element approximation and Galerkin energy-error
estimates on a fixed bounded polygonal Lipschitz domain $\Omega \subset \mathbb{R}^2$.

For a fixed $\theta \in (0, 1)$, the intended downstream theorem has the form

$$
\|u - u_h\|_{H^1(\Omega)} \le C(\Omega, \kappa, \theta)\, h^\theta\, \|u\|_{X_\theta},
$$

where:

- $X_\theta$ is a precisely defined interpolation scale between $X_0 = H_0^1(\Omega)$
  and $X_1 = H^2(\Omega) \cap H_0^1(\Omega)$;
- $\kappa$ is the uniform mesh shape-regularity bound;
- $h = \max_T h_T$ is the mesh size;
- $u_h \in V_h^0 \subseteq H_0^1(\Omega)$ is the conforming $P_1$ Galerkin solution.

### Why complex interpolation rather than real interpolation

Complex interpolation (Calderón's method $[X_0, X_1]_\theta$) is chosen over real
interpolation ($K$/$J$-methods $(X_0, X_1)_{\theta, q}$) for three concrete reasons
tied directly to FemLean's proof architecture:

1. **Operator interpolation shortens downstream proofs.** Whenever a linear operator $T$
   is bounded at both endpoints of an interpolation couple, Calderón's theorem yields
   $$
   \|T\|_{X_\theta \to Y_\theta} \le \|T\|_{X_0 \to Y_0}^{1-\theta} \|T\|_{X_1 \to Y_1}^\theta
   $$
   with constant $1$. Once uniform endpoint bounds of a finite element approximation or
   projection error operator are established on $H_0^1(\Omega)$ and
   $H^2(\Omega) \cap H_0^1(\Omega)$, every fractional estimate $\theta \in (0, 1)$
   follows uniformly and composes immediately with `FemLean.Core.Variational.cea`,
   avoiding per-$\theta$ approximation constructions.
2. **Natural alignment with Hilbert–Sobolev scales.** Complex interpolation meshes
   directly with $H^s$ Hilbert scales, reiteration, duality, and endpoint operator
   bounds without introducing the auxiliary integrability parameter $q$ and Lorentz-space
   language required by real interpolation.
3. **Scope clarity.** Real interpolation is not mathematically weaker—it is the natural
   framework for Lorentz spaces, weak-type bounds, and certain approximation spaces—but
   those targets are outside the $H^1$–$H^2$–fractional energy-error line prioritized here.

Accordingly, this RFC specifies **two classes of acceptance results**:

1. the definition of the complex interpolation space and its explicit relation to
   bounded-domain fractional Sobolev scales;
2. the operator-interpolation, reiteration, and endpoint-stability theorems that
   genuinely simplify downstream finite element proofs.

## Ecosystem starting points and bibliography

### Mathlib `v4.36.0` and EllipticPDE findings

- **`Mathlib.Analysis.Complex.Hadamard` (`Complex.HadamardThreeLines`)** already
  proves the Banach-space-valued Hadamard three-lines theorem
  (`norm_le_interp_of_mem_verticalClosedStrip₀₁'`) for arbitrary complex normed spaces
  `[NormedAddCommGroup E] [NormedSpace ℂ E]` on `verticalClosedStrip 0 1`.
- **`Mathlib.Analysis.Complex.PhragmenLindelof`** provides the vertical-strip
  Phragmén–Lindelöf principle underlying three-lines bounds.
- **`Mathlib.Analysis.InnerProductSpace.ProdL2`** (`WithLp 2 (H × H)`) and
  **`Mathlib.Analysis.InnerProductSpace.Projection.Submodule`**
  (`Submodule.starProjection` / `Submodule.starProjection_minimal`) supply the exact
  Hilbert-space primitives needed for canonical complexification and
  orthogonal-projection error operators.
- **`Mathlib.Analysis.FunctionalSpaces.BesselPotentialSpace`** and
  **`Mathlib.Analysis.Distribution.Sobolev`** define Fourier-based Bessel potential
  spaces $H^{s, p}(E, F)$ on full Euclidean spaces, not bounded-domain Dirichlet scales.
- **Missing ecosystem pieces:**
  - No generic complex-interpolation functor for compatible Banach couples exists in
    Mathlib `v4.36.0`.
  - No bundled complexification of real Hilbert/Banach spaces exists in Mathlib `v4.36.0`.
  - No complex-interpolation or fractional-Sobolev scale exists in the EllipticPDE
    revision evaluated in RFC 0001 / PR #27 (`d25bc25df4289edc13cb4fa6b79a7d88cbe5b12b`).

### Mathematical references

- J. Bergh and J. Löfström, *Interpolation Spaces: An Introduction*, Springer, 1976:
  Ch. 2 §2.3 (compatible couples), Ch. 4 §§4.1–4.6 (Calderón complex method, Theorem
  4.1.2 operator interpolation, Theorems 4.2.1–4.2.2 endpoints and density, Theorem
  4.6.1 reiteration), Ch. 6 §6.4 (Bessel potential spaces).
- H. Triebel, *Interpolation Theory, Function Spaces, Differential Operators*,
  North-Holland, 1978: §1.9 (complex interpolation), §1.18.10 (Hilbert-space spectral
  scale identification), §4.3 (spaces on bounded domains).
- J.-L. Lions and E. Magenes, *Non-Homogeneous Boundary Value Problems and
  Applications*, Vol. I, Springer, 1972: Ch. 1 §§2, 9–10 (Hilbert interpolation scales
  and boundary-condition compatibility, including the critical $\theta = 1/2$ space
  $H_{00}^{1/2}$).
- A. Lunardi, *Interpolation Theory*, 3rd ed., Edizioni della Normale, 2018: Ch. 2.
- S. C. Brenner and L. R. Scott, *The Mathematical Theory of Finite Element Methods*,
  3rd ed., Springer, 2008: Ch. 4 §4.8 (Scott–Zhang quasi-interpolation), Ch. 14
  §§14.1–14.3 (interpolation spaces and fractional-order FEM error bounds).
- D. Braess, *Finite Elements*, 3rd English ed., Cambridge University Press, 2007:
  Ch. II §§4, 6–8 (abstract variational framework, Céa's lemma, affine $P_1$ estimates).

## Design questions and candidate options

### Question 1: Generic complex-interpolation functor vs. Dirichlet-only construction

1. **Option A1 (Recommended): Generic Calderón functor for compatible complex Banach
   couples + canonical Hilbert complexification bridge.**
   - Define `ComplexBanachCouple`, `CalderonStrip`, and `[X₀, X₁]_θ` once on top of
     `Mathlib.Analysis.Complex.Hadamard`.
   - Bridge real Hilbert spaces (`H01`, `H2H01`) via `HilbertComplexification H`
     (`WithLp 2 (H × H)` with $\|u + i v\|^2 = \|u\|^2 + \|v\|^2$), which is canonical,
     preserves completeness, embeds `H` isometrically, and preserves operator norms
     $\|T_{\mathbb{C}}\| = \|T\|$ with exact constant $1$ (unlike general real Banach
     complexifications, which may introduce a distortion factor).
   - Reusable across $L^2$–$H^1$, $H_0^1$–$(H^2 \cap H_0^1)$, dual scales, and future
     mixed/Stokes spaces; core pieces are natural candidates for `FemLean/ForMathlib/`.
2. **Option A2: Hilbert spectral-power scale $\operatorname{Dom}(\Lambda^\theta)$ only.**
   - For a dense nested Hilbert couple $X_1 \hookrightarrow X_0$, avoids complexification
     by using the unbounded positive self-adjoint operator $\Lambda$ satisfying
     $\langle u, v \rangle_{X_1} = \langle \Lambda u, \Lambda v \rangle_{X_0}$.
   - **Drawback:** Mathlib `v4.36.0` lacks unbounded self-adjoint functional calculus,
     and this construction does not extend to non-Hilbert Banach couples.
3. **Option A3: Ad-hoc Dirichlet-only norm without an abstract functor.**
   - **Rejected:** Duplicates complex-strip machinery without supporting reiteration,
     duality, or reuse across other couples.

### Question 2: Defining the Dirichlet scale $X_\theta$ and preserving boundary conditions

1. **Option B1 (Recommended): Direct interpolation between $X_0 = H_0^1(\Omega)$ and
   $X_1 = H^2(\Omega) \cap H_0^1(\Omega)$.**
   - Uses RFC 0001's `H01` (`EllipticPdes.H1Graph.H01 volume Ω`) as the ambient space
     and `X₀`, and the bounded-domain `H²(Ω) ∩ H₀¹(Ω)` Hilbert space as `X₁` via the
     continuous injection `incl : H2H01 →L[ℝ] H01`.
   - Homogeneous Dirichlet boundary conditions are preserved **by construction**
     ($X_\theta \subseteq H_0^1(\Omega)$ for every $\theta \in [0, 1]$).
   - Avoids needing a Stein/Calderón extension operator on polygonal domains merely to
     define $X_\theta$ or prove the fractional Galerkin error theorem.
   - Handles boundary-critical regularity honestly (e.g., Lions–Magenes $H_{00}^{1/2}$
     phenomena when interpolating spaces with trace constraints).
2. **Option B2: Restriction of Mathlib's full-space `BesselPotentialSpace` to $\Omega$,
   intersected with $H_0^1(\Omega)$.**
   - Requires bounded extension operators on polygonal Lipschitz domains and separate
     compatibility between full-space tempered distributions and RFC 0001's graph spaces,
     and does not directly supply operator interpolation for discrete operators defined
     only on $\Omega$.
   - Better positioned as an optional compatibility theorem later, not the primary
     definition of $X_\theta$.
3. **Option B3: Intrinsic Slobodeckij / Gagliardo seminorm as the primary definition.**
   - Makes operator interpolation and reiteration far harder to establish directly.

### Question 3: Intrinsic fractional norms vs. interpolation norms

Downstream approximation and Galerkin error theorems **must be stated in terms of the
interpolation norm** `dirichletScaleNorm E θ u` (i.e., $\|u\|_{X_\theta}$) and **must
never assume** equivalence with an intrinsic Slobodeckij or Bessel restriction norm.

Any identification with an intrinsic fractional norm $N_\theta$ must be formulated as an
explicit, separate equivalence theorem (`IntrinsicNormEquivalence`), recording:

- the exact domain regularity assumptions (e.g., bounded Lipschitz / polygonal);
- the exact range of $\theta$ for which the equivalence holds (accounting for
  boundary-condition transitions);
- explicit two-sided constants $c_1(\Omega, \theta), c_2(\Omega, \theta) > 0$.

### Question 4: Constant dependencies and finite element endpoint stability

A key mathematical subtlety in 2D is that **nodal Lagrange $P_1$ interpolation $I_h$ is
not bounded on $H_0^1(\Omega)$** because $H^1(\Omega) \not\hookrightarrow C^0(\overline{\Omega})$
in dimension $2$. Therefore, operator interpolation cannot be applied directly to the
nodal interpolant between $H_0^1(\Omega)$ and $H^2(\Omega) \cap H_0^1(\Omega)$.

Two clean routes avoid this trap and are both prototyped in
[experiments/rfc0005/ComplexInterpolation.lean](../../experiments/rfc0005/ComplexInterpolation.lean):

- **Route C1 (Minimal path directly on top of M4): $H_0^1$-orthogonal projection
  error operator $E_h = \mathrm{id} - P_h$.**
  Since $V_h^0 \subseteq H_0^1(\Omega)$ is a closed subspace, Mathlib's
  `Submodule.starProjection_minimal` gives $\|u - P_h u\|_{H_0^1} \le 1 \cdot \|u\|_{H_0^1}$
  automatically at $\theta = 0$, while M4's nodal $P_1$ bound gives
  $\|u - P_h u\|_{H_0^1} \le \inf_{v_h \in V_h^0} \|u - v_h\|_{H_0^1} \le C_{\mathrm{app}}(\Omega, \kappa)\, h\, \|u\|_{H^2 \cap H_0^1}$
  at $\theta = 1$. Interpolating $E_h$ into the fixed target $H_0^1(\Omega)$ and
  composing with `FemLean.Core.Variational.cea` yields
  $$
  \|u - u_h\|_{H^1(\Omega)} \le \frac{M}{\alpha}\, C_{\mathrm{app}}(\Omega, \kappa)^\theta\, h^\theta\, \|u\|_{X_\theta}.
  $$
- **Route C2 (Local quasi-interpolant path): Scott–Zhang / Clément operator $I_h^{\mathrm{SZ}}$.**
  When a local, explicit boundary-preserving $H_0^1$-stable operator with
  $\|v - I_h^{\mathrm{SZ}} v\|_{H^1} \le C_0(\kappa) \|v\|_{H^1}$ and
  $\|v - I_h^{\mathrm{SZ}} v\|_{H^1} \le C_1(\Omega, \kappa) h \|v\|_{H^2}$ is
  supplied, the same interpolation step gives
  $$
  \|u - u_h\|_{H^1(\Omega)} \le \frac{M}{\alpha}\, C_0^{1-\theta} C_1^\theta\, h^\theta\, \|u\|_{X_\theta}.
  $$

#### Explicit constant-dependence accounting

| Constant | Depends on | Uniform in $\theta \in [0, 1]$? |
| --- | --- | --- |
| $M / \alpha$ (Céa ratio) | Bilinear form, domain Poincaré constant | Yes |
| $C_1 = C_{\mathrm{app}}(\Omega, \kappa)$ (M4 endpoint bound) | Fixed domain $\Omega$, shape bound $\kappa$ | Yes |
| $C_0$ (orthogonal projection: $C_0 = 1$; quasi-interpolant: $C_0(\kappa)$) | None (Route C1) or $\kappa$ (Route C2) | Yes |
| Interpolation factor $C_0^{1-\theta} C_1^\theta$ | $C_0, C_1, \theta$ | Yes, bounded by $\max(C_0, C_1)$ |
| Intrinsic norm equivalence constants $c_1(\Omega, \theta), c_2(\Omega, \theta)$ | Domain $\Omega$, extension operator, $\theta$ | **No** in general; requires separate proof |

## Compiled Lean statement prototype

The downstream leaf prototype
[experiments/rfc0005/ComplexInterpolation.lean](../../experiments/rfc0005/ComplexInterpolation.lean)
compiles against `origin/main` (Lean `4.36.0` / Mathlib `v4.36.0`) with zero `sorry`,
zero `admit`, no `lakefile.toml` or `lake-manifest.json` changes, and only standard Lean
axioms (`propext`, `Classical.choice`, `Quot.sound`).

### What is defined and proved vs. deferred

| Item | Prototype status | Lean declaration |
| --- | --- | --- |
| Compatible complex Banach couple | Defined | `ComplexBanachCouple` |
| Calderón strip space and strip norm | Defined + basic norm bounds proved | `CalderonStrip`, `CalderonStrip.stripNorm` |
| Complex interpolation space and infimum norm | Defined + nonnegativity & intersection bound proved | `MemComplexInterp`, `ComplexInterp`, `complexInterpNorm` |
| Fixed-target operator interpolation (`M₀, M₁ ≥ 0`, `θ ∈ [0, 1]`) | **Proved** directly from `Complex.HadamardThreeLines` | `norm_apply_le_interp_fixedTarget` |
| Couple-to-couple Calderón operator interpolation (`M₀, M₁ > 0`) | **Proved** via entire exponential damping | `calderon_operator_interpolation` |
| Canonical Hilbert complexification (`H ⊕ i H`) | Defined + `NormedSpace ℂ`, `CompleteSpace`, isometric `ofReal`, exact `‖complexifyCLM T‖ ≤ ‖T‖` **proved** | `HilbertComplexification`, `complexifyCLM` |
| Dirichlet interpolation scale `X_θ` (`X₀ = H₀¹`, `X₁ = H² ∩ H₀¹`) | Defined (parameterized for RFC 0001 instantiation) | `DirichletEndpointCouple`, `MemScale`, `scaleNorm` |
| Fractional `P₁` best-approximation & Galerkin energy error | **Proved** from M4 endpoint bound + `Core.Variational.cea` (both projection and quasi-interpolant forms) | `fractional_best_approx_of_endpoint_bound`, `fractional_galerkin_energy_error`, `fractional_galerkin_error_of_quasi_interpolant` |
| Endpoint recovery at `θ = 0` and `θ = 1` | **Checked** (`θ = 1` recovers exact M4 `O(h)` bound whenever `‖E.incl u‖ ≤ ‖u‖`; `θ = 0` recovers `h`-independent bound in `X_0`) | `scaleNorm_le_of_contractive_incl`, endpoint `example`s |
| Banach structure / completeness of `ComplexInterp C θ` | **Deferred** to implementation issue 1 | — |
| Reverse endpoint identifications (`X_0 ≃ H₀¹` via density; `X_1 ≃ H² ∩ H₀¹` via reflexivity) | **Deferred** to implementation issue 1 (not assumed) | — |
| Complex reiteration (`[[X₀, X₁]_{θ₀}, [X₀, X₁]_{θ₁}]_η`) & duality | **Deferred** to implementation issue 4 (prototype statement `ReiterationProperty` recorded) | `ReiterationProperty` |
| Intrinsic Slobodeckij / Bessel-restriction norm equivalence | **Deferred** to implementation issue 4 (prototype statement `IntrinsicNormEquivalence` recorded; never assumed downstream) | `IntrinsicNormEquivalence` |

### Integration with RFC 0001 (PR #27)

Once RFC 0001 / PR #27 merges and M4 defines the bounded-domain `H²(Ω) ∩ H₀¹(Ω)` space,
`DirichletEndpointCouple` instantiates directly with:

- `H01 := EllipticPdes.H1Graph.H01 volume Ω` (which already provides
  `InnerProductSpace ℝ` and `CompleteSpace` in `experiments/rfc0001/EllipticPDE.lean`),
- `H2H01` := bounded-domain `H²(Ω) ∩ H₀¹(Ω)` Hilbert space with `‖u‖_{H¹} ≤ ‖u‖_{H²}`,
- `incl` := the continuous linear forgetful injection `H2H01 →L[ℝ] H01`.

Because `experiments/rfc0005/ComplexInterpolation.lean` is parameterized over
`DirichletEndpointCouple`, this RFC prototype requires no dependency edits and causes no
merge conflict with PR #27 or M4.

## Trade-offs and migration consequences

- **Architecture impact:** Follows `docs/architecture.md` cleanly. The generic functor
  and Hilbert complexification belong in `FemLean/Analysis/Interpolation/` (or
  `FemLean/ForMathlib/` for general Banach/Hilbert lemmas) with zero mesh, finite
  element, or PDE model dependencies. The fractional $P_1$ approximation theorem belongs
  in `FemLean/Approximation/` and the fractional Poisson error theorem in
  `FemLean/Models/Poisson/`.
- **M4 isolation:** M4's integer-order $H^2$ Poisson theorem does not depend on any
  module introduced here; rather, M5 consumes M4's endpoint bound as an input hypothesis.
- **Technical risk:** Proving completeness of `[X₀, X₁]_θ`, density of `X₀ ∩ X₁`, and
  reiteration requires careful complex-analysis estimates (e.g., Poisson kernel on the
  strip and `c₀`-decay normalization via $e^{\varepsilon (z-\theta)^2}$). Keeping the
  operator-interpolation path usable before reiteration avoids blocking downstream FEM
  results on the hardest general-theory theorems.

## Follow-up implementation issues (after RFC approval)

1. **Generic complex interpolation core (`FemLean/Analysis/Interpolation/`):**
   Banach-space structure and completeness of `ComplexInterp C θ`, `c₀`-vanishing strip
   equivalence, full `0 ≤ M₀, M₁` couple-to-couple operator interpolation, and endpoint
   density embeddings (`X₀ ∩ X₁` dense in `[X₀, X₁]_θ`).
2. **Canonical Hilbert complexification (`FemLean/ForMathlib/`):**
   Complete `InnerProductSpace ℂ (HilbertComplexification H)`, adjoint/isometry lemmas,
   and exact operator-norm equality `‖complexifyCLM T‖ = ‖T‖`.
3. **Bounded-domain Dirichlet scale `X_θ` (`FemLean/Analysis/Sobolev/`):**
   Instantiate `DirichletEndpointCouple` with RFC 0001's `H01` and M4's `H² ∩ H₀¹`,
   and prove density of `H² ∩ H₀¹` in `H₀¹` on polygonal Lipschitz domains for endpoint
   identification at $\theta = 0$.
4. **Fractional $P_1$ approximation and Poisson energy error (`FemLean/Approximation/`,
   `FemLean/Models/Poisson/`):**
   Connect M4's $P_1$ error theorem via orthogonal-projection interpolation (Route C1) to
   deliver the fractional Galerkin energy estimate; add a separate optional issue for
   Scott–Zhang quasi-interpolation (Route C2) when local stability is needed.
5. **Advanced interpolation properties (on demand):**
   Reiteration (Bergh–Löfström Theorem 4.6.1), duality, and equivalence with intrinsic
   Slobodeckij or full-space Bessel restriction norms only when required by a concrete
   downstream theorem.

## Decision record

Pending RFC 0001 (#8 / #27) acceptance and independent semantic and Lean API review of
this proposal.
