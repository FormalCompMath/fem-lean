# 发展路线图

[English version](../roadmap.md)

项目进度按完整且经过审查的数学节点衡量，不按原书页数百分比、代码行数或提交数
衡量。

## M0 — 基础设施

- [x] 固定 Lean 和 Mathlib 版本。
- [x] 添加构建和冒烟测试 CI。
- [x] 添加全命名空间公理审计。
- [x] 添加 issue 和 PR 模板。
- [x] 添加架构、审查和贡献政策。
- [x] 建立蓝图和文档基础设施。
- [x] 完成干净的远端构建并部署项目网站。
- [x] 配置分支保护和实时 Projects 看板。

## M1 — 抽象变分核心（最小闭环）

优先交付不依赖具体模型的最小 Galerkin 闭环：

- 有界且强制的双线性形式（`BoundedBy`、`CoerciveWith`）；
- 弱解和 Galerkin 解的规格；
- Galerkin 正交性；
- Céa 拟最优性定理（采用 $M\ge 0$，包括 $M=0$）；
- 全空间精确性推论与具体的可编译示例；
- 数学语义审查和蓝图声明链接。

本里程碑不需要网格、装配或具体 PDE。其余抽象工具（Lax–Milgram、二次能量极小化、
Aubin–Nitsche、Strang 引理、鞍点理论以及 `Assembly/`）留到后续阶段按需逐步加入，
确保 M1 核心先干净落地。

## M2 — 二维 Poisson 连续问题

- 通过 RFC 0001 选择 Sobolev 空间表示。弱问题和 RFC 0002 的网格原型共用一个
  开集 $\Omega$，首期取欧氏平面上的有界 Lipschitz 多边形域。
- 补充或复用所需的 Lax–Milgram 和 Poincaré/Friedrichs 结果；
- 在明确的区域和边界假设下定义 Poisson 弱问题；
- 实例化抽象 Galerkin 接口并推出拟最优估计。

## M3 — 二维 P1 单元与装配桥梁

- 通过 RFC 0002 选择网格表示（先做二维三角网格，确保固定区域覆盖清晰且不阻塞后续
  $d$ 维单形泛化），并通过 RFC 0004 确定 Ciarlet 有限元接口；
- 定义参考三角形、仿射映射、$P_1$ 节点基函数与形状正则网格族；
- 将全体节点值重建到 $H^1(\Omega)$。对齐次 Dirichlet 条件，把 $D_h^0$ 中的自由顶点坐标
  在边界顶点处补零，证明所得映射 $R_h^0:D_h^0\hookrightarrow H_0^1(\Omega)$
  是线性单射，其像就是 Galerkin 试探和测试空间。
- 在 `Assembly/` 中按测试行、试探列证明局部型组装、坐标等价与边界消元。
  在 `Models/Poisson` 中证明消元刚度矩阵正定，并证明其方程等价于
  $R_h^0 U$ 在上述像空间上满足 Galerkin 方程。
- 在从中心连向四个角的单位正方形网格上验收消元。对 $-\Delta u=1$，
  唯一自由顶点的方程为 $4U_c=1/3$。

## M4 — 第一条完整的二维有限元误差定理

- 在 `Approximation/` 建立所需的二维插值、仿射缩放与平均 Taylor / Bramble–Hilbert
  结果；
- 固定区域 $\Omega$ 和统一的形状正则界 $\kappa$，对整个网格族及所有满足
  $u\in H^2(\Omega)\cap H_0^1(\Omega)$ 的单位系数 Poisson 解使用同一常数
  $C=C(\Omega,\kappa)$。先证明 Galerkin 解的误差界，再用 M3 的等价性推出下式。
  其中 $h$ 为最大单元直径，$U$ 满足消元方程 $K_0 U=F_0$。

  $$
  \lVert u-R_h^0 U\rVert_{H^1(\Omega)}
    \le C h\,\lvert u\rvert_{H^2(\Omega)}.
  $$

- 公开主定理的假设、声明链接和公理审计结果。

## M5 — 方法扩展与高维泛化

根据研究需要按需推进，而不是按原书顺序推进：

- Aubin–Nitsche 对偶方法与 $L^2$ 误差估计；
- Strang 引理和非协调方法（如 Crouzeix–Raviart）；
- inf-sup / Babuška–Brezzi 理论、Fortin 插值、Raviart–Thomas 与 Stokes；
- 高阶 Lagrange 单元（$P_k$）与 `Assembly/` 中的静态凝聚（复用 Mathlib 的
  `Matrix.SchurComplement` 与 `Matrix.PosDef`）；
- `Aposteriori/` 中的后验误差估计与自适应方法；
- 将二维几何、单形和 Sobolev 层泛化到一般 $d$ 维。

## M6 — 快速求解器与线弹性

- `Solver/`：共轭梯度误差界、Uzawa 鞍点迭代与多重网格（Galerkin 粗网格修正、
  两网格与 V/W 循环收敛；待 `Assembly/` 矩阵接口就绪后可并行推进）；
- `Models/Elasticity/`：三维向量值 Sobolev 空间、线弹性应变与各向同性 Hooke 能量、
  Korn 不等式以及无锁死混合方法。

经典有限差分方法（Braess 第 I 章）不在核心路线图范围内。只有主要结果无占位构建、
通过公理审计、接受数学语义审查并被下游实际使用后，相应里程碑才算完成。
