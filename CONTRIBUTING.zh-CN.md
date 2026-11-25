# FemLean 贡献指南

[English version](CONTRIBUTING.md)

FemLean 使用 GitHub 作为任务、数学设计、审查和进度的正式记录。即时聊天适合快速
沟通，但涉及定义、接口或里程碑的决定，必须回到 issue、PR 或 RFC 中保存。

## 配置开发环境

安装 `elan` 后运行：

```bash
git clone https://github.com/FormalCompMath/fem-lean.git
cd fem-lean
lake exe cache get
lake build
lake env lean tests/Smoke.lean
```

不要手工编辑 `lake-manifest.json`。依赖更新应放在独立 PR 中，并说明更新原因。

## 选择并认领任务

1. 选择带有 `status: ready` 标签的 issue，分配给自己；开始前也可先评论实现思路。
2. 查看关联的依赖 issue 和蓝图节点。
3. 保持任务小而明确：一个 PR 通常只完成一个定义、一个数学结果或一项集中的
   基础设施修改。
4. 使用短期任务分支，不要维护长期与主库分离的个人版本。

被阻塞的任务应标记为 `status: blocked`，并写清楚等待的是哪个定义、定理或设计
决定。

## 采用“陈述优先”的 Pull Request

数学工作应尽早创建 Draft PR，第一版通常包含：

- 非形式化数学陈述和准确来源；
- 拟采用的定义与定理陈述；
- 假设以及相对于来源的差异；
- 一个具体的预期用途；
- issue 和蓝图节点链接。

证明占位符可以暂时出现在 Draft PR 中，但绝不能进入 `main`。投入长篇证明之前，
先请求 `status: statement review`；数学语义审查通过后，再完成证明并请求最终审查。

## Pull Request 要求

每个 PR 必须：

- 通过 Lean 构建、冒烟测试和公理审计；
- 保持 `main` 始终可用；
- 在相关时更新蓝图节点和声明链接；
- 为新的数学接口提供可编译示例；
- 将数学修改与无关重构、依赖更新分开；
- 获得至少一名非作者审查者的批准。

`FemLean/Core`、共享几何或有限元接口以及已接受 RFC 的修改需要格外谨慎。破坏性
核心修改通常需要 RFC、两人批准和 PR 中的迁移说明。

## 审查职责

Lean 内核检查证明，但不检查定义是否代表预期的数学对象。因此应先审查定义和
陈述，再审查 tactic 证明。详见[审查与信任政策](docs/zh-CN/review.md)。

如果定理陈述没有变化，CI 已经确认证明正确性；最终审查应关注可维护性、不必要的
全局实例或记法、库复用以及依赖方向。

## 依赖与模块规则

阅读[项目架构](docs/zh-CN/architecture.md)。尤其注意：

- 抽象变分代码不能导入具体网格、单元或模型；
- 有限元不能依赖某个具体 PDE 模型；
- 代数求解器不应依赖几何单元实现；
- 示例和实验是下游叶子模块，库模块不能导入它们；
- 内部模块应导入精确依赖，而不是公共便利根模块。

## 设计讨论与 RFC

探索性问题使用 GitHub Discussions。形成具体验收标准后，再转成 issue。对逆转成本
很高的设计决定使用 RFC，尤其是 Sobolev 空间、网格和有限元表示。

RFC 应记录问题、候选方案、小型原型、取舍、决定和迁移影响。最终决定不能只存在
于聊天记录中。中文 RFC 见[设计 RFC 索引](docs/zh-CN/rfcs/README.md)。

## 数学蓝图

蓝图是数学进度的唯一事实来源，GitHub Projects 负责任务流转。常用本地命令为：

```bash
python3 -m venv .venv
.venv/bin/pip install leanblueprint
.venv/bin/leanblueprint pdf
.venv/bin/leanblueprint web
lake build
.venv/bin/leanblueprint checkdecls
```

使用 `\lean{...}` 将节点关联到 Lean 声明；只有定义或证明完成后才使用 `\leanok`；
使用 `\uses{...}` 表示数学依赖。不能仅因命题陈述能够编译，就把节点标为完成。
蓝图不维护两份语言版本，避免形式化状态发生分叉。

## 会议与协作

简短的定期会议用于处理受阻审查、核心设计决定和下一批可并行任务。日常工作尽量
异步进行并公开展示在 GitHub 上。新贡献者应先处理示例、文档或独立引理，再修改
核心数学表示。
