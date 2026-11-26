# RFC 0002：网格表示

[English version](../../rfcs/0002-mesh-representation.md)

- 状态：审查中
- 决定：待定
- 目标里程碑：M3

## 问题

选择单个单元、相容网格和形状正则网格族的表示。该表示既要支持抽象误差分析，也要
支持具体的仿射 Lagrange 单元，同时不能强迫理论层采用某种可执行网格设计。

## 生态起点

- Mathlib `v4.36.0` 已在 `Mathlib.LinearAlgebra.AffineSpace.Simplex.Basic` 提供
  任意维单形 `Affine.Simplex ℝ P n`（含二维 `Affine.Triangle`），在
  `Mathlib.Geometry.Euclidean.{Simplex, Triangle, Incenter.Basic}` 提供欧氏单形、
  三角形与内心几何，并在 `Mathlib.Geometry.Euclidean.Volume.MeasureSimplex` 证明了
  单形代数体积与 `closedInterior` 测度的等价性；
- 原型阶段应优先评估在 `EuclideanSpace ℝ (Fin 2)` 上直接封装 Mathlib 的
  `Affine.Simplex`，避免从零重写基础三角形面积与内切圆几何；缺失的通用单形引理
  统一放入 `FemLean/ForMathlib/`。

## 需要回答的问题

- 如何在 M3 中先干净落地二维三角网格，同时保留向 $d$ 维单形泛化的路径（例如直接
  基于 `EuclideanSpace ℝ (Fin 2)`，避免最大范数与欧氏坐标双轨转换）？
- 单元是几何单形、顶点数组中的索引，还是通过接口同时支持两者？
- 如何表达非退化性、公共面的相容性和对同一开集 $\Omega$ 的覆盖，使整个网格族
  的重建映射具有固定的 Sobolev 余域？
- 如何表示边界面和本质边界条件？
- 形状正则是单个单元、单个网格还是网格族的性质？
- 逼近陈述中哪些参数和常数必须显式出现？
- 分析证明能否避免依赖可执行数据结构？

## 需要制作原型的方案

1. 使用谓词表达可容许网格的几何分析接口；
2. 携带网格不变量的组合—几何捆绑结构；
3. 分离分析表示与可执行表示，再通过规格连接两者。

## 必要原型

制作形状正则三角形网格族的陈述原型和一个局部仿射拉回公式。检查退化三角形、
悬挂节点、非协调扩展，以及该设计是否人为阻碍高维推广。

### 同一区域上的两种剖分

首个 Poisson 模型固定平面上的有界 Lipschitz 多边形域 $\Omega$。对有限协调剖分，
记 $S_h$ 为所有闭三角形的并。要求 $S_h=\overline{\Omega}$、
$\operatorname{int}(S_h)=\Omega$，且只属于一个三角形的闭边之并恰为 $\partial\Omega$。
两个不同三角形的交为空集或共同的面（顶点或边）。

对同一个开单位正方形取两种剖分。沿对角线剖分得到两个三角形，自由顶点数为零；
将中心连向四角得到四个三角形，有一个自由顶点。两种齐次边界重建的余域都应为
[RFC 0001](0001-sobolev-representation.md) 中原来那个 $\Omega$ 上的 $H_0^1(\Omega)$。

## 决定记录

等待数学语义和 Lean API 审查。
