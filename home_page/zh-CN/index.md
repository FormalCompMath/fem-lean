---
layout: default
title: 中文文档
nav_order: 3
permalink: /zh-CN/
usemathjax: true
---

<div lang="zh-CN" markdown="1">

# FemLean 中文文档

可复用、由机器检查的 Lean 4 有限元理论库。
{: .fs-6 .fw-300 }

[项目说明](https://github.com/FormalCompMath/fem-lean/blob/main/README.zh-CN.md){: .btn .btn-primary }
[贡献指南](https://github.com/FormalCompMath/fem-lean/blob/main/CONTRIBUTING.zh-CN.md){: .btn }
[English home]({{ '/' | relative_url }}){: .btn .btn-outline }

{: .note }
项目正在进入 M1：抽象 Galerkin 理论和 Céa 引理，随后处理 Poisson 模型与二维
$$P_1$$ 能量误差估计。

## 数学路线

项目以 Braess 的《Finite Elements》为数学路线图，Lean 模块按依赖关系而不是原书
章节组织。第一条纵向路线将抽象 Galerkin 理论连接到具体的协调有限元方法。

## 中文项目文档

- [项目说明](https://github.com/FormalCompMath/fem-lean/blob/main/README.zh-CN.md)
- [贡献指南](https://github.com/FormalCompMath/fem-lean/blob/main/CONTRIBUTING.zh-CN.md)
- [项目架构](https://github.com/FormalCompMath/fem-lean/blob/main/docs/zh-CN/architecture.md)
- [审查与信任政策](https://github.com/FormalCompMath/fem-lean/blob/main/docs/zh-CN/review.md)
- [发展路线图](https://github.com/FormalCompMath/fem-lean/blob/main/docs/zh-CN/roadmap.md)
- [Lean 项目规范](https://github.com/FormalCompMath/fem-lean/blob/main/docs/zh-CN/conventions.md)
- [设计 RFC](https://github.com/FormalCompMath/fem-lean/blob/main/docs/zh-CN/rfcs/README.md)
- [更新日志](https://github.com/FormalCompMath/fem-lean/blob/main/CHANGELOG.zh-CN.md)

## 协作与实时进度

- [实时任务看板](https://github.com/orgs/FormalCompMath/projects/1)
- [开放任务](https://github.com/FormalCompMath/fem-lean/issues)
- [设计讨论](https://github.com/FormalCompMath/fem-lean/discussions)
- [数学蓝图]({{ '/blueprint/' | relative_url }})
- [蓝图 PDF]({{ '/blueprint.pdf' | relative_url }})
- [数学依赖图]({{ '/blueprint/dep_graph_document.html' | relative_url }})
- [Lean API 文档]({{ '/docs/' | relative_url }})

蓝图只维护一份数学状态。`\leanok` 表示形式化工作已完成，独立数学语义审查则通过
PR 记录。构建和公理审计不能替代人类对定义和定理陈述的审查。

</div>
