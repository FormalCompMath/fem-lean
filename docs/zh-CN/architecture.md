# 项目架构

[English version](../architecture.md)

## 设计目标

FemLean 应通过增加模块成长，而不是每增加一个结果就反复修改所有旧模块。仓库按
数学依赖组织，不按 Braess 原书的章节顺序组织。

[总规划](../../fem_lean_architecture_plan.md) 列出教材与模块的对应关系，并给出各层共用的 Poisson 验收算例。

## 分层结构

```text
FemLean/
├── Core/                 抽象变分、鞍点与模型无关的先验误差理论
├── Geometry/             欧氏单形、相容网格和形状正则网格族
├── Analysis/             Sobolev 空间、迹、不等式和正则性接口
├── FiniteElement/        Ciarlet 三元组、具体单元与全局有限元空间
├── Approximation/        Bramble–Hilbert、参考元缩放与插值估计
├── Assembly/             局部型组装、基坐标矩阵、边界消元与静态凝聚
├── Solver/               代数迭代法、Krylov 方法和多重网格
├── Models/               Poisson、Stokes、弹性及其纵向组合
├── Aposteriori/          （M5 按需扩展）网格相关的后验误差估计与自适应框架
└── ForMathlib/           拟向上游 Mathlib 贡献的通用小引理
```

只创建当前工作真正需要的模块，不以预先建立完整空目录树为目标。可执行数值计算实现
（浮点/稀疏矩阵求解等）不放入核心理论分层，留作远期下游方向。

## 范围边界与演进策略

- **核心范围**：FemLean 聚焦于变分与有限元理论。经典 PDE 最大值原理与有限差分方法
  （Braess 第 I 章）不纳入核心库范围，避免维护与变分体系无关的包袱。
- M4 假设当前弱解属于 $H^2(\Omega)$。对所有载荷成立的解算子正则性估计另立定理。
- **先 2D 闭环，再高维泛化**：前期具体几何、Sobolev、单元与插值里程碑优先落地二维
  以尽快打通第一条完整 $P_1$ 收敛链，但底层表示应避免阻碍后续 $d$ 维泛化的设计陷阱
  （例如优先采用 `EuclideanSpace ℝ (Fin 2)` 而非混合最大范数/欧氏坐标，并显式表达
  固定区域覆盖以减少网格族上的依赖类型替换）。

## Mathlib 复用边界（v4.36.0）

引入项目本地基础定义前，优先直接复用 Mathlib `v4.36.0` 已有设施；缺失的通用小引理
统一放入 `ForMathlib/` 以便追踪上游贡献：

- **`Core/`**：`Analysis.InnerProductSpace.{Dual, LaxMilgram, Projection}`、
  `Analysis.Normed.Operator.Bilinear`。
- **`Geometry/`**：`LinearAlgebra.AffineSpace.Simplex.Basic`（`Affine.Simplex`、
  `Affine.Triangle`）、`Geometry.Euclidean.{Simplex, Triangle, Incenter.Basic,
  Volume.MeasureSimplex}` 以及 `MeasureTheory.Measure.Haar.*`。
- **`Analysis/`**：`Analysis.Distribution.{TestFunction, Distribution,
  AEEqOfIntegralContDiff}`、`Analysis.Calculus.BumpFunction.{Convolution,
  SmoothApprox}`、`Analysis.Calculus.LineDeriv.IntegrationByParts` 与
  `MeasureTheory.Integral.DivergenceTheorem`。（Mathlib 中基于 Fourier 变换的
  `Analysis.Distribution.Sobolev` 暂不能替代有界域 $H^1(\Omega)$ / $H_0^1(\Omega)$。）
- **`FiniteElement/` 与 `Approximation/`**：`Algebra.MvPolynomial`、`AffineMap`、
  `LinearAlgebra.Lagrange` 与 `Analysis.Calculus.TaylorIntegral`。
- **`Assembly/` 与 `Solver/`**：`LinearAlgebra.Matrix.{PosDef, SchurComplement,
  BilinearForm}` 与 `Analysis.InnerProductSpace.Spectrum`。

## 依赖规则

1. `Core` 可依赖 Mathlib、`ForMathlib` 中的通用引理及其他核心模块。
   `ForMathlib` 只依赖 Mathlib 和本目录的通用引理。
2. `Geometry` 不依赖 PDE 或 Galerkin 方法。
3. `Analysis` 可以使用 `Geometry` 中的欧氏空间与测度工具，但不能依赖网格或有限元。
4. `FiniteElement` 可以使用几何和分析，但不能依赖具体模型。
5. `Approximation` 可以使用几何、分析和有限元接口，但不能依赖模型专用误差定理。
6. `Assembly` 将 `Core` 中的离散变分形式与线性代数/坐标矩阵相连（包括局部型组装、
   边界消元与静态凝聚），不依赖具体 PDE 模型或三角形单元实现。
7. `Aposteriori`（M5 按需新增）负责网格相关的后验误差估计与自适应；与网格无关的
   抽象先验估计（如 Céa、Aubin–Nitsche、Strang、Brezzi 拟最优性）留在 `Core`。
8. `Solver` 应依赖离散算子和线性代数接口（如通过 `Assembly` 得到的 `Matrix.PosDef`），
   而不是三角形单元实现。
9. `Models` 将通用组件组合成具体结果；通用结果不能导入 `Models`。
10. `examples`、`tests` 和 `experiments` 是叶子模块，库模块不能导入它们。
11. `FemLean.lean` 是公共便利根模块，内部模块应导入精确依赖。

Lean 会禁止循环导入，但不会禁止不合理的层级倒置，因此架构维护应包括导入图审查。

## 模型的纵向组合

### 装配约定

设 $\phi_j$ 是试探基函数，$\psi_i$ 是测试基函数。取 $K_{ij}=a(\phi_j,\psi_i)$、
$F_i=\ell(\psi_i)$，于是测试向量与 $KU$ 配对。在两槽使用同一组基时，Mathlib 的
`LinearMap.BilinForm.toMatrix_apply` 给出 $a(\phi_i,\phi_j)$，转置后才得到 $K$。
在平面的标准基上，$a(x,y)=x_1y_2$ 给出 $K_{21}=1$、$K_{12}=0$（下标从 1 起）。

`Assembly` 对一般双线性型证明坐标方程等价性。在形式对称且强制、重建为单射时，
再推出矩阵正定。`Models/Poisson` 对边界零空间上的 Dirichlet 能量验证这些假设。
Mathlib v4.36.0 的 `Matrix.PosDef.fromBlocks₁₁` 以可逆正定主块的 Schur 补刻画
整个分块矩阵的**半正定性**。

### Poisson 误差估计

具体模型可以组合多个阶段，而不必把这些依赖强加给通用代码。例如：

```text
核心变分理论 ────────────────────┐
                                 │
分析与 P1 逼近 ──────────────────┼── Models/Poisson/Error.lean
                                 │
装配与矩阵等价 ──────────────────┤
                                 │
Poisson 弱形式 ──────────────────┘
```

`Models/Poisson/Weak.lean`、`Models/Poisson/P1.lean` 和
`Models/Poisson/Error.lean` 可以有各自精确的导入。新增 Stokes 模型不应为了方便
而复用 Poisson 专用证明。

## 架构扩展性检查

以下情况说明依赖边界设计合理：

- 增加高阶 Lagrange 单元不需要修改 Céa 引理；
- 增加 Stokes 不需要导入 Poisson 的具体误差定理；
- 增加静态凝聚或证明多重网格收敛不需要知道节点基函数或三角形实现；
- 将二维欧氏/单形模块泛化到 $d$ 维不需要重写 `Core`、`Assembly` 或 `Solver`；
- 论文实验只有暴露真正通用的抽象缺口时才需要修改核心。

## Lean 环境的可扩展性

- 优先使用 `scoped` 记法和局部实验实例；
- 避免不必要的全局 coercion 和 orphan instance；
- 全局 `simp` 引理应有明确的简化范式理由；
- 不要习惯性通过提高 heartbeat 限制来掩盖昂贵的证明搜索；
- 避免在 `Util`、`Misc` 或巨型 `Basic` 文件中堆积无关声明；
- 当声明有不同使用方时拆分模块，不按机械行数限制拆分；
- `ForMathlib` 中的内容应小而通用，并跟踪上游贡献或本地整合。

## 仓库规模扩展

初期保持一个仓库和一个 Lake package。多仓库会引入工具链和依赖版本矩阵。论文
专用仓库可以依赖 FemLean 的固定发布版本，成熟后再将通用结果贡献回主库。只有
独立发布需求足以证明协作成本合理时，才拆分核心数学组件。

## 稳定代码与实验代码

核心表示通过 RFC 和经过审查的迁移说明演化；外围单元和模型可以通过普通 PR 快速
迭代。实验代码不承诺接口稳定，但不能破坏主库。发布记录和 Changelog 应记录破坏性
修改、弃用以及数学陈述变化。
