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

- Mathlib 的 `Mathlib.Analysis.Distribution.Sobolev` 通过 Fourier 变换定义
  Bessel 位势空间；
- [EllipticPDE](https://github.com/alejandro-soto-franco/EllipticPDE) 在 Mathlib
  之上建立了弱导数 Sobolev 层和椭圆 Dirichlet 理论；
- 项目可能需要本地层，但复制一套互不兼容的 Sobolev 层级会产生很高的下游成本。

## 需要制作原型的方案

1. 通过固定版本的依赖复用现有外部项目，并暴露一个小型 FemLean 适配层；
2. 基于当前 Mathlib 定义，在必要处补充有界区域上的弱导数；
3. 建立项目本地弱导数接口，并显式证明它与生态定义的等价性或转换结果。

## 评估标准

- 能否表达有界 Lipschitz 区域上的 \(H^1(\Omega)\)、\(H_0^1(\Omega)\)、迹和
  分片有限元函数；
- Poincaré、Rellich–Kondrachov 和 Lax–Milgram 基础设施的可用性；
- 整合现有证明时能否保留并清楚展示其假设；
- 维护成本和工具链兼容性；
- 下游误差估计陈述的质量。

## 必要原型

接受方案之前，使用每个认真考虑的候选表示写出预期的 Poisson 弱命题，以及协调
分片多项式空间的成员关系命题。比较实际 Lean 类型，而不只比较自然语言描述。

## 决定记录

等待数学语义和 Lean API 审查。
