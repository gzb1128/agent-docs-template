# 记忆命令改进实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 按照 `docs/design/2026-05-28-memory-commands-design.md` 改进 `plugins/agent-docs-tools/skills/learn/SKILL.md` 与 `plugins/agent-docs-tools/skills/remember/SKILL.md`。

**Architecture:** 只修改两个手动触发命令体，不引入 agent 集成、hook、自动触发、运行时存储、向量数据库或外部记忆系统。`/learn` 负责会话候选记忆的分类、验证、diff 提案和确认后写入；`/remember` 负责 `AGENTS.md` 记忆表面的健康审计和确认后清理。

**Tech Stack:** Markdown command bodies, `AGENTS.md`, repository documentation conventions.

---

### Task 1: 更新 `/learn` 命令

**Files:**
- Modify: `plugins/agent-docs-tools/skills/learn/SKILL.md`

- [x] **Step 1: 保留手动触发边界**

确认文件顶部仍说明该文件是 manual-trigger command，且没有建议自动加载、hook、后台任务或 agent runtime 集成。

- [x] **Step 2: 加入候选洞察分类**

在不可推导原则之后加入分类表：`Hidden Knowledge`、`Quick Reference`、`Rule`、`Doc`、`Skip`。`Rule` 和 `Doc` 只能报告建议去向，不能由 `/learn` 自动创建或修改对应文档。

- [x] **Step 3: 强化写入前验证**

把验证要求改成必须为每个保留候选项记录证据：路径存在、符号存在、行为确认、命令运行或无法验证的原因。无法验证的候选项必须跳过。

- [x] **Step 4: 改为 diff-first approval**

在流程中要求先展示目标文件、目标 section、原因、验证证据和 diff，再请求用户确认。即使用户希望快速应用，也不能跳过 diff 和确认。

- [x] **Step 5: 收尾检查**

确认 `/learn` 仍只写入 `AGENTS.md` 记忆表面，且不会鼓励把可推导代码结构写入 `Hidden Knowledge`。

### Task 2: 更新 `/remember` 命令

**Files:**
- Modify: `plugins/agent-docs-tools/skills/remember/SKILL.md`

- [x] **Step 1: 保留报告优先边界**

确认文件顶部和用户确认步骤仍明确：默认只输出报告，不经用户批准不编辑文件。

- [x] **Step 2: 扩展审计范围**

把审计范围从仅 `## Hidden Knowledge` 扩展为 `Quick Reference`、`Architecture`、`Key Patterns`、`Golden Rules`、`Hidden Knowledge`、sub-package `AGENTS.md`。

- [x] **Step 3: 加入健康维度**

增加 `Signal`、`Placement`、`Currency`、`Non-Derivability`、`Duplication`、`Actionability` 六个维度，用于统一评估每个问题。

- [x] **Step 4: 更新报告格式**

把输出格式升级为 `Memory Health Report`，包含 `Promotions`、`Deletions`、`Rewrites`、`Duplicates`、`Conflicts`、`No Action Needed`。

- [x] **Step 5: 收尾检查**

确认 `/remember` 不承诺自动删除、不自动合并冲突、不运行任何外部记忆系统。

### Task 3: 验证和审查

**Files:**
- Inspect: `plugins/agent-docs-tools/skills/learn/SKILL.md`
- Inspect: `plugins/agent-docs-tools/skills/remember/SKILL.md`

- [x] **Step 1: 检查占位符**

Run: `rg -n "TO[D]O|T[B]D|FIX[M]E|\\{\\{" plugins/agent-docs-tools/skills/learn/SKILL.md plugins/agent-docs-tools/skills/remember/SKILL.md`

Expected: no output.

- [x] **Step 2: 检查禁止的集成范围**

Run: `rg -n "vector|database|MCP|hook|background|auto-trigger|runtime storage|external memory" plugins/agent-docs-tools/skills/learn/SKILL.md plugins/agent-docs-tools/skills/remember/SKILL.md`

Expected: only prohibition text is acceptable; no instruction should add those systems.

- [x] **Step 3: 检查 markdown whitespace**

Run: `git diff --check -- plugins/agent-docs-tools/skills/learn/SKILL.md plugins/agent-docs-tools/skills/remember/SKILL.md`

Expected: no output.

- [x] **Step 4: 运行 loopfix reviewer**

Request a reviewer pass scoped to the two command files and the design. Fix in-scope findings and repeat until the latest pass has no current-goal findings.
