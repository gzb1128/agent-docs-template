# agent-docs-template

A Claude Code plugin (`agent-docs-tools`) that scaffolds **Agent-First documentation** into any repository, based on [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/) practices.

**Core idea:** Human at the helm. Agents execute. The repo is the system of record — knowledge is structured for agent readability with progressive disclosure.

## Quick Start

```bash
# 1. Add this marketplace
claude plugin marketplace add gzb1128/agent-docs-template

# 2. Install the plugin
claude plugin install agent-docs-tools@agent-docs-plugins

# 3. In your target repo, ask Claude:
#    "bootstrap agent docs"
#    The bootstrap-agent-docs skill takes over from there.
```

Updates land automatically — the plugin is pinned to git commit SHA, every push is a new version. Run `claude plugin update agent-docs-tools@agent-docs-plugins` (or wait for auto-update) to pull the latest.

## What the plugin ships

| Skill | Type | Purpose |
|---|---|---|
| `bootstrap-agent-docs` | model-invoked | Scaffold `AGENTS.md`, `docs/_templates/`, `docs/rules/`, and per-category INDEX files into a target repo |
| `clean-commit` | model-invoked | Run quality gates (lint/test/typecheck) before committing, with messages that explain WHY |
| `learn` | manual skill (`/agent-docs-tools:learn`) | Persist non-obvious session insights to the right `AGENTS.md` (verified, approval-gated) |
| `remember` | manual skill (`/agent-docs-tools:remember`) | Audit `AGENTS.md` knowledge for staleness, duplication, and misplacement |

The template payload that `bootstrap-agent-docs` rsyncs lives inside the plugin at `plugins/agent-docs-tools/templates/` and resolves at runtime via `${CLAUDE_PLUGIN_ROOT}/templates/`. No separate repo clone needed.

## What gets scaffolded

When you ask Claude to "bootstrap agent docs" in a target repo, the plugin creates:

```
your-repo/
├── AGENTS.md                          # ~100-line table of contents (root entry for agents)
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

## Why This Structure?

Read [`openai-harness-engineering.md`](plugins/agent-docs-tools/templates/docs/rules/openai-harness-engineering.md) for the full rationale. The short version:

- **Context is scarce.** A 1000-line AGENTS.md crowds out the actual task. Keep it ~100 lines.
- **All guidance becomes noise.** If everything is "important", nothing is. Be selective.
- **Stale docs rot.** Copy-pasted code/config in docs goes out of date in days. Link to source.
- **Agents need triggers.** "When to use" columns let agents pick the right doc without reading them all.

## Contributing

This repo is both the marketplace and the plugin source. See [AGENTS.md](AGENTS.md) for the development workflow, local verification commands (`claude plugin validate`), and SHA-based versioning policy.

## License

Use freely. Adapt to your project's needs.
