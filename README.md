# Agent Docs Template

A ready-to-use baseline for **Agent-First documentation** in any repository, based on [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/) practices.

**Core idea:** Human at the helm. Agents execute. The repo is the system of record — knowledge is structured for agent readability with progressive disclosure.

## Quick Start

### Option 1: Use the bundled `bootstrap-agent-docs` skill (recommended)

This template ships with a skill at `.agents/skills/bootstrap-agent-docs/SKILL.md` that scaffolds any repo to follow these practices.

Point your agent at the skill and ask:

> "Bootstrap agent docs for this repo using the bootstrap-agent-docs skill at `$AGENT_DOCS_TEMPLATE/.agents/skills/bootstrap-agent-docs/SKILL.md` (defaults to `~/code/agent-docs-template/`)."

The skill detects your project's language/build system, copies this template, and fills in placeholders interactively. The `.agents/skills/` directory is copied along with the template, so the skill and the bundled `clean-commit` skill become available in the target repo automatically.

### Option 2: Manual copy

```bash
# In your target repo root. --ignore-existing ensures we never overwrite
# anything you already have (AGENTS.md, .gitignore, etc.).
# Override the template path via $AGENT_DOCS_TEMPLATE if it lives elsewhere.
TEMPLATE_DIR="${AGENT_DOCS_TEMPLATE:-$HOME/code/agent-docs-template}"
rsync -av --ignore-existing --exclude='.git/' --exclude='README.md' \
  "$TEMPLATE_DIR/" ./

# See what was created vs skipped
git status

# Then search for {{...}} placeholders and TODO markers in AGENTS.md and fill them in
grep -rn '{{' AGENTS.md docs/
grep -rn 'TODO:' AGENTS.md docs/
```

## What You Get

```
your-repo/
├── AGENTS.md                          # ~100-line table of contents (root entry for agents)
├── .agents/
│   ├── skills/
│   │   ├── bootstrap-agent-docs/SKILL.md  # The skill that scaffolds this structure into other repos
│   │   └── clean-commit/SKILL.md          # Starter skill: enforce quality gates before commit
│   └── commands/                          # Manual-trigger commands (NOT skills — wire into /command yourself)
│       ├── README.md                      # Why they're commands, how to wire them up
│       ├── learn.md                       # Persist non-obvious insights to AGENTS.md
│       └── remember.md                    # Audit existing AGENTS.md for stale/duplicate knowledge
└── docs/
    ├── codemaps/INDEX.md              # Architecture maps (concept → file path)
    ├── design/INDEX.md                # Design specs: YYYY-MM-DD-<topic>-design.md
    ├── plans/INDEX.md                 # Implementation plans: YYYY-MM-DD-<feature>.md
    ├── rules/                         # Coding standards
    │   ├── INDEX.md
    │   ├── non-derivability.md        # 不可推导原则 — universal doc filter
    │   ├── document-conventions.md
    │   └── openai-harness-engineering.md
    ├── troubleshoot/INDEX.md          # Symptom-indexed troubleshooting
    ├── runbooks/INDEX.md              # Deterministic operational procedures
    ├── lib/INDEX.md                   # Third-party library usage notes
    ├── verify/INDEX.md                # Dry-run verification flows
    └── _templates/                    # Templates for new docs (copy & customize)
        ├── codemap.md
        ├── design.md
        ├── plan.md
        └── subpackage-AGENTS.md
```

## The Practices in 60 Seconds

| Practice | What it means |
|----------|---------------|
| **Repo as record system** | If agents can't see it in markdown, it doesn't exist. No tribal knowledge in Slack/Docs. |
| **Progressive disclosure** | `AGENTS.md` (~100 lines) → `docs/codemaps/*.md` (per-component) → source files. Never duplicate. |
| **INDEX per category** | Every `docs/*/` has an `INDEX.md` with a "When to Use" column so agents can triage at a glance. |
| **Non-derivability filter** | Record only what cannot be derived from code, git history, or existing docs. |
| **Maps, not encyclopedias** | Codemaps use tables of concept → file path. They link to source, never copy code. |
| **Sub-package AGENTS.md** | Add one only for modules with state machines, cross-cutting constraints, or high complexity. |
| **Date-prefixed designs/plans** | `YYYY-MM-DD-<topic>-design.md` keeps history browsable in chronological order. |

## Filling in the Template

After copying, these are useful next steps:

1. **Replace `{{PROJECT_NAME}}`, `{{BUILD_COMMAND}}`, etc.** in `AGENTS.md` (grep for `{{`)
2. **Fill `TODO:` markers** in `AGENTS.md` (grep for `TODO:`)
3. **If navigation is non-obvious, write a codemap** under `docs/codemaps/<component>.md` using `docs/_templates/codemap.md`. Update `docs/codemaps/INDEX.md` to link it.
4. **Add project-specific rules** under `docs/rules/`. Update `docs/rules/INDEX.md`.
5. **Commit the baseline:**
   ```bash
   git add . && git commit -m "docs: bootstrap agent-first documentation baseline"
   ```

## Why This Structure?

Read [docs/rules/openai-harness-engineering.md](docs/rules/openai-harness-engineering.md) for the full rationale. The short version:

- **Context is scarce.** A 1000-line AGENTS.md crowds out the actual task. Keep it ~100 lines.
- **All guidance becomes noise.** If everything is "important", nothing is. Be selective.
- **Stale docs rot.** Copy-pasted code/config in docs goes out of date in days. Link to source.
- **Agents need triggers.** "When to use" columns let agents pick the right doc without reading them all.

## Maintenance

Treat documentation like code: review it, refactor it, run garbage collection on it.

- When you add a module → update the relevant INDEX and codemap
- When you discover an outdated section → fix it the same commit
- When a doc grows past its complexity tier (see `document-conventions.md`) → split it

## Plugin Marketplace

This repo ships with a Claude Code plugin marketplace at `.claude-plugin/marketplace.json`.

### Versioning: git commit SHA, not semver

All plugins in this marketplace **omit the `version` field** by design. This means Claude Code resolves each plugin's version to the **git commit SHA** of its source — every push to the marketplace repo automatically becomes a new version.

Why:

- **No manual version bumps** — contributors push changes and users get them immediately
- **Deterministic reproducibility** — each SHA is immutable; the exact code a user ran is always recoverable
- **Always latest** — `claude plugin update` picks up the newest SHA without waiting for a maintainer to edit a version string

Users run `/plugin update` or let auto-update handle it. There is nothing to tag or release.

### Installation

```bash
# Add the marketplace (local path, GitHub repo, or git URL)
claude plugin marketplace add gzb1128/agent-docs-template

# Install a plugin
claude plugin install example-plugin@agent-docs-plugins

# Update to latest commit
claude plugin update example-plugin@agent-docs-plugins
```

### Adding new plugins

1. Create a directory under `plugins/<plugin-name>/`
2. Add `.claude-plugin/plugin.json` — do **not** set `version`
3. Add skills, agents, hooks, or MCP servers as needed
4. Register the plugin in `.claude-plugin/marketplace.json` with `"source": "./plugins/<name>"`
5. Run `claude plugin validate .` to verify

## License

Use freely. Adapt to your project's needs.
