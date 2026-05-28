# {{PROJECT_NAME}}

> **Agent-First Engineering**: This repository follows [OpenAI Harness Engineering](docs/rules/openai-harness-engineering.md) — 
> "Human at the helm. Agents execute." The knowledge base is structured for agent readability with progressive disclosure.

This file is the entry point for any AI coding agent working in this repository.
For deeper context, follow the links — don't try to absorb everything upfront.

## Quick Reference

| Action | Command |
|--------|---------|
| Build | `{{BUILD_COMMAND}}` <!-- TODO: e.g., `make all`, `npm run build`, `cargo build` --> |
| Test | `{{TEST_COMMAND}}` <!-- TODO: e.g., `go test ./...`, `npm test`, `pytest` --> |
| Lint | `{{LINT_COMMAND}}` <!-- TODO: e.g., `golangci-lint run ./...`, `npm run lint` --> |
| Run locally | `{{RUN_COMMAND}}` <!-- TODO --> |
| Generate code | `{{CODEGEN_COMMAND}}` <!-- TODO: optional, delete this row if N/A --> |
| Clean | `{{CLEAN_COMMAND}}` <!-- TODO: optional, delete this row if N/A --> |

## Architecture

<!-- TODO: 1-3 sentences describing what this project IS and the main components.
     Example:
     Three components, one repo:
     - **api-server** (`cmd/api/main.go`) — HTTP API server
     - **worker** (`cmd/worker/main.go`) — Async job executor
     - **cli** (`cmd/cli/main.go`) — Command-line tool
-->
{{ARCHITECTURE_SUMMARY}}

## Common Tasks

| I want to... | Start here |
|---|---|
| Add/modify a plugin | `plugins/<name>/` — see Plugin Marketplace section below |
| Validate marketplace or plugin | `claude plugin validate .` (marketplace) / `claude plugin validate ./plugins/<name>` (plugin) |
| Test plugin install locally | `claude plugin marketplace add <repo-path>` then `claude plugin install <name>@agent-docs-plugins` |
| Add/modify an API endpoint | [codemaps/INDEX.md](docs/codemaps/INDEX.md) <!-- TODO: replace with API codemap if useful --> |
| Change database schema | [codemaps/INDEX.md](docs/codemaps/INDEX.md) <!-- TODO: replace with database codemap if useful --> |
| Understand the build/deploy flow | [codemaps/INDEX.md](docs/codemaps/INDEX.md) <!-- TODO: replace with build/deploy codemap if useful --> |
| Troubleshoot a system issue | [troubleshoot/INDEX.md](docs/troubleshoot/INDEX.md) |
| Run an operational procedure | [runbooks/INDEX.md](docs/runbooks/INDEX.md) |
| Use a third-party library | [lib/INDEX.md](docs/lib/INDEX.md) |
| Verify system behavior (dry-run) | [verify/INDEX.md](docs/verify/INDEX.md) |
| Look up a coding standard | [rules/INDEX.md](docs/rules/INDEX.md) |
| Find an architecture map | [codemaps/INDEX.md](docs/codemaps/INDEX.md) |

**More**: [Code map index](docs/codemaps/INDEX.md) | [Coding rules](docs/rules/INDEX.md) | [Troubleshoot](docs/troubleshoot/INDEX.md) | [Runbooks](docs/runbooks/INDEX.md) | [Library refs](docs/lib/INDEX.md) | [Design docs](docs/design/INDEX.md) | [Plans](docs/plans/INDEX.md) | [Verify index](docs/verify/INDEX.md) | [Doc templates](docs/_templates/)

## Key Patterns

<!-- TODO: 3-5 bullets describing the dominant patterns/conventions of this codebase.
     Examples:
     - **Generated code**: Edit source definitions, regenerate outputs — never hand-edit generated files
     - **DI**: Uber FX (runtime), Wire (compile-time)
     - **Tests next to source**: `_test.go` lives with the file it tests
-->

## Golden Rules

<!-- TODO: 3-7 hard rules that must NOT be broken. These are the rules that agents
     are most likely to violate without explicit reminders. -->
1. Never hand-edit generated code — regenerate
2. Tests live next to source
3. Follow existing patterns before inventing new ones
4. Update the relevant codemap/INDEX when you add new modules

## Document Creation Rules

> ⚠️ **CRITICAL**: Before creating ANY documentation, read [docs/rules/non-derivability.md](docs/rules/non-derivability.md), [docs/rules/document-conventions.md](docs/rules/document-conventions.md), and [docs/rules/openai-harness-engineering.md](docs/rules/openai-harness-engineering.md).

**Anti-Patterns (RED):**
- Copying code/config into documentation
- Writing detailed procedures in INDEX files (INDEX = table of links, not tutorial)

**Correct Pattern (GREEN):**
- Use tables to map concepts → file paths
- Link to source files instead of copying content
- Record only what cannot be derived from code, git history, or existing docs
- INDEX files: ~30 lines of tables + quick navigation

## Development Workflow

1. Make changes
2. Run `{{LINT_COMMAND}}` on affected package — fix lint errors <!-- TODO -->
3. Run `{{TEST_COMMAND}}` on affected package first <!-- TODO -->
4. Update relevant docs (codemap, INDEX) if structure changed
5. Commit with a message that explains WHY (business impact), not WHAT (code change)

## Plugin Marketplace

This repo ships with a Claude Code plugin marketplace at `.claude-plugin/marketplace.json`. Plugins live under `plugins/`.

### Versioning: git commit SHA, not semver

All plugins **omit the `version` field** by design. Claude Code resolves each plugin's version to the git commit SHA — every push to this repo automatically becomes a new version. No manual bumps, no release tags.

### Local verification workflow

After modifying a plugin, always verify before committing:

```bash
# 1. Validate the marketplace catalog
claude plugin validate .

# 2. Validate the individual plugin (checks plugin.json + skills frontmatter)
claude plugin validate ./plugins/<name>

# 3. (Optional) Smoke-test install from local path
claude plugin marketplace add /path/to/this/repo
claude plugin install <name>@agent-docs-plugins
claude plugin list --json   # confirm enabled + correct version
```

`claude plugin validate` checks: JSON schema, duplicate plugin names, source path traversal, skill/agent/command frontmatter parsing. It does **not** check hook safety or MCP reachability — those require the full `scan-plugins` CI pipeline.

### Adding a new plugin

1. Create `plugins/<name>/` with `.claude-plugin/plugin.json` (no `version` field)
2. Add skills as `skills/<skill-name>/SKILL.md` directories
3. Register in `.claude-plugin/marketplace.json` with `"source": "./plugins/<name>"`
4. Run `claude plugin validate .` and `claude plugin validate ./plugins/<name>`
5. Commit

## Sub-Package Rules

<!-- TODO: Add rows for any sub-package with its own AGENTS.md (complex modules
     with state machines, cross-module constraints, etc.). Leave empty if none. -->

| Module | Rules Doc | Reason |
|--------|-----------|--------|
| _none yet_ | — | — |

See [docs/rules/document-conventions.md](docs/rules/document-conventions.md) for when to add a sub-package AGENTS.md.

## Verification

Verify system behavior via [docs/verify/INDEX.md](docs/verify/INDEX.md). Prefer dry-run modes.
