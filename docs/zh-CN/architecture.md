# 项目架构

[English version](../architecture.md)

## 设计目标

FemLean 应通过增加模块成长，而不是每增加一个结果就反复修改所有旧模块。仓库按
数学依赖组织，不按 Braess 原书的章节顺序组织。

## 分层结构

```text
FemLean/
├── Core/                 抽象变分形式与混合形式
├── Analysis/             Sobolev 空间、迹、不等式和正则性
├── Geometry/             单形、网格和形状正则网格族
├── FiniteElement/        不依赖具体 PDE 模型的单元
├── Approximation/        插值与逼近理论
├── Error/                可复用的抽象误差和后验误差结果
├── Models/               Poisson、Stokes、弹性及其纵向组合
├── Solver/               代数迭代法和多重网格
└── Computation/          可执行实现及其验证
```

只创建当前工作真正需要的模块，不以预先建立完整空目录树为目标。

## 依赖规则

1. `Core` 只能依赖 Mathlib 和其他核心模块，不能导入网格、单元或具体模型。
2. `Geometry` 不依赖 PDE 或 Galerkin 方法。
3. `FiniteElement` 可以使用几何和分析，但不能依赖具体模型。
4. `Approximation` 可以使用有限元接口，但不能依赖模型专用误差定理。
5. `Solver` 应依赖离散算子和线性代数接口，而不是三角形单元实现。
6. `Models` 将通用组件组合成具体结果；通用结果不能导入 `Models`。
7. `examples`、`tests` 和 `experiments` 是叶子模块，库模块不能导入它们。
8. `FemLean.lean` 是公共便利根模块，内部模块应导入精确依赖。

Lean 会禁止循环导入，但不会禁止不合理的层级倒置，因此架构维护应包括导入图审查。

## 模型的纵向组合

具体模型可以组合多个阶段，而不必把这些依赖强加给通用代码。例如：

```text
核心变分理论 ────────────────────┐
                                 │
分析与 P1 逼近 ──────────────────┼── Models/Poisson/Error.lean
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
- 证明多重网格收敛不需要知道节点基函数；
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
