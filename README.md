# skill-forge

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`skill-forge` 是一个用于锻造 agent 运行环境的 Claude Code plugin marketplace。它把可复用的技能沉淀为插件，覆盖仓库知识、代码质量、提交纪律、自动修复循环，以及 OpenCode 配置定制。

**核心理念：** Human at the helm. Agents execute. 仓库是 agent 的运行环境，知识、规则和操作流程必须被打磨成 agent 可以稳定读取、判断和执行的形态。

**关键词：** `claude-plugin`, `claude-code`, `agent-skills`, `agent-harness`, `openai-harness-engineering`, `opencode`, `code-review`, `clean-commit`

## Quick Start

```bash
# 1. 添加 Skill Forge marketplace
claude plugin marketplace add gzb1128/skill-forge

# 2. 安装需要的插件
claude plugin install agent-docs@skill-forge
claude plugin install code-quality@skill-forge
claude plugin install opencode-customize@skill-forge

# 3. 在目标仓库中调用技能
#    "bootstrap agent docs"       -> 脚手架化 Agent-First 文档
#    "review my changes"          -> 审查本地 diff 的质量风险
#    "commit this"                -> 通过质量门禁后提交
#    "loopfix"                    -> 自动 review-fix 循环
#    "hydrate model config"       -> 补全 OpenCode 自定义模型参数
```

插件版本由 git commit SHA 决定。每次 push 都会生成新的可安装版本，无需手动维护 semver。运行 `claude plugin update <plugin>@skill-forge` 可以拉取最新版本。

## Plugins

| Plugin | Purpose | Skills |
|---|---|---|
| `agent-docs` | 为仓库建立 Agent-First 文档底座，并维护不可推导的团队知识 | `bootstrap-agent-docs`, `learn`, `remember` |
| `code-quality` | 把代码审查、提交门禁、diff 清理和自动修复循环做成可重复执行的 agent 工作流 | `quality-reviewer`, `clean-commit`, `diff-cleanup`, `loopfix` |
| `opencode-customize` | 辅助定制 OpenCode 配置，尤其是补全自定义 provider 的模型元数据 | `hydrate-opencode-models` |

## Skill Catalog

### `agent-docs`

| Skill | Type | Purpose |
|---|---|---|
| `bootstrap-agent-docs` | model-invoked | 在目标仓库中生成 `AGENTS.md`、`docs/_templates/`、`docs/rules/` 和各类 `INDEX.md` |
| `learn` | manual skill (`/agent-docs:learn`) | 将会话中发现的非显性知识写入合适的 `AGENTS.md`，写入前必须验证并经过用户确认 |
| `remember` | manual skill (`/agent-docs:remember`) | 审计 `AGENTS.md` 中的记忆内容，清理过期、重复或位置错误的信息 |

`bootstrap-agent-docs` 使用的模板载荷位于 `plugins/agent-docs/templates/`，运行时通过 `${CLAUDE_PLUGIN_ROOT}/templates/` 定位，不依赖额外 clone。

### `code-quality`

| Skill | Type | Purpose |
|---|---|---|
| `quality-reviewer` | model-invoked | 对本地变更执行结构化质量审查：三轮 review、diff hygiene、lint、test、caller check |
| `clean-commit` | model-invoked | 在提交前调用质量门禁，并生成解释 WHY 的提交信息 |
| `diff-cleanup` | model-invoked | 清理 feature branch 中的 AI slop：冗余注释、死代码、防御性噪音和重复逻辑 |
| `loopfix` | model-invoked | 运行自动 review-fix 循环：子代理发现问题，主代理判断并修复，直到审查干净 |

### `opencode-customize`

| Skill | Type | Purpose |
|---|---|---|
| `hydrate-opencode-models` | model-invoked | 从 Models.dev 目录中查找模型元数据，并映射到 OpenCode custom provider 的 model 配置 |

## What `agent-docs` Scaffolds

当你在目标仓库中请求 “bootstrap agent docs” 时，插件会生成：

```text
your-repo/
├── AGENTS.md                          # agent 的根入口和约 100 行导航
└── docs/
    ├── codemaps/INDEX.md              # 架构地图：概念 -> 文件路径
    ├── design/INDEX.md                # 设计文档：YYYY-MM-DD-<topic>-design.md
    ├── plans/INDEX.md                 # 实施计划：YYYY-MM-DD-<feature>.md
    ├── rules/                         # 工程规则
    │   ├── INDEX.md
    │   ├── non-derivability.md        # 不可推导原则
    │   ├── document-conventions.md
    │   └── openai-harness-engineering.md
    ├── troubleshoot/INDEX.md          # 按症状索引的排障记录
    ├── runbooks/INDEX.md              # 确定性操作流程
    ├── lib/INDEX.md                   # 第三方库使用约束
    ├── verify/INDEX.md                # dry-run 验证流程
    └── _templates/                    # 新文档模板
        ├── codemap.md
        ├── design.md
        ├── plan.md
        └── subpackage-AGENTS.md
```

## Practices

| Practice | Meaning |
|----------|---------|
| **Repo as record system** | agent 看不到的知识等于不存在，关键约束不能只留在聊天记录或外部文档里。 |
| **Progressive disclosure** | `AGENTS.md` 负责入口导航，`docs/codemaps/*.md` 指向组件，再由源码承载细节。 |
| **INDEX per category** | 每个 `docs/*/` 目录都有 `INDEX.md`，用 “When to Use” 帮助 agent 快速判断是否需要读取。 |
| **Non-derivability filter** | 只记录无法从源码、git 历史或现有文档推导出来的信息。 |
| **Maps, not encyclopedias** | codemap 只维护概念到路径的地图，不复制源码和配置。 |
| **Date-prefixed designs/plans** | `YYYY-MM-DD-<topic>-design.md` 让设计和计划按时间可浏览、可追溯。 |

完整理念见 [`openai-harness-engineering.md`](plugins/agent-docs/templates/docs/rules/openai-harness-engineering.md)。

## Development

本仓库同时是 marketplace catalog 和 plugin source。开发流程、验证命令、SHA 版本策略见 [AGENTS.md](AGENTS.md)。

常用验证命令：

```bash
make validate
make test-skills-link
make test-skills-status
make test-skills-unlink
```

## License

This project is licensed under the [MIT License](LICENSE).
