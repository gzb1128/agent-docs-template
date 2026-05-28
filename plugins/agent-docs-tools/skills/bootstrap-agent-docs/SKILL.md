---
name: bootstrap-agent-docs
description: Use when bootstrapping a repository to follow Agent-First documentation practices (OpenAI Harness Engineering), when the user says "bootstrap agent docs", "init agent docs", "apply our doc baseline", "scaffold AGENTS.md", or when an existing repo lacks a structured docs/ directory, root AGENTS.md table-of-contents, or .agents/skills/ scaffolding
---

# Bootstrap Agent-First Documentation

## Overview

Scaffold a repository's documentation structure to follow **Agent-First Engineering** practices — "Human at the helm. Agents execute." The knowledge base is structured for agent readability with progressive disclosure: a small stable entry point (`AGENTS.md` ~100 lines) that points to deeper docs.

**Core principle:** Scaffold the structure, do NOT auto-generate content that will rot. Agents and humans fill in content iteratively as the project evolves.

**Reference template:** The template repo this skill ships inside. Resolve its path in this order:

1. `$AGENT_DOCS_TEMPLATE` env var, if set
2. `~/code/agent-docs-template/`, if it exists
3. Ask the user

Bind this to `$TEMPLATE_DIR` once at the start of the run and use `$TEMPLATE_DIR` in every later command. The example commands below assume `$TEMPLATE_DIR` is already exported.

```bash
TEMPLATE_DIR="${AGENT_DOCS_TEMPLATE:-$HOME/code/agent-docs-template}"
[ -d "$TEMPLATE_DIR" ] || { echo "Template not found at $TEMPLATE_DIR — set AGENT_DOCS_TEMPLATE"; exit 1; }
```

> **Installing this skill in a target repo:** This skill lives at `.agents/skills/bootstrap-agent-docs/` in the template repo. The simplest install is just running the rsync command in Step 4 — `.agents/skills/` is included in the copy, so once you bootstrap a target repo, the skill (and the `clean-commit` skill) travel along automatically. For a one-shot run without persisting the skill, you can invoke it directly by pointing your agent at `$TEMPLATE_DIR/.agents/skills/bootstrap-agent-docs/SKILL.md`.

## When to Use

**Use when:**
- Initializing a new repo with Agent-First docs baseline
- An existing repo has no `AGENTS.md` or has a bloated 1000+ line `AGENTS.md`
- Documentation is scattered with no INDEX, no clear convention
- The user explicitly asks to "apply our doc practices" or "bootstrap agent docs"

**Do NOT use when:**
- The repo already has a working `AGENTS.md` table-of-contents + `docs/` tree (just improve it incrementally)
- The user wants to write a single document (create that document directly)
- The user wants to add ONE specific rule/codemap (just create that file directly)

## Process

```dot
digraph bootstrap {
    "Verify target repo" [shape=box];
    "Scan repo characteristics" [shape=box];
    "Confirm scaffolding plan" [shape=diamond];
    "Copy template tree" [shape=box];
    "Adapt root AGENTS.md" [shape=box];
    "Identify complex sub-packages" [shape=box];
    "Add sub-package AGENTS.md?" [shape=diamond];
    "Scaffold sub-package AGENTS.md" [shape=box];
    "Print next-steps checklist" [shape=doublecircle];

    "Verify target repo" -> "Scan repo characteristics";
    "Scan repo characteristics" -> "Confirm scaffolding plan";
    "Confirm scaffolding plan" -> "Copy template tree" [label="approved"];
    "Confirm scaffolding plan" -> "Print next-steps checklist" [label="rejected"];
    "Copy template tree" -> "Adapt root AGENTS.md";
    "Adapt root AGENTS.md" -> "Identify complex sub-packages";
    "Identify complex sub-packages" -> "Add sub-package AGENTS.md?";
    "Add sub-package AGENTS.md?" -> "Scaffold sub-package AGENTS.md" [label="yes"];
    "Scaffold sub-package AGENTS.md" -> "Print next-steps checklist";
    "Add sub-package AGENTS.md?" -> "Print next-steps checklist" [label="no"];
}
```

### Step 1: Verify Target Repo

- Confirm the user's target directory (do NOT assume current working directory).
- Check it is a git repo (`git rev-parse --show-toplevel`). If not, ask the user to confirm.
- Check for existing `AGENTS.md` / `docs/`. If present, ask whether to **merge** (preserve existing) or **replace** (overwrite). Default to merge.

### Step 2: Scan Repo Characteristics

Run quick detection and report findings to the user:

| Signal | Command | Used for |
|--------|---------|----------|
| Language | look at top extensions: `git ls-files \| sed 's/.*\.//' \| sort \| uniq -c \| sort -rn \| head -5` | Choose example rules to seed |
| Build system | look for `Makefile`, `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml` | Quick Reference table commands |
| Entry points | look for `cmd/*/main.go`, `src/index.*`, `main.py` | Architecture section in AGENTS.md |
| Sub-packages with potential complexity | `find . -type d \( -name internal -o -name pkg -o -name src -o -name lib \) -maxdepth 3` | Candidates for sub-package AGENTS.md |

Report what was detected. Do NOT proceed silently.

### Step 3: Confirm Scaffolding Plan

Before writing any files, summarize what will be created:

```
Will create in <target>:
- AGENTS.md (root, ~100 lines, table of contents)
- docs/codemaps/INDEX.md
- docs/rules/{INDEX,non-derivability,document-conventions,openai-harness-engineering}.md
- docs/{troubleshoot,runbooks,lib,verify,design,plans}/INDEX.md
- docs/_templates/{codemap,design,plan,subpackage-AGENTS}.md
- .agents/skills/{bootstrap-agent-docs,clean-commit}/SKILL.md
- .agents/commands/{README,learn,remember}.md  (manual-trigger; wire into your /command system)
- .gitignore (only if missing)
```

Get user approval before creating files.

### Step 4: Copy Template Tree

Source: `$TEMPLATE_DIR` (resolved in Overview).

Both strategies below use `--ignore-existing` so the target's `.gitignore`, `AGENTS.md`, or any pre-existing file is never overwritten. The README.md of the template is for the template repo itself and is excluded.

**Strategy A — fresh repo (no existing AGENTS.md/docs):**
```bash
rsync -av --ignore-existing \
  --exclude='.git/' --exclude='README.md' \
  "$TEMPLATE_DIR/" <target>/
```

**Strategy B — existing repo (merge, never overwrite):**
```bash
rsync -av --ignore-existing \
  --exclude='.git/' --exclude='README.md' \
  "$TEMPLATE_DIR/" <target>/
# Then list what's new and what was skipped:
cd <target> && git status
```

After copy, run `cd <target> && git status` to see exactly what was created. If the user wants to overwrite a specific file, copy it explicitly after confirming.

### Step 5: Adapt Root AGENTS.md

The copied `AGENTS.md` contains two kinds of placeholders:

- **`{{NAME}}`** — single values to replace (e.g., `{{PROJECT_NAME}}`, `{{BUILD_COMMAND}}`). Replace with detected values, or leave the placeholder if you can't determine it.
- **`<!-- TODO: ... -->`** — prose hints for sections the human needs to flesh out. Leave the comment in place until the human fills the section in. Delete the comment only when its row/section is confirmed N/A.

Search both with:
```bash
grep -rn '{{' <target>/AGENTS.md <target>/docs/
grep -rn 'TODO:' <target>/AGENTS.md <target>/docs/
```

For values you cannot detect from the repo scan, leave the `{{...}}` placeholder untouched — the user will fill it in.

**Critical:** Keep root `AGENTS.md` under ~150 lines. If you find yourself adding more, link to a doc in `docs/` instead.

### Step 6: Identify Complex Sub-Packages

A sub-package warrants its own `AGENTS.md` when ANY of:

| Condition | Threshold |
|-----------|-----------|
| State machine | Has explicit state transitions, phase flow |
| High complexity | Single file > 800 LoC, or package total > 3000 LoC |
| Cross-module constraints | Changes require updates in multiple docs/configs |
| Special error handling | Retry, compensation, rollback logic |
| High test complexity | > 5 test files or has integration tests |

For each candidate, ASK the user before creating — do not auto-create. Sub-package `AGENTS.md` template is in `$TEMPLATE_DIR/docs/_templates/subpackage-AGENTS.md`.

### Step 7: Next-Steps Checklist

Print this for the user (the agent is done; the user/agent iterates from here):

```
Bootstrap complete. Next steps for you/the agent:

1. Fill placeholders in AGENTS.md (search for "TODO:" markers)
2. Wire up the manual-trigger commands at .agents/commands/ into your agent's
   command system (e.g., symlink to .opencode/command/ or .claude/commands/).
   See .agents/commands/README.md for the rationale and per-agent setup.
3. If useful, write your first code map: docs/codemaps/<component>.md
   - Apply the non-derivability principle (docs/rules/non-derivability.md)
   - Use the "map, not encyclopedia" pattern (docs/rules/openai-harness-engineering.md)
4. Add project-specific coding rules under docs/rules/, update docs/rules/INDEX.md
5. Add the first design doc when you have a non-obvious decision to record:
   docs/design/YYYY-MM-DD-<topic>-design.md
6. Commit the baseline: `git add . && git commit -m "docs: bootstrap agent-first documentation baseline"`
```

## Quick Reference

| Action | Where |
|--------|-------|
| Template source | `$TEMPLATE_DIR` (default `~/code/agent-docs-template/`, override with `$AGENT_DOCS_TEMPLATE`) |
| Root AGENTS.md placeholder list | `$TEMPLATE_DIR/AGENTS.md` (grep for `{{`) |
| Sub-package AGENTS.md template | `$TEMPLATE_DIR/docs/_templates/subpackage-AGENTS.md` |
| OpenAI Harness reference | `$TEMPLATE_DIR/docs/rules/openai-harness-engineering.md` |
| Document conventions | `$TEMPLATE_DIR/docs/rules/document-conventions.md` |

## Golden Rules (enforce while scaffolding)

1. **Root `AGENTS.md` is a table of contents, not an encyclopedia.** Target ~100 lines.
2. **Progressive disclosure.** Each level points to the next, never duplicates content.
3. **INDEX.md per category.** Every `docs/*/` subdir has an INDEX.md mapping topic → file.
4. **Code maps are maps.** Tables of concept → file path, never copy code into docs.
5. **Naming conventions.**
   - Design: `docs/design/YYYY-MM-DD-<topic>-design.md`
   - Plan: `docs/plans/YYYY-MM-DD-<feature>.md`
6. **Sub-package AGENTS.md only when justified.** Do not over-scaffold.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Copying the template AGENTS.md verbatim with placeholders unfilled | Always replace `{{...}}` or add `TODO:` markers explicitly |
| Auto-generating code maps from `tree`/AST scans | Don't. They rot in days. Let humans/agents write them when actually needed |
| Creating sub-package AGENTS.md for every package | Only for state machines, complex modules, cross-cutting constraints |
| Skipping the user approval step (Step 3) | Always confirm scope before mass-creating files |
| Forgetting to merge instead of overwrite on existing repos | Default to merge; only overwrite with explicit user consent |

## Anti-Patterns (do NOT do)

- **One giant `AGENTS.md`** — kills agent context, contains stale rules, can't be verified mechanically
- **Nested `docs/x/y/z/`** — flat is better; use purpose-specific subdirs only
- **`docs/codemaps/*.md` containing copy-pasted config or function bodies** — link to source files instead
- **`docs/rules/INDEX.md` missing "When to Use" column** — agents need triggering signals, not just titles

## Red Flags — Stop and Reconsider

- About to create > 20 files without user approval → STOP, ask
- About to generate a code map by reading source → STOP, that's the human/agent's job after bootstrap
- AGENTS.md drifting past 200 lines → STOP, move detail into `docs/`
- Sub-package AGENTS.md being created for a leaf package → STOP, not justified
