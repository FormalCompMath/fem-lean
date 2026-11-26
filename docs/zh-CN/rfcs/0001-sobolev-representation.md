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
