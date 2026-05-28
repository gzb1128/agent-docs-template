# Document Conventions

## Document Tree

| Document Type | Location | Naming |
|--------------|----------|--------|
| Design specs | `docs/design/` | `YYYY-MM-DD-<topic>-design.md` |
| Implementation plans | `docs/plans/` | `YYYY-MM-DD-<feature-name>.md` |
| Code maps (architecture) | `docs/codemaps/` | By component, flat or one level of subdirs |
| Coding rules / best practices | `docs/rules/` | Flat structure with INDEX.md |
| Troubleshoot guides | `docs/troubleshoot/` | Flat structure with INDEX.md |
| Operational runbooks | `docs/runbooks/` | Flat structure with INDEX.md |
| Library usage guides | `docs/lib/` | Flat structure with INDEX.md |
| Verification flows | `docs/verify/` | Flat structure with INDEX.md |
| One-off guides / how-tos | `docs/` root | `<topic>.md` |

**Do not create extra nesting** — keep `docs/` flat with purpose-specific subdirectories. Add one level of subdir under `codemaps/` or `verify/` only when you have 10+ docs in that category.

## Code Map Guidelines

All code maps in `docs/codemaps/` **must follow** [OpenAI Harness Engineering](openai-harness-engineering.md):

- **Map, not encyclopedia.** Directory structure, architecture diagrams, quick navigation
- **No implementation code.** Function bodies belong in source, not docs
- **Progressive disclosure.** Overview → concept-to-file table → link to source
- **File index.** Tables mapping concepts to file paths
- **Related areas.** Always link to related docs

### Depth Proportional to Interface Surface Area

| Module role | Criteria | Recommended depth |
|-------------|----------|-------------------|
| Core | 3+ consumer packages, has state machine, cross-module constraints | ~200-300 lines |
| Standard | 1-2 consumer packages, no state machine | ~100 lines |
| Leaf | No internal consumers, self-contained | ≤ 50 lines |

Quick check: `rg "<package-path>" --glob '*.<ext>' | wc -l`. > 20 references = core; < 5 = leaf.

### Rule Documents Take Precedence

> ⚠️ **Critical Rule**: If a topic has a dedicated rule document under `docs/rules/`, **link to it from the codemap** — do not re-state the rule inline. Single source of truth.

## When to Add a Sub-Package AGENTS.md

Add `AGENTS.md` to a sub-package when ANY of:

| Condition | Threshold / Note |
|-----------|------------------|
| State machine | Explicit state transitions, phase flow |
| High complexity | Single file > 800 LoC or package total > 3000 LoC |
| Cross-module constraints | Changes require synchronizing multiple docs/configs |
| Special error handling | Retry, compensation, rollback logic |
| High test complexity | > 5 test files or has integration tests |

Use the template at [../_templates/subpackage-AGENTS.md](../_templates/subpackage-AGENTS.md).

## INDEX.md Standards

Every `docs/<category>/` directory must have an `INDEX.md`. Keep it short (~30-60 lines):

- **One table** listing documents with a description and "When to Use" column
- **No tutorials** — INDEX is a table of links, not a how-to
- **Update the INDEX** in the same commit as adding/removing a doc in that category

## Naming Standards

- Lowercase with hyphens: `task-controller.md`, not `TaskController.md`
- Date prefix for designs/plans: `2026-05-28-feature-x-design.md`
- No version suffix (`-v2`): supersede the file by editing it; archive the old version in a `*-archive.md` table if needed for history
