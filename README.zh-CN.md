# FormalCompMath FemLean

[English version](README.md)

FemLean 是一个可复用、由机器检查的 Lean 4 有限元理论库。项目以 Dietrich Braess
的《Finite Elements》为数学路线图，而不是把原书逐页翻译成 Lean 文件。

## 当前状态

项目基础设施已经就位，正在进入第一个数学里程碑 M1：首先建立抽象 Galerkin
理论并以 Céa 引理为核心结果，随后处理 Poisson 模型和二维 \(P_1\) 能量误差估计。

- [贡献指南](CONTRIBUTING.zh-CN.md)
- [项目架构](docs/zh-CN/architecture.md)
- [审查与信任政策](docs/zh-CN/review.md)
- [发展路线图](docs/zh-CN/roadmap.md)
- [中文文档索引](docs/zh-CN/README.md)
- [实时任务看板](https://github.com/orgs/FormalCompMath/projects/1)
- [数学蓝图](https://formalcompmath.github.io/fem-lean/blueprint/)

## 本地开发

项目固定使用 Lean 4.36.0 和 Mathlib 4.36.0。

```bash
lake exe cache get
lake build
lake env lean tests/Smoke.lean
```

## 信任政策

`main` 分支必须能够在没有 `sorry`、`admit` 或项目自定义公理的情况下构建。
CI 会审计 `FemLean` 命名空间下的声明，只允许 Lean 的标准公理
`propext`、`Classical.choice` 和 `Quot.sound`。

Lean 内核负责检查证明是否成立，人类审查负责确认定义和定理陈述是否表达了
预期的数学含义。

## 参考资料

受版权保护的原书 PDF 仅保存在本地 `references/`，不由 Git 跟踪。蓝图条目
使用自己的语言转述数学命题并注明版本、章节和页码，不整段复制原书。

## 许可证

项目采用 Apache-2.0，详见 [LICENSE](LICENSE)。
