# FemLean 总体规划

FemLean 按数学依赖组织 Braess《Finite Elements》第三版的形式化。首个完整目标是对同一个二维 Poisson 问题，从弱解、协调的分片线性空间和消元矩阵，一直追踪到重建解的一阶误差估计。

## 如何查阅和更新规划

- 模块职责、允许的导入方向和 Mathlib 复用清单以[架构文档](docs/architecture.md)为准，另有[中文版本](docs/zh-CN/architecture.md)。
- 阶段目标和验收标准以[路线图](docs/roadmap.md)为准，另有[中文版本](docs/zh-CN/roadmap.md)。固定单位正方形的两种剖分见[网格 RFC](docs/zh-CN/rfcs/0002-mesh-representation.md)，中心节点的消元检验见路线图 M3。
- 表示方案、备选设计和决定记录在对应的 [RFC](docs/rfcs/README.md) 中，另有[中文索引](docs/zh-CN/rfcs/README.md)。
- 定理的数学陈述、证明依赖和 Lean 声明链接维护在[数学蓝图](blueprint/src/content.tex)中。

修改规范时更新对应文档及其译本。本页保留参考实现的取舍和教材索引，方便从书中的结果找到相应模块。

## 对 `BraessFEM`（demo）的借鉴与取舍矩阵

`BraessFEM` 以 `1a8c570` 为只读参考版本。

| 策略 | 对应 `BraessFEM` 内容 | 在 `FemLean` 中的落位与改造要点 |
| --- | --- | --- |
| **直接借鉴证明结构（低成本）** | `Variational/*`（6 文件）<br>`Assembly/*`（5 文件）<br>`Multigrid/CoarseCorrection` | 按 `fem-lean` 人工审核过的陈述重写；M1 先迁最小闭环（弱解、Galerkin、正交性、Céa，支持 $0 \le M$），M2/M3/M5/M6 再按需引入 Lax–Milgram、能量极小、Aubin–Nitsche、Strang、装配与粗网格修正 |
| **复用数学路线，升级接口** | `Analysis/DirichletSpace`, `SobolevAffine`, `AveragedTaylor`, `SobolevDensity`, `DirichletTrace`<br>`Mesh/TriangularMesh`, `ShapeRegular`<br>`Elasticity/*` | 先落地 2D，但从底层换用 `EuclideanSpace ℝ (Fin 2)`（去掉 `Point2 := ℝ × ℝ` 双度量割裂）、优先评估对接 Mathlib 的 `TestFunction` 与 `Affine.Simplex`、补齐 bundled `H1`、解耦固定域覆盖（去掉 `hΩ ▸`）、抽象 Ciarlet 三元组 |
| **留在参考库** | `FiniteDifference/*`、`Analysis/ClassicalPoisson`、`Examples/TwoTriangle*`、`Analysis/SublevelDivergence` | 第 I 章差分与古典最大值原理在核心范围之外。算例移植时使用叶子目录和共用网格接口。凸域正则性证明可按下游需求引入。 |

在该冻结版本中，`Analysis/SublevelDivergence` 已证明 `integral_divergence_nonneg_of_boundaryFlux`，且 `Analysis/SmoothConvexHessianEstimate` 调用了该定理。M4 直接使用当前解的 $H^2$ 假设。

---

## Braess《Finite Elements》（第 3 版）到模块的映射

| 教材位置 | 核心内容 | 对应 `FemLean` 模块 | 阶段 |
| --- | --- | --- | --- |
| Ch. I §§1–4 | 古典椭圆 PDE、五点差分与离散极值原理 | *不纳入核心库* | 排除 |
| Ch. II §4 | Ritz–Galerkin、Galerkin 正交、Céa 引理 | `Core/` | **M1（最小闭环）** |
| Ch. II §§1–3 | Sobolev 空间、Lax–Milgram、Poincaré、边值问题 | `Core/` + `Analysis/` + `Models/Poisson/` | **M2（2D 起步）** |
| Ch. II §5, §8 | 2D 可容许三角网格、Ciarlet 三元组、$P_1$ 协调空间、装配与消元 | `Geometry/` + `FiniteElement/` + `Assembly/` + `Models/Poisson/` | **M3（2D $P_1$ + 装配）** |
| Ch. II §§6–7 | 平均 Taylor / Bramble–Hilbert、插值估计与一阶 $H^1$ 误差 | `Approximation/` + `Models/Poisson/` | **M4** |
| Ch. II §7 | Aubin–Nitsche 对偶论证与 $L^2$ 误差 | `Core/` + `Models/Poisson/` | **M5** |
| Ch. III §§1–9 | Strang I/II、CR 非协调、鞍点/inf-sup/RT/Stokes、后验估计 + 高维与高阶 $P_k$ 泛化 | `Core/` + `FiniteElement/` + `Aposteriori/` + `Models/Stokes/` | **M5（按需扩展与泛化）** |
| Ch. IV–VI | CG、多重网格（两网格/V-W 循环）、3D 线弹性/Korn/锁死与板壳 | `Solver/` + `Analysis/` + `Models/Elasticity/` | **M6（求解器与弹性）** |
