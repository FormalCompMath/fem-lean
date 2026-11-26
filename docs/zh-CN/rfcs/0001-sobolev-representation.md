# RFC 0001：Sobolev 空间表示

[English version](../../rfcs/0001-sobolev-representation.md)

- 状态：审查中
- 决定：待定
- 目标里程碑：M2

## 问题

选择 Poisson 弱形式、迹、协调性、插值和误差估计所使用的主要弱导数 Sobolev 空间
接口。该选择必须支持有界区域和 \(H_0^1\)，不能只支持欧氏空间上基于 Fourier
分析的空间。

## 生态起点

- Mathlib `v4.36.0` 已提供紧支撑光滑测试函数
  `Mathlib.Analysis.Distribution.TestFunction`（`𝓓(Ω, F)`）、广义函数
  `Mathlib.Analysis.Distribution.Distribution`（`𝓓'(Ω, F)`）、变分基本引理
  `Mathlib.Analysis.Distribution.AEEqOfIntegralContDiff`、磨光卷积逼近
  `Mathlib.Analysis.Calculus.BumpFunction.{Convolution, SmoothApprox}`，以及全空间
  分部积分 `Mathlib.Analysis.Calculus.LineDeriv.IntegrationByParts`；
- Mathlib 的 `Mathlib.Analysis.Distribution.Sobolev` 通过 Fourier 变换定义全空间
  Bessel 位势空间，`Mathlib.Analysis.FunctionalSpaces.SobolevInequality` 针对紧支撑
  $C^1$ 函数给出嵌入不等式，二者均不能直接替代有界区域上的 $H^1(\Omega)$ 与
  $H_0^1(\Omega)$；
- [EllipticPDE](https://github.com/alejandro-soto-franco/EllipticPDE) 在 Mathlib
  之上建立了弱导数 Sobolev 层和椭圆 Dirichlet 理论；
- 项目可能需要本地层，但应尽量直接建在 Mathlib 的 `TestFunction` / `Distribution`
  之上以降低生态割裂成本，缺失的通用小引理放入 `FemLean/ForMathlib/`。

## 需要制作原型的方案

1. 通过固定版本的依赖复用现有外部项目，并暴露一个小型 FemLean 适配层；
2. 基于当前 Mathlib 定义，在必要处补充有界区域上的弱导数；
3. 建立项目本地弱导数接口，并显式证明它与生态定义的等价性或转换结果。

## 评估标准

- 支持 **M2 先在二维落地**，同时不阻碍后续向 $d$ 维（`EuclideanSpace ℝ (Fin d)`）
  与向量值空间（$H^1(\Omega; \mathbb{R}^d)$、$H(\operatorname{div})$）泛化；
  尤其避免把乘积最大范数空间（`ℝ × ℝ`）与欧氏范数混用；
- 能否同时支持带内积封装的 \(H^1(\Omega)\)、图闭包形式的 \(H_0^1(\Omega)\)、
  \(H^2(\Omega)\)、迹以及有界区域上的分片有限元函数；
- Poincaré/Friedrichs、Rellich–Kondrachov 和 Lax–Milgram 基础设施的可用性；
- 整合现有证明时能否保留并清楚展示其假设；
- 维护成本和工具链兼容性；
- 下游误差估计陈述的质量（包括把椭圆正则性保持为显式前提，而不是塞进空间定义）。

## 必要原型

对每个候选表示，以 `Ω : TopologicalSpace.Opens (EuclideanSpace ℝ (Fin 2))`
为参数，检查 Poisson 弱方程的 Lean 类型，并注明在 $H_0^1(\Omega)$ 上应用
Lax–Milgram 所用的内积及其完备性的来源。

取开单位正方形和 [RFC 0002](0002-mesh-representation.md#同一区域上的两种剖分)
的两种剖分，比较重建签名。每张网格的全体节点值映入 $H^1(\Omega)$，边界零数据
都映入同一个 $H_0^1(\Omega)$。M2 固定 $\Omega$ 核对这些类型，M3 再构造网格并证明协调性。

## 决定记录

等待数学语义和 Lean API 审查。

## 已编译原型：EllipticPDE 与 FemLean 适配层

原型将 EllipticPDE 固定到
`d25bc25df4289edc13cb4fa6b79a7d88cbe5b12b`，并使用主项目的 Mathlib
`v4.36.0`。该外部版本声明的是 `v4.35.0`，但其
`EllipticPdes.Sobolev.Graph` 已用 `v4.36.0` 成功编译。`lakefile.toml` 中必须把
Mathlib 的 `require` 放在最后，使主项目统一控制传递依赖版本；外部仓库还需设置
`subDir = "lean"`。

以下检查在不改变 Lean 工具链、不提高 heartbeat 限制的情况下通过：

```bash
lake build EllipticPdes.Poincare.GraphBounded
lake env lean experiments/rfc0001/EllipticPDE.lean
```

[原型](../../../experiments/rfc0001/EllipticPDE.lean)在
`Plane := EuclideanSpace ℝ (Fin 2)` 上检查了以下实际 Lean 类型：

```lean
EllipticPdes.H1Graph volume Ω
EllipticPdes.H1Graph.W12 volume Ω
EllipticPdes.H1Graph.H01 volume Ω
(Vertex → ℝ) →ₗ[ℝ] EllipticPdes.H1Graph.W12 volume Ω
(FreeVertex → ℝ) →ₗ[ℝ] EllipticPdes.H1Graph.H01 volume Ω
```

其中 `W12` 是闭的弱梯度图子空间，`H01` 是测试函数图的闭包。两者继承实 Hilbert
结构，`H01` 可自动获得 `CompleteSpace` 实例。函数与梯度投影分别是连续线性映射
`fnL` 和 `gradL`。

原型直接用 `gradL` 定义 Dirichlet 型，证明
`Core.Variational.BoundedBy (dirichletForm Ω) 1` 和对称性，通过 `embL2` 构造
\(L^2\) 载荷，并用现有 `Core.Variational.IsWeakSolution` 表达 Poisson 方程。无需
重复定义弱解谓词，也没有引入自定义公理。

固定开单位正方形用 `Plane` 中的一个开集表示，两种重建签名共享同一个 `Ω`，不需要
等式递归或不同区域表示之间的依赖类型转换。开性证明采用有限个坐标开集的交，而不能
使用只适用于线序的 `Set.Ioo` 开性接口。

上述通用签名接受给定的线性映射。为检验具体函数的成员关系，原型另取
[PR #25](https://github.com/FormalCompMath/fem-lean/pull/25) 中的中心扇形网格。
帽函数在中心取 1，在四条边上取 0。`CentreHatMemH01` 陈述：存在一个 `H01` 元素，
其函数分量与梯度分量在正方形上几乎处处分别等于该帽函数及其逐单元梯度。
原型核验中心取值，并对这条命题作类型检查。成员关系的证明属于 M3 的协调性工作。

## Poincaré 与存在性路径

外部图接口已有 `EllipticPdes.H1Graph.poincare_H01_of_bounded`：由 `Ω` 有界得到
非负常数，在 `H01` 上用梯度部分的平方范数控制函数部分的平方范数。由此可得
Dirichlet 型的显式强制常数。`EllipticPdes.DivForm.FullEllipticOp` 也展示了经
Mathlib 的 `IsCoercive.existsUnique_apply_eq` 使用 Lax–Milgram 的路径。

M2 应对单位系数 Poisson 型实例化这些结果，并用显式常数暴露 `BoundedBy` 和
`CoerciveWith`，无需在本地重新证明图空间的 Poincaré 不等式。

## 原型后的方案比较

1. **固定 EllipticPDE 版本并加小型适配层——推荐。** 可复用已完成的图空间、
   弱导数、`H01`、稠密性和 Poincaré 理论。适配层可提供简短的 FemLean 名称并连接
   现有变分谓词，无需建立平行层级。
2. **仅基于 Mathlib 的本地构造——不建议用于 M2。** 当前 Mathlib 提供测试函数、
   广义函数和 Fourier 型 Bessel 位势空间，但没有有界区域图空间构造。重复外部的
   `H1Graph`、`W12`、`H01` 和 Poincaré 证明，会在有限元工作开始前产生大量兼容
   负担。
3. **独立的项目本地 Sobolev 层级——除非复用确实不可行，否则否决。** 原型表明
   无需第二种表示。小型 FemLean 适配仍然合适，但应保留外部图类型及其实例，不应
   用没有下游收益的新接口隐藏它们。

代价是增加固定版本的外部依赖和编译范围。以后升级 Mathlib 时必须检查 EllipticPDE
兼容性，因此固定版本与 `subDir` 设置也是接口决定的一部分。

## 建议决议与后续工作

建议采用**方案 1**，以已编译适配层作为 M2 起点。在独立数学语义和 Lean API 审查
完成前，这仍只是建议而非最终决议。

外部依赖并不会替代有限元专用工作。尤其是在该固定版本中没有找到通用边界迹算子。
后续任务应包括：

- 最小 `FemLean/Analysis/Sobolev` 适配层，而非重复层级；
- 显式 Poisson 强制性和 Lax–Milgram 实例化；
- 有界区域 \(H^2\)、所需连续代表元与迹接口，以及它们同 `H1Graph.W12` / `H01`
  的关系；
- 分片仿射函数的协调性和进入 `H01` 的零边界重建；
- M4 所需仿射拉回、插值与 \(H^2\) 半范数。
