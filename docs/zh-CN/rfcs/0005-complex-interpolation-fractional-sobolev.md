# RFC 0005：复插值与分数阶 Sobolev 尺度

[English version](../../rfcs/0005-complex-interpolation-fractional-sobolev.md)

- **状态：** 草稿（Draft）
- **决定：** 待定
- **目标里程碑：** M5（研究导向扩展；与 M4 保持独立）
- **关联 Issue：** [#28](https://github.com/FormalCompMath/fem-lean/issues/28)
- **前置依赖：** 受 [#8](https://github.com/FormalCompMath/fem-lean/issues/8)（RFC 0001）与
  [#27](https://github.com/FormalCompMath/fem-lean/pull/27) 的整数阶 Sobolev 表示决定阻塞。
  本工作**不得阻塞** M4 整数阶误差定理的落地。

## 问题与下游使用场景

设计一套可复用的复插值层与有界区域分数阶 Sobolev 空间尺度，用于支持固定有界多边形
Lipschitz 区域 $\Omega \subset \mathbb{R}^2$ 上的分数阶有限元逼近与 Galerkin 能量误差估计。

对固定的 $\theta \in (0, 1)$，预期下游定理具有如下形式：

$$
\|u - u_h\|_{H^1(\Omega)} \le C(\Omega, \kappa, \theta)\, h^\theta\, \|u\|_{X_\theta},
$$

其中：

- $X_\theta$ 是在 $X_0 = H_0^1(\Omega)$ 与 $X_1 = H^2(\Omega) \cap H_0^1(\Omega)$ 之间精确
  定义的插值尺度；
- $\kappa$ 是网格族的一致形状正则常数；
- $h = \max_T h_T$ 是网格尺寸；
- $u_h \in V_h^0 \subseteq H_0^1(\Omega)$ 是协调 $P_1$ Galerkin 解。

### 为什么优先选择复插值而非实插值

本项目选择 Calderón 复插值方法 $[X_0, X_1]_\theta$ 而非实插值（$K$/$J$ 方法
$(X_0, X_1)_{\theta, q}$），主要基于以下三点直接服务于 FemLean 证明架构的考量：

1. **算子插值定理能显著缩短下游证明并提高复用度。** 只要线性算子 $T$ 在插值对的两个端点
   空间上分别有界，Calderón 定理即可直接给出带精确常数 $1$ 的算子范数估计：
   $$
   \|T\|_{X_\theta \to Y_\theta} \le \|T\|_{X_0 \to Y_0}^{1-\theta} \|T\|_{X_1 \to Y_1}^\theta.
   $$
   因此，只要建立有限元逼近或投影误差算子在 $H_0^1(\Omega)$ 与
   $H^2(\Omega) \cap H_0^1(\Omega)$ 两个端点上的一致界，即可统一推出所有 $\theta \in (0, 1)$
   的分数阶估计，再直接与 `FemLean.Core.Variational.cea` 组合，无需针对每个分数阶单独构造
   逼近证明。
2. **与 Hilbert–Sobolev 空间尺度自然衔接。** 复插值在椭圆 PDE 与 $H^s$ Hilbert 尺度中
   更直接，与重迭代、对偶及端点算子界衔接自然，避免了实插值引入的额外参数 $q$ 及 Lorentz
   型空间语言。
3. **范围边界说明。** 这并非否定实插值的能力——实插值在 Lorentz 空间、弱型估计及部分逼近论
   问题中更为自然；只是当前目标聚焦于 $H^1$–$H^2$–分数阶能量误差估计，复插值在定义清晰度与
   端点稳定性传递两方面更契合。

因此，本 RFC 同时记录**两类验收结果**：

1. 复插值空间的定义及其与有界区域分数阶 Sobolev 尺度的明确关系；
2. 真正使下游有限元证明变短的算子插值、重迭代与端点稳定性定理。

## 生态起点与文献调研

### Mathlib `v4.36.0` 与 EllipticPDE 现状

- **`Mathlib.Analysis.Complex.Hadamard`（`Complex.HadamardThreeLines`）** 已针对任意复赋范
  空间 `[NormedAddCommGroup E] [NormedSpace ℂ E]` 在闭带域 `verticalClosedStrip 0 1` 上证明了
  Banach 空间值的 Hadamard 三线定理（`norm_le_interp_of_mem_verticalClosedStrip₀₁'`）。
- **`Mathlib.Analysis.Complex.PhragmenLindelof`** 提供了支撑三线定理的带域
  Phragmén–Lindelöf 原理。
- **`Mathlib.Analysis.InnerProductSpace.ProdL2`**（`WithLp 2 (H × H)`）与
  **`Mathlib.Analysis.InnerProductSpace.Projection.Submodule`**
  （`Submodule.starProjection` / `Submodule.starProjection_minimal`）提供了规范 Hilbert 复化与
  正交投影误差算子所需的现成原语。
- **`Mathlib.Analysis.FunctionalSpaces.BesselPotentialSpace`** 与
  **`Mathlib.Analysis.Distribution.Sobolev`** 定义的是全欧氏空间上的 Fourier 型 Bessel 位势空间
  $H^{s, p}(E, F)$，不能直接替代有界区域 Dirichlet 尺度。
- **生态缺口：**
  - Mathlib `v4.36.0` 中尚无相容 Banach 对的通用复插值函子；
  - Mathlib `v4.36.0` 中尚无实 Hilbert/Banach 空间的封装复化层；
  - RFC 0001 / PR #27 固定的 EllipticPDE 版本（`d25bc25df4289edc13cb4fa6b79a7d88cbe5b12b`）中
    不含复插值或分数阶 Sobolev 尺度。

### 数学参考文献

- J. Bergh & J. Löfström, *Interpolation Spaces: An Introduction*, Springer, 1976：
  第 2 章 §2.3（相容对）、第 4 章 §§4.1–4.6（Calderón 复插值法、定理 4.1.2 算子插值、定理
  4.2.1–4.2.2 端点与稠密性、定理 4.6.1 重迭代）、第 6 章 §6.4（Bessel 位势空间）。
- H. Triebel, *Interpolation Theory, Function Spaces, Differential Operators*,
  North-Holland, 1978：§1.9（复插值）、§1.18.10（Hilbert 空间谱尺度等价）、§4.3（有界区域空间）。
- J.-L. Lions & E. Magenes, *Non-Homogeneous Boundary Value Problems and Applications*,
  Vol. I, Springer, 1972：第 1 章 §§2, 9–10（Hilbert 插值尺度与 Dirichlet 边界条件在临界指标
  $\theta = 1/2$ 处的 $H_{00}^{1/2}$ 现象）。
- A. Lunardi, *Interpolation Theory*, 3rd ed., Edizioni della Normale, 2018：第 2 章。
- S. C. Brenner & L. R. Scott, *The Mathematical Theory of Finite Element Methods*,
  3rd ed., Springer, 2008：第 4 章 §4.8（Scott–Zhang 拟插值）、第 14 章 §§14.1–14.3（插值空间与
  分数阶有限元误差估计）。
- D. Braess, *Finite Elements*, 第 3 英文版, Cambridge University Press, 2007：
  第 II 章 §§4, 6–8（抽象变分框架、Céa 引理、仿射 $P_1$ 估计）。

## 设计问题与候选方案

### 问题 1：通用复插值层 vs. 仅针对 Dirichlet 尺度的专用构造

1. **方案 A1（推荐）：相容复 Banach 对的通用 Calderón 函子 + 规范 Hilbert 复化桥接层。**
   - 在 `Mathlib.Analysis.Complex.Hadamard` 之上统一定义 `ComplexBanachCouple`、`CalderonStrip`
     与 `[X₀, X₁]_θ`。
   - 通过 `HilbertComplexification H`（基于 `WithLp 2 (H × H)`，赋以 $\|u + iv\|^2 = \|u\|^2 + \|v\|^2$）
     将实 Hilbert 空间（`H01`、`H2H01`）桥接到复插值函子：该复化范数是规范唯一的，保持完备性、
     实嵌入等距，且实有界线性算子复化后满足精确的 $\|T_{\mathbb{C}}\| = \|T\|$（不引入一般实
     Banach 空间复化可能出现的范数畸变因子）。
   - 可复用于 $L^2$–$H^1$、$H_0^1$–$(H^2 \cap H_0^1)$、对偶尺度及后续混合元/Stokes 空间；通用部分
     适合放入 `FemLean/ForMathlib/` 或 `FemLean/Analysis/Interpolation/`。
2. **方案 A2：仅在嵌套 Hilbert 对上使用无界正自伴算子谱幂尺度 $\operatorname{Dom}(\Lambda^\theta)$。**
   - 虽可避开复化，但 Mathlib `v4.36.0` 尚缺无界自伴算子泛函演算，且无法推广至一般 Banach 对。
3. **方案 A3：不抽离通用函子，仅为 Dirichlet 空间手写专用插值范数。**
   - **不推荐：** 重复建设带域机制，失去重迭代、对偶与其他插值对的复用能力。

### 问题 2：如何定义 Dirichlet 尺度 $X_\theta$ 以显式保持边界条件

1. **方案 B1（推荐）：直接在 $X_0 = H_0^1(\Omega)$ 与 $X_1 = H^2(\Omega) \cap H_0^1(\Omega)$
   之间作复插值。**
   - 以 RFC 0001 的 `H01`（`EllipticPdes.H1Graph.H01 volume Ω`）作为外围空间与 $X_0$，以有界区域
     `H²(Ω) ∩ H₀¹(Ω)` Hilbert 空间经连续单射 `incl : H2H01 →L[ℝ] H01` 作为 $X_1$。
   - 齐次 Dirichlet 边界条件由构造自动保持（对所有 $\theta \in [0, 1]$ 有 $X_\theta \subseteq H_0^1(\Omega)$）。
   - 无需为了定义 $X_\theta$ 或证明分数阶 Galerkin 误差估计而先在多边形区域上构造 Stein/Calderón 延拓算子。
   - 能诚实处理边界临界正则性（如 $\theta = 1/2$ 处 Lions–Magenes 的 $H_{00}^{1/2}$ 细节），不会误写错误等同。
2. **方案 B2：将 Mathlib 全空间 `BesselPotentialSpace` 限制到 $\Omega$ 再与 $H_0^1(\Omega)$ 相交。**
   - 依赖多边形 Lipschitz 区域上的有界延拓算子及全空间广义函数与图空间的兼容定理，且不能直接给仅
     定义在 $\Omega$ 上的离散算子提供算子插值；更适合作为后续可选兼容定理，而非 $X_\theta$ 的主定义。
3. **方案 B3：以内蕴 Slobodeckij / Gagliardo 半范数作为主定义。**
   - 直接证明算子插值与重迭代成本过高。

### 问题 3：内蕴分数阶范数与插值范数的区分

下游逼近与 Galerkin 误差定理**必须以插值范数** `dirichletScaleNorm E θ u`（即 $\|u\|_{X_\theta}$）
陈述，**绝不在下游陈述中隐式假设**其与内蕴 Slobodeckij 或 Bessel 限制范数等价。

若后续引入内蕴分数阶范数 $N_\theta$，其与插值范数的等价性必须作为独立定理
（`IntrinsicNormEquivalence`）单独证明，并显式记录区域正则性条件、适用的 $\theta$ 范围以及依赖
于 $(\Omega, \theta)$ 的双边常数 $c_1, c_2 > 0$。

### 问题 4：常数依赖与有限元端点稳定性路线

二维情形下有一个关键数学细节：**节点型 Lagrange $P_1$ 插值算子 $I_h$ 在 $H_0^1(\Omega)$ 上并非有界**
（二维中 $H^1(\Omega) \not\hookrightarrow C^0(\overline{\Omega})$），因此不能直接对节点插值算子在
$H_0^1(\Omega)$ 与 $H^2(\Omega) \cap H_0^1(\Omega)$ 之间套用算子插值。

以下两条合规路线均已在 [experiments/rfc0005/ComplexInterpolation.lean](../../experiments/rfc0005/ComplexInterpolation.lean)
中完成可编译原型验证：

- **路线 C1（接续 M4 的最短路径）：对 $H_0^1$-正交投影误差算子 $E_h = \mathrm{id} - P_h$ 作插值。**
  由于 $V_h^0 \subseteq H_0^1(\Omega)$ 为闭子空间，Mathlib 的 `Submodule.starProjection_minimal`
  在 $\theta = 0$ 处自动给出 $\|u - P_h u\|_{H_0^1} \le 1 \cdot \|u\|_{H_0^1}$；而在 $\theta = 1$ 处，
  M4 的节点 $P_1$ 误差界直接给出
  $\|u - P_h u\|_{H_0^1} \le \inf_{v_h \in V_h^0} \|u - v_h\|_{H_0^1} \le C_{\mathrm{app}}(\Omega, \kappa)\, h\, \|u\|_{H^2 \cap H_0^1}$。
  将 $E_h$ 插值到固定目标空间 $H_0^1(\Omega)$ 再与 `FemLean.Core.Variational.cea` 组合，即得：
  $$
  \|u - u_h\|_{H^1(\Omega)} \le \frac{M}{\alpha}\, C_{\mathrm{app}}(\Omega, \kappa)^\theta\, h^\theta\, \|u\|_{X_\theta}.
  $$
- **路线 C2（局部拟插值路径）：Scott–Zhang / Clément 拟插值算子 $I_h^{\mathrm{SZ}}$。**
  当后续需要显式局部或单元级稳定性时，只需提供保零边值的 $H_0^1$-稳定线性算子 $I_h^{\mathrm{SZ}}$，
  同样通过算子插值得到 $\frac{M}{\alpha}\, C_0^{1-\theta} C_1^\theta\, h^\theta\, \|u\|_{X_\theta}$。

#### 常数依赖关系核对表

| 常数 | 依赖项 | 对 $\theta \in [0, 1]$ 是否一致有界 |
| --- | --- | --- |
| $M / \alpha$（Céa 常数比） | 双线性型、区域 Poincaré 常数 | 是 |
| $C_1 = C_{\mathrm{app}}(\Omega, \kappa)$（M4 端点常数） | 固定区域 $\Omega$、形状正则界 $\kappa$ | 是 |
| $C_0$（正交投影为 $1$；拟插值为 $C_0(\kappa)$） | 无（路线 C1）或 $\kappa$（路线 C2） | 是 |
| 插值因子 $C_0^{1-\theta} C_1^\theta$ | $C_0, C_1, \theta$ | 是，受 $\max(C_0, C_1)$ 一致控制 |
| 内蕴范数等价常数 $c_1(\Omega, \theta), c_2(\Omega, \theta)$ | 区域 $\Omega$、延拓算子、$\theta$ | **一般否**，须单独证明 |

## 已编译的 Lean 声明原型

叶子实验模块 [experiments/rfc0005/ComplexInterpolation.lean](../../experiments/rfc0005/ComplexInterpolation.lean)
在 `origin/main`（Lean `4.36.0` / Mathlib `v4.36.0`）上直接编译通过，无 `sorry`、无 `admit`、
未修改 `lakefile.toml` 与 `lake-manifest.json`，仅使用标准 Lean 公理
（`propext`、`Classical.choice`、`Quot.sound`）。

### 已定义/已证明项与后续延后项的明确区分

| 内容 | 原型状态 | Lean 声明 |
| --- | --- | --- |
| 相容复 Banach 对 | 已定义 | `ComplexBanachCouple` |
| Calderón 带域函数空间与带域范数 | 已定义 + 基本界已证明 | `CalderonStrip`, `CalderonStrip.stripNorm` |
| 复插值空间与下确界范数 | 已定义 + 非负性与交空间界已证明 | `MemComplexInterp`, `ComplexInterp`, `complexInterpNorm` |
| 固定目标空间算子插值（`M₀, M₁ ≥ 0`, `θ ∈ [0, 1]`） | **已证明**（直接调用 `Complex.HadamardThreeLines`） | `norm_apply_le_interp_fixedTarget` |
| 相容对间 Calderón 算子插值（`M₀, M₁ > 0`） | **已证明**（整函数指数权阻尼） | `calderon_operator_interpolation` |
| 规范 Hilbert 复化（`H ⊕ i H`） | 已定义 + `NormedSpace ℂ`、`CompleteSpace`、等距 `ofReal` 与 `‖complexifyCLM T‖ ≤ ‖T‖` **已证明** | `HilbertComplexification`, `complexifyCLM` |
| Dirichlet 插值尺度 `X_θ`（`X₀ = H₀¹`, `X₁ = H² ∩ H₀¹`） | 已定义（参数化以衔接 RFC 0001） | `DirichletEndpointCouple`, `MemScale`, `scaleNorm` |
| 分数阶 $P_1$ 最佳逼近与 Galerkin 能量误差 | **已证明**（由 M4 端点界 + `Core.Variational.cea` 推出，含正交投影与拟插值两版） | `fractional_best_approx_of_endpoint_bound`, `fractional_galerkin_energy_error`, `fractional_galerkin_error_of_quasi_interpolant` |
| 端点核验（`θ = 0` 与 `θ = 1`） | **已编译核验**（当 `‖E.incl u‖ ≤ ‖u‖` 时 `θ = 1` 精确恢复 M4 的 $O(h)$ 估计；`θ = 0` 恢复与 $h$ 无关的 $X_0$ 界） | `scaleNorm_le_of_contractive_incl` 及端点 `example` |
| `ComplexInterp C θ` 的完备性与 Banach 空间实例 | **留待后续 Issue 1 实现** | — |
| 反向端点等同（`X_0 ≃ H₀¹` 需稠密性；`X_1 ≃ H² ∩ H₀¹` 需自反性） | **留待后续 Issue 1/3 实现**（未作隐式假设） | — |
| 复重迭代定理（`[[X₀, X₁]_{θ₀}, [X₀, X₁]_{θ₁}]_η`）与对偶 | **留待后续 Issue 5 实现**（已给出原型陈述） | `ReiterationProperty` |
| 内蕴 Slobodeckij / Bessel 限制范数等价定理 | **留待后续 Issue 5 实现**（已给出独立陈述，下游绝不假设） | `IntrinsicNormEquivalence` |

### 与 RFC 0001（PR #27）的衔接

待 RFC 0001 / PR #27 合入且 M4 确定有界区域 `H²(Ω) ∩ H₀¹(Ω)` 接口后，`DirichletEndpointCouple`
可直接实例化为：

- `H01 := EllipticPdes.H1Graph.H01 volume Ω`（在 `experiments/rfc0001/EllipticPDE.lean` 中已验证
  具备 `InnerProductSpace ℝ` 与 `CompleteSpace` 实例）；
- `H2H01` := 有界区域 `H²(Ω) ∩ H₀¹(Ω)` Hilbert 空间（满足 `‖u‖_{H¹} ≤ ‖u‖_{H²}`）；
- `incl` := 连续线性遗忘单射 `H2H01 →L[ℝ] H01`。

## 方案取舍与迁移影响

- **架构合规性：** 严格遵循 [项目架构](../architecture.md)。通用复插值函子与 Hilbert 复化位于
  `FemLean/Analysis/Interpolation/`（或通用引理入 `FemLean/ForMathlib/`），不依赖网格、有限元或具体
  PDE 模型；分数阶 $P_1$ 逼近位于 `FemLean/Approximation/`；分数阶 Poisson 误差定理位于
  `FemLean/Models/Poisson/`。
- **与 M4 解耦：** M4 的整数阶 $H^2$ 误差定理不依赖本 RFC 的任何模块；相反，M5 仅以 M4 的端点界作为输入。
- **实现风险控制：** 完备性、`X₀ ∩ X₁` 稠密性与重迭代需要更细致的复分析估计（如带域 Poisson 核与
  $e^{\varepsilon (z-\theta)^2}$ 衰减归一）。先落实算子插值与端点稳定性，可避免下游有限元误差定理被
  重迭代等深层理论长期阻塞。

## 后续拆分任务（RFC 通过后）

1. **通用复插值核心（`FemLean/Analysis/Interpolation/`）：** `ComplexInterp C θ` 的 Banach 空间
   结构与完备性、`c₀`-衰减带域等价、含零端点的通用相容对算子插值，以及交空间稠密性。
2. **规范 Hilbert 复化（`FemLean/ForMathlib/`）：** 补齐 `InnerProductSpace ℂ (HilbertComplexification H)`、
   伴随/等距性质与精确算子范数等式 `‖complexifyCLM T‖ = ‖T‖`。
3. **有界区域 Dirichlet 尺度 `X_θ`（`FemLean/Analysis/Sobolev/`）：** 接入 RFC 0001 的 `H01` 与
   M4 的 `H² ∩ H₀¹`，并证明多边形 Lipschitz 区域上 `H² ∩ H₀¹` 在 `H₀¹` 中的稠密性以完成 $\theta = 0$
   端点刻画。
4. **分数阶 $P_1$ 逼近与 Poisson 能量误差（`FemLean/Approximation/`、`FemLean/Models/Poisson/`）：**
   基于路线 C1（正交投影插值）接续 M4 交付分数阶 Galerkin 误差估计；按需另开独立 Issue 实现
   Scott–Zhang 拟插值（路线 C2）。
5. **按需高级插值性质：** 仅在具体下游定理需要时再推进重迭代（Bergh–Löfström 定理 4.6.1）、对偶
   以及与内蕴 Slobodeckij / 全空间 Bessel 限制范数的等价定理。

## 决定记录

等待 RFC 0001（#8 / #27）落定，以及本提案的独立数学语义与 Lean API 审查。
