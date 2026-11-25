---
title: FemLean 中文文档
usemathjax: true
permalink: /zh-CN/
---

[English homepage]({{ site.url }}/)

FemLean 是一个可复用、由机器检查的 Lean 4 有限元理论库。第一条纵向路线是抽象
Galerkin 理论、Poisson 模型问题和二维 \(P_1\) 能量误差估计。

项目以 Braess 的《Finite Elements》为数学路线图，Lean 模块按依赖关系而不是原书
章节组织。

## 中文文档

- [项目说明](https://github.com/FormalCompMath/fem-lean/blob/main/README.zh-CN.md)
- [贡献指南](https://github.com/FormalCompMath/fem-lean/blob/main/CONTRIBUTING.zh-CN.md)
- [项目架构](https://github.com/FormalCompMath/fem-lean/blob/main/docs/zh-CN/architecture.md)
- [审查与信任政策](https://github.com/FormalCompMath/fem-lean/blob/main/docs/zh-CN/review.md)
- [发展路线图](https://github.com/FormalCompMath/fem-lean/blob/main/docs/zh-CN/roadmap.md)
- [Lean 项目规范](https://github.com/FormalCompMath/fem-lean/blob/main/docs/zh-CN/conventions.md)
- [设计 RFC](https://github.com/FormalCompMath/fem-lean/blob/main/docs/zh-CN/rfcs/README.md)

## 协作与实时进度

- [GitHub 仓库](https://github.com/FormalCompMath/fem-lean)
- [实时任务看板](https://github.com/orgs/FormalCompMath/projects/1)
- [开放任务](https://github.com/FormalCompMath/fem-lean/issues)
- [设计讨论](https://github.com/FormalCompMath/fem-lean/discussions)
- [数学蓝图]({{ site.url }}/blueprint/)
- [蓝图 PDF]({{ site.url }}/blueprint.pdf)
- [数学依赖图]({{ site.url }}/blueprint/dep_graph_document.html)
- [Lean API 文档]({{ site.url }}/docs/)

蓝图只维护一份数学状态。`\leanok` 表示相应形式化工作已完成，独立数学语义审查
则通过 PR 和审查政策记录。主分支由构建和公理审计保护，但两者都不能替代人类对
定义和定理陈述的审查。
