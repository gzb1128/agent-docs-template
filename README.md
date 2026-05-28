# Agent Docs Template

A ready-to-use baseline for **Agent-First documentation** in any repository, based on [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/) practices.

**Core idea:** Human at the helm. Agents execute. The repo is the system of record — knowledge is structured for agent readability with progressive disclosure.

## Quick Start

### Option 1: Use the `bootstrap-agent-docs` skill (recommended)

If you have the `bootstrap-agent-docs` opencode skill installed (typically at `~/.config/opencode/skill/bootstrap-agent-docs/SKILL.md`), just ask your agent:

> "Bootstrap agent docs for this repo."

The skill detects your project's language/build system, copies this template, and fills in placeholders interactively.

### Option 2: Manual copy

```bash
# In your target repo root. --ignore-existing ensures we never overwrite
# anything you already have (AGENTS.md, .gitignore, etc.).
rsync -av --ignore-existing --exclude='.git/' --exclude='README.md' \
  ~/code/agent-docs-template/ ./

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
├── .agents/skills/
│   └── clean-commit/SKILL.md          # Starter skill: enforce quality gates before commit
└── docs/
    ├── codemaps/INDEX.md              # Architecture maps (concept → file path)
    ├── design/                        # Design specs: YYYY-MM-DD-<topic>-design.md
    ├── plans/                         # Implementation plans: YYYY-MM-DD-<feature>.md
    ├── rules/                         # Coding standards
    │   ├── INDEX.md
    │   ├── document-conventions.md
    │   └── openai-harness-engineering.md
    ├── troubleshoot/INDEX.md          # Symptom-indexed troubleshooting
    ├── runbooks/INDEX.md              # Deterministic operational procedures
    ├── lib/INDEX.md                   # Third-party library usage notes
    ├── verify/INDEX.md                # Dry-run verification flows
    └── _templates/                    # Templates for new docs
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
| **Maps, not encyclopedias** | Codemaps use tables of concept → file path. They link to source, never copy code. |
| **Sub-package AGENTS.md** | Add one only for modules with state machines, cross-cutting constraints, or high complexity. |
| **Date-prefixed designs/plans** | `YYYY-MM-DD-<topic>-design.md` keeps history browsable in chronological order. |

## Filling in the Template

After copying, do these in order:

1. **Replace `{{PROJECT_NAME}}`, `{{BUILD_COMMAND}}`, etc.** in `AGENTS.md` (grep for `{{`)
2. **Fill `TODO:` markers** in `AGENTS.md` (grep for `TODO:`)
3. **Write your first codemap** under `docs/codemaps/<component>.md` using the template in `docs/_templates/codemap.md`. Update `docs/codemaps/INDEX.md` to link it.
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

## License

Use freely. Adapt to your project's needs.
