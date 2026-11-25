# 设计 RFC

[English version](../../rfcs/README.md)

当数学表示或公共接口的逆转成本很高时，需要通过 RFC 作出设计决定。普通引理添加
不需要 RFC。

每份 RFC 应包含：

1. 问题和下游使用场景；
2. 约束条件与现有生态方案；
3. 真正不同的候选设计；
4. 有用时提供小型 Lean 接口原型；
5. 方案取舍和迁移影响；
6. 决定、日期、审查者和后续任务。

状态值为 `Draft`（草稿）、`Under review`（审查中）、`Accepted`（已接受）、
`Rejected`（已拒绝）和 `Superseded`（已被取代）。聊天中的决定只有记录到 RFC 后
才算最终确定。

当前 RFC：

- [0001：Sobolev 空间表示](0001-sobolev-representation.md)
- [0002：网格表示](0002-mesh-representation.md)
- [0003：双线性型的有界性与强制性](0003-bilinear-form-interface.md)
