# skill-forge

> **Agent-First Engineering**: 本仓库遵循 [OpenAI Harness Engineering](plugins/agent-docs/templates/docs/rules/openai-harness-engineering.md) ——
> "Human at the helm. Agents execute."

`skill-forge` 是一个 Claude Code plugin marketplace，用于锻造 agent 的运行环境。仓库同时承载 marketplace catalog、插件源码、技能验证流程和 Agent-First 文档模板。

## 当前插件

| Plugin | Purpose | Skills |
|---|---|---|
| `agent-docs` | Agent-First 文档脚手架和知识管理 | `bootstrap-agent-docs`, `learn`, `remember` |
| `code-quality` | 代码审查、提交门禁、diff 清理和自动修复循环 | `quality-reviewer`, `clean-commit`, `diff-cleanup`, `loopfix` |
| `opencode-customize` | OpenCode 配置定制，尤其是自定义 provider 的模型参数补全 | `hydrate-opencode-models` |

## What's here

| Path | Purpose |
|------|---------|
| `.claude-plugin/marketplace.json` | Marketplace catalog (`skill-forge`) |
| `plugins/agent-docs/` | 文档插件：`bootstrap-agent-docs`, `learn`, `remember` |
| `plugins/agent-docs/templates/` | `bootstrap-agent-docs` rsync 的模板载荷 |
| `plugins/code-quality/` | 质量插件：`quality-reviewer`, `clean-commit`, `diff-cleanup`, `loopfix` |
| `plugins/opencode-customize/` | OpenCode 定制插件：`hydrate-opencode-models` |
| `docs/design/`, `docs/plans/` | 本仓库演进用的设计文档和实施计划 |
| `docs/verify/` | RED→GREEN→REFACTOR 技能测试流程和场景构造脚本 |
| `Makefile` | `validate` + `test-skills-link/unlink/status` 验证入口 |
| `README.md` | 面向用户的安装和使用说明 |

## Quick Reference

| Action | Command |
|--------|---------|
| Validate marketplace + plugins | `make validate` |
| Link skills into `~/.agents/skills/` for testing | `make test-skills-link` then restart opencode |
| Check current symlink state | `make test-skills-status` |
| Build a scenario for GREEN testing | `bash docs/verify/scenarios/<skill>/build-<letter>.sh` |
| Remove test symlinks | `make test-skills-unlink` |
| Smoke-test install (local path) | `claude plugin marketplace add $(pwd)` then `claude plugin install <plugin>@skill-forge` |
| Inspect installed plugins | `claude plugin list --json \| jq '.[] \| select(.id \| endswith("@skill-forge"))'` |

## Plugin Marketplace

本仓库就是 marketplace。`.claude-plugin/marketplace.json` 列出 `agent-docs`、`code-quality` 和 `opencode-customize` 三个插件。

### Versioning: git commit SHA, not semver

所有插件都**刻意省略 `version` 字段**。Claude Code 会把插件版本解析为 git commit SHA，因此每次 push 都会自动成为新版本，不需要维护 release tag 或 semver。

> `claude plugin validate` 可能提示 `No version specified`。这是预期行为，不是错误。

### Local verification workflow

修改 `plugins/` 下任何文件后，提交前必须验证：

```bash
# 1. Validate the marketplace catalog
claude plugin validate .

# 2. Validate every plugin
for plugin in plugins/*; do
  [ -d "$plugin/.claude-plugin" ] && claude plugin validate "$plugin"
done

# 3. Smoke-test install from the local working tree
claude plugin marketplace add "$(pwd)"
claude plugin install agent-docs@skill-forge
claude plugin install code-quality@skill-forge
claude plugin install opencode-customize@skill-forge
claude plugin list --json | jq '.[] | select(.id | endswith("@skill-forge"))'
```

**Local path vs GitHub form:** `claude plugin marketplace add "$(pwd)"` 读取当前工作区，适合提交前 smoke test。`claude plugin marketplace add gzb1128/skill-forge` 会从 GitHub 拉取最新提交，适合模拟最终用户安装，无法看到未提交变更。

`claude plugin validate` 会检查 JSON schema、重复插件名、source path traversal、`SKILL.md` frontmatter。它不会检查 hook 安全性、MCP 可达性或技能行为，这些需要上游 `scan-plugins` CI 或手工验证。

### Editing a skill

1. 修改 `plugins/<plugin-name>/skills/<name>/SKILL.md`，插件目录是唯一源码来源。
2. 运行 `claude plugin validate ./plugins/<plugin-name>`。
3. 本地重装并确认新 SHA：`claude plugin install <plugin-name>@skill-forge`。
4. 提交信息必须解释 WHY（业务影响），而不是只描述 WHAT（代码变化）。

### Editing the template payload

1. 修改 `plugins/agent-docs/templates/<path>`，这是 `bootstrap-agent-docs` 的 rsync 源。
2. 在临时目标仓库中重新执行 bootstrap 等价流程，确认模板按预期落地：
   ```bash
   TMP=$(mktemp -d) && cd "$TMP" && git init -q
   rsync -av --ignore-existing /path/to/skill-forge/plugins/agent-docs/templates/ ./
   git status
   ```
3. 提交变更。

## Hidden Knowledge

- **`bootstrap-agent-docs` 通过 `${CLAUDE_PLUGIN_ROOT}/templates/` 定位模板**。该环境变量由 Claude Code 在插件启用时自动设置。不要在技能中引用本仓库的相对路径；插件会安装到 `~/.claude/plugins/cache/...`，运行时看不到当前工作区。
- **插件安装只复制插件目录内的内容**。`plugins/<name>/` 外部路径对已安装插件不可见，不要在技能中写 `../../something`；需要的资源必须打包进对应插件目录。
- **省略 `version` 是刻意设计**。添加固定 version 会破坏“每次 push 都是新版本”的 SHA 版本策略。
- **Marketplace source 使用 `git-subdir.url` 字段**。当前 Claude Code schema 要求 `git-subdir` source 使用 `url`，不是旧版 `repo` 字段。

## Development Workflow

1. 修改 `plugins/<plugin-name>/` 下的技能、模板或插件元数据。
2. 运行 `make validate`。
3. 如涉及技能行为，运行 `make test-skills-link` 并重启 opencode 后执行对应场景验证。
4. 本地 smoke-test install（见 Local verification workflow）。
5. 提交时使用解释 WHY 的英文提交信息。
6. Push 后，新的 git SHA 自动成为插件版本。
