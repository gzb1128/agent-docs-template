---
description: Audit and reorganize AGENTS.md knowledge — deduplicate, promote, and clean up
---

> **Manual-trigger command.** This file is intentionally NOT a skill — keeping
> it out of the auto-loaded skill set prevents the model from running audits
> mid-task. Wire it into your agent as a slash command (e.g., `/remember`) and
> invoke it deliberately when you want to clean up. See
> `.agents/commands/README.md` for setup.

Review all AGENTS.md files across the project and produce a structured cleanup report. Do NOT apply changes — present proposals for user approval.

## What this does

This is the complement to `/learn`:
- `/learn` writes new knowledge into AGENTS.md
- `/remember` audits existing knowledge for staleness, duplication, and misplacement

## Step 1: Gather all knowledge layers

Read all AGENTS.md files in the project. Example layout:

```
AGENTS.md
internal/<package>/AGENTS.md
<other-package>/AGENTS.md
```

Also read your personal preferences file (e.g., `~/.claude/CLAUDE.md`, `~/.config/opencode/AGENTS.md`) if it exists.

## Step 2: Classify each insight

For each `## Hidden Knowledge` entry found, determine the best destination:

| Destination | What belongs here | Examples |
|---|---|---|
| **Root AGENTS.md** (promote) | Project-wide conventions every contributor must know | "schema changes require code generation before build" |
| **Package AGENTS.md** (keep) | Package-specific quirks only relevant to that module | "state constants must match controller types" |
| **Delete** (stale) | Information that is no longer true or now derivable | Function renamed, file removed, workaround fixed |
| **No action** | Still valid and in the right place | — |

### Delete criteria (stale detection)

An entry is stale if ANY of these are true:

1. **File path no longer exists**: `ls` the referenced path — 404 = stale
2. **Function/type no longer exists**: `grep` the referenced name — no match = stale
3. **Behavior contradicted by code**: The insight says "must X" but the code now does Y
4. **Now derivable from docs/rules/**: A rule document was added that covers this insight
5. **Now in AGENTS.md main body**: The insight was promoted into a Golden Rule or Key Pattern

### Promote criteria

An entry in a package AGENTS.md should be promoted to root AGENTS.md if:

- It affects 2+ packages (cross-module constraint)
- It is a build/test command that belongs in Quick Reference
- It is a project-wide convention, not package-specific

## Step 3: Check for duplicates

Scan across all AGENTS.md files for:

- **Exact duplicates**: Same insight written in multiple places → keep in the most specific location
- **Partial overlaps**: One insight subsumes another → merge into one, delete the weaker version
- **Conflicts**: Two insights contradict each other → flag for user resolution

## Step 4: Present the report

Output a structured report:

```markdown
## AGENTS.md Audit Report

### Promotions (move to higher-level AGENTS.md)
1. `<source file>`: "<insight text>" → move to `<target file>` because <reason>

### Deletions (stale or now-derivable)
1. `<file>`: "<insight text>" → delete because <verification result>

### Duplicates
1. "<insight text>" in `<file A>` and `<file B>` → keep in `<file A>`, remove from `<file B>`

### Conflicts
1. `<file A>` says "X" but `<file B>` says "Y" → needs user input

### No action needed
<brief note on entries that are still valid and well-placed>
```

If no Hidden Knowledge sections exist anywhere, say so and offer to run `/learn` first.

## Step 5: User approval

- Present ALL proposals before making any changes
- Do NOT modify files without explicit user approval
- The user may approve all, approve some, or reject all
- For conflicts, ask the user which version is correct

## Procedure

1. Find and read all AGENTS.md files
2. Extract all `## Hidden Knowledge` entries
3. Verify each entry (grep/ls/cat the referenced paths)
4. Classify: promote / delete / duplicate / conflict / no action
5. Present report
6. Wait for user approval
7. Apply approved changes only
