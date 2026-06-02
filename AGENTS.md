# agent-docs-template

> **Agent-First Engineering**: This repository follows [OpenAI Harness Engineering](plugins/agent-docs/templates/docs/rules/openai-harness-engineering.md) —
> "Human at the helm. Agents execute."

This repo hosts two Claude Code plugins under the `agent-docs-plugins` marketplace:

- **`agent-docs`** — Agent-First documentation scaffolding and knowledge management
- **`code-quality`** — Code review, clean commits, diff cleanup, and autonomous fix-review loops

## What's here

| Path | Purpose |
|------|---------|
| `.claude-plugin/marketplace.json` | Marketplace catalog (`agent-docs-plugins`) |
| `plugins/agent-docs/` | Documentation plugin: `bootstrap-agent-docs`, `learn`, `remember` |
| `plugins/agent-docs/templates/` | Template payload rsynced by the `bootstrap-agent-docs` skill |
| `plugins/code-quality/` | Code quality plugin: `quality-reviewer`, `clean-commit`, `diff-cleanup`, `loopfix` |
| `docs/design/`, `docs/plans/` | Design docs and plans for THIS repo's evolution |
| `docs/verify/` | RED→GREEN→REFACTOR test process and scenario build scripts |
| `Makefile` | `validate` + `test-skills-link/unlink/status` for skill verification |
| `README.md` | User-facing install + usage guide |

## Quick Reference

| Action | Command |
|--------|---------|
| Validate marketplace + plugins | `make validate` |
| Link skills into `~/.agents/skills/` for testing | `make test-skills-link` then restart opencode |
| Check current symlink state | `make test-skills-status` |
| Build a scenario for GREEN testing | `bash docs/verify/scenarios/<skill>/build-<letter>.sh` |
| Remove test symlinks | `make test-skills-unlink` |
| Smoke-test install (local path) | `claude plugin marketplace add $(pwd)` then `claude plugin install <plugin>@agent-docs-plugins` |
| Inspect installed plugin | `claude plugin list --json \| jq '.[] \| select(.id\|contains("agent-docs"))'` |

## Plugin Marketplace

This repo IS the marketplace. The `.claude-plugin/marketplace.json` lists two plugins: `agent-docs` and `code-quality`.

### Versioning: git commit SHA, not semver

Both plugins **omit the `version` field** by design. Claude Code resolves the plugin's version to the git commit SHA — every push to this repo automatically becomes a new version. No manual bumps, no release tags.

> `claude plugin validate` warns `No version specified` and `No marketplace description provided` — both are **expected and intentional**, not errors. Validation passes.

### Local verification workflow

After modifying any file under `plugins/`, always verify before committing:

```bash
# 1. Validate the marketplace catalog
claude plugin validate .

# 2. Validate each plugin (checks plugin.json + SKILL.md frontmatter)
claude plugin validate ./plugins/agent-docs
claude plugin validate ./plugins/code-quality

# 3. Smoke-test install from the LOCAL working tree (tests uncommitted changes)
claude plugin marketplace add "$(pwd)"
claude plugin install agent-docs@agent-docs-plugins
claude plugin install code-quality@agent-docs-plugins
claude plugin list --json | jq '.[] | select(.id | contains("agent-docs"))'
```

**Local path vs GitHub form:** `claude plugin marketplace add "$(pwd)"` reads from your working tree (good for pre-commit smoke tests). `claude plugin marketplace add gzb1128/agent-docs-template` fetches the latest pushed commit from GitHub (good for end-user simulation, won't see uncommitted changes).

`claude plugin validate` checks: JSON schema, duplicate plugin names, source path traversal, SKILL.md frontmatter parsing. It does **not** check hook safety, MCP reachability, or skill behavior — those need the upstream `scan-plugins` CI pipeline or manual testing.

### Editing a skill

1. Edit `plugins/<plugin-name>/skills/<name>/SKILL.md` — the plugin is the only source
2. Run `claude plugin validate ./plugins/<plugin-name>`
3. Re-install locally and confirm new SHA: `claude plugin install <plugin-name>@agent-docs-plugins`
4. Commit with a message explaining WHY the skill changed (business impact)

### Editing the template payload

1. Edit `plugins/agent-docs/templates/<path>` — that's the rsync source for `bootstrap-agent-docs`
2. Re-run a bootstrap against a throwaway target dir to verify the change lands as intended:
   ```bash
   TMP=$(mktemp -d) && cd "$TMP" && git init -q
   rsync -av --ignore-existing /path/to/agent-docs-template/plugins/agent-docs/templates/ ./
   git status   # inspect what landed
   ```
3. Commit

## Hidden Knowledge

- **`bootstrap-agent-docs` resolves templates from `${CLAUDE_PLUGIN_ROOT}/templates/`** — that env var is set automatically by Claude Code when the plugin is enabled. Do NOT reference templates by repo-relative paths; the plugin is installed into `~/.claude/plugins/cache/...` and cannot see this repo's working tree.
- **Plugin install copies into cache, paths outside `plugins/<name>/` are invisible** — never write a skill that does `../../something`; pack everything the skill needs into its plugin directory.
- **No `version` field is intentional** — adding one pins the plugin and breaks the "every push is a new version" guarantee.

## Development Workflow

1. Edit under `plugins/agent-docs/` or `plugins/code-quality/` (skills or templates)
2. Run `claude plugin validate .` and `claude plugin validate ./plugins/<plugin-name>`
3. Smoke-test install locally (see Local verification workflow above)
4. Commit with a message that explains WHY (business impact), not WHAT (code change)
5. Push — every push is a new plugin version (SHA-based)
