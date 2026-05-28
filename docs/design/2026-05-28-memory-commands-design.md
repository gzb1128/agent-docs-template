# Design: 记忆命令能力改进

**Status:** Approved
**Date:** 2026-05-28
**Author:** OpenCode

## Problem

当前插件通过 `plugins/agent-docs-tools/skills/learn/SKILL.md` 和 `plugins/agent-docs-tools/skills/remember/SKILL.md` 提供记忆能力：`/agent-docs-tools:learn` 在会话结束时沉淀非显性知识，`/agent-docs-tools:remember` 周期性审计已有 `AGENTS.md` 内容。这个方向是正确的，但两个命令的职责边界还不够完整：`/agent-docs-tools:learn` 更偏向“写入”，缺少写入前的结构化提案；`/agent-docs-tools:remember` 更偏向审计 `## Hidden Knowledge`，对 `Quick Reference`、`Key Patterns`、`Golden Rules` 等记忆表面覆盖不足。

对比 `claude-md-management` 后，值得吸收的是可审查 diff、质量维度和代码库交叉验证；但不能引入其较宽松的记录标准，否则会削弱本模板的核心优势：严格执行不可推导原则，避免 `AGENTS.md` 变成百科全书。

## Goals

- 提升 `/learn` 的写入质量：先分类、验证、展示 diff，再经用户确认后写入。
- 提升 `/remember` 的审计范围：从只审计 `Hidden Knowledge` 扩展为审计所有 `AGENTS.md` 记忆表面。
- 保留手动触发模型：命令仍然只是 markdown 命令体，不自动集成到任何 agent runtime。
- 保留不可推导原则：只有无法从代码、git 历史或现有文档推导的信息才能进入 `Hidden Knowledge`。

## Non-Goals

- 不实现 agent 集成、自动触发、后台任务、hook、MCP、向量数据库或长期外部记忆存储。
- 不把 `/learn` 或 `/remember` 提升为自动加载 skill。
- 不要求每次开发都必须运行记忆命令。
- 不把所有文档质量问题都放进本设计；本设计只覆盖 `AGENTS.md` 记忆命令。

## Proposed Design

### Architecture

记忆能力保持为两个手动命令：

| Command | Role | Default Write Behavior |
|---------|------|------------------------|
| `/learn` | 从当前会话提炼候选知识，并提出写入建议 | 先展示 diff，获得用户确认后写入 |
| `/remember` | 审计已有 `AGENTS.md` 记忆表面，提出清理建议 | 默认只报告，获得用户确认后才修改 |

两者共享同一条记忆生命周期：

```text
candidate insight -> classify -> non-derivability filter -> verify -> route -> propose diff -> approve -> apply/audit later
```

### `/learn` Flow

`/learn` 应从“直接追加洞察”升级为“先生成可审查的记忆提案”。当候选内容明显属于其他文档体系时，只报告建议去向，不在 `/learn` 流程中创建或修改那些文档。流程如下：

1. 回顾当前会话，提取候选洞察。
2. 将每个候选洞察分类为 `Hidden Knowledge`、`Quick Reference`、`Rule`、`Doc` 或 `Skip`。
3. 对 `Hidden Knowledge` 应用不可推导测试；可从代码、git 历史或现有文档推导的信息必须跳过。
4. 对保留的候选项收集验证证据，例如路径存在、符号存在、命令可运行、行为仍然成立。
5. 为每个建议变更展示目标文件、目标 section、原因和 diff。
6. 请求用户确认后再编辑文件。
7. 报告实际写入位置和跳过原因。

分类规则：

| Classification | Destination | Rule |
|----------------|-------------|------|
| `Hidden Knowledge` | 最近作用域的 `AGENTS.md` 的 `## Hidden Knowledge` | 只记录无法推导的隐藏依赖、误导性错误、特殊顺序和项目怪癖 |
| `Quick Reference` | root `AGENTS.md` Quick Reference 表 | 构建、测试、lint、运行等常用命令 |
| `Rule` | 仅报告建议去向 | 团队约定或必须遵守的边界；不由 `/learn` 自动创建规则文档 |
| `Doc` | 仅报告建议去向 | 设计、故障排查、runbook、库怪癖等较长知识；不由 `/learn` 自动创建文档 |
| `Skip` | 不写入 | 可推导、一次性、重复、过时或泛化建议 |

### `/remember` Flow

`/remember` 应从只检查 `## Hidden Knowledge` 扩展为检查所有 `AGENTS.md` 记忆表面。它仍然默认不写文件，只输出报告。

审计范围：

| Surface | Checks |
|---------|--------|
| `Quick Reference` | 命令是否仍存在、占位符是否清理、命令是否可执行或可合理验证 |
| `Architecture` | 是否仍是入口地图，而不是复制源代码细节 |
| `Key Patterns` | 是否项目特定、仍然成立、没有被机械规则取代 |
| `Golden Rules` | 是否仍是硬规则、是否重复 `docs/rules/`、是否需要降级为链接 |
| `Hidden Knowledge` | 是否不可推导、仍可验证、没有重复、位置正确 |
| Sub-package `AGENTS.md` | 是否仍满足复杂度或跨模块约束阈值 |

报告格式升级为 `Memory Health Report`：

| Dimension | Meaning |
|-----------|---------|
| Signal | 内容是否值得占用 prompt 空间 |
| Placement | 是否位于正确层级和 section |
| Currency | 路径、命令、行为是否仍然真实 |
| Non-Derivability | 是否已经能从代码、git 或文档推导 |
| Duplication | 是否与其他 `AGENTS.md` 或规则文档重复 |
| Actionability | 未来 agent 是否能直接执行或遵守 |

报告应按以下分组输出：

```markdown
## Memory Health Report

### Promotions
### Deletions
### Rewrites
### Duplicates
### Conflicts
### No Action Needed
```

### Data Flow

`/learn` 是生产者：它从会话上下文生成候选记忆，并在用户确认后把经过验证的内容写入正确位置。`/remember` 是垃圾回收器：它扫描已有记忆，提出删除或改写已经过时、可推导、重复或放错位置内容的建议。两者通过 `AGENTS.md` 作为唯一共享状态，不依赖外部系统。

```text
session context --/learn--> AGENTS.md memory surfaces --/remember--> cleanup proposals
```

### Error Handling

- 如果候选洞察无法验证，`/learn` 必须跳过，并说明缺少哪类证据。
- 如果无法确定目标位置，`/learn` 应提出候选位置并请求用户确认，而不是猜测写入。
- 如果 `/remember` 发现冲突，它应保留两个版本并请求用户判断，不应自行合并。
- 如果命令无法实际运行，应记录“未验证”和原因，而不是声称命令有效。
- 如果没有可写入或可清理的内容，应明确报告“无行动”，避免为了产出而污染文档。

### Testing Strategy

本设计主要通过提示体样例和人工审查验证，不需要新增运行时测试。后续实现应至少做以下检查：

- 用一个包含 `Quick Reference`、`Golden Rules`、`Hidden Knowledge` 的示例 `AGENTS.md` 手动演练 `/remember` 报告。
- 用一个包含可推导、不可推导、重复和无法验证候选项的会话样例手动演练 `/learn` 分类。
- 检查命令体是否仍然明确要求手动触发，且没有暗示自动集成。
- 检查所有新增说明是否遵守不可推导原则，没有鼓励把代码结构复制进 `AGENTS.md`。
- 检查实现 diff 是否只修改 `plugins/agent-docs-tools/skills/learn/SKILL.md` 和 `plugins/agent-docs-tools/skills/remember/SKILL.md`，除非用户另行批准文档索引或说明文件更新。
- 检查两个命令是否都明确禁止 agent 集成、hook、自动触发、运行时存储、向量数据库或外部记忆系统。
- 检查 `/remember` 是否保持报告优先，且没有在用户确认前编辑文件。

## Alternatives Considered

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| 最小补丁：只给 `/learn` 增加 diff、给 `/remember` 增加少量 stale 检查 | 改动小，风险低 | 不能解决记忆表面覆盖不足的问题 | Rejected |
| 结构化生命周期：统一 capture、classify、verify、route、audit | 覆盖核心问题，仍保持命令简单 | 需要改写两个命令体 | Chosen |
| 完整治理体系：增加评分、fixture、单独 audit 命令和模板库 | 最全面 | 对当前模板过重，容易偏离“只提供命令和 skill”的边界 | Rejected |

## Migration / Rollout

1. 更新 `plugins/agent-docs-tools/skills/learn/SKILL.md`，加入分类表、验证证据、diff 提案和用户确认步骤。
2. 更新 `plugins/agent-docs-tools/skills/remember/SKILL.md`，把审计范围扩展到所有 `AGENTS.md` 记忆表面，并输出 `Memory Health Report`。
3. 实现阶段默认只触碰上述两个命令文件；任何说明文件、索引或规则文档更新都需要单独确认。

## Open Questions

- `/remember` 是否需要给出分数？当前设计选择不给总分，只给维度化报告，避免把审计变成形式化打分。

已决策：`/learn` 不跳过 diff 和用户确认。即使用户希望快速应用，也必须先看到具体变更并批准。

## Related

- Skill: `plugins/agent-docs-tools/skills/learn/SKILL.md`
- Skill: `plugins/agent-docs-tools/skills/remember/SKILL.md`
- Rule: `docs/rules/non-derivability.md`
- Rule: `docs/rules/document-conventions.md`
