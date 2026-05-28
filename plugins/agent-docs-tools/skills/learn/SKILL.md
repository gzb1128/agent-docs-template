---
name: learn
description: Use when the user says "learn", "save this insight", "remember this", or wants to persist non-obvious knowledge from the current session to AGENTS.md
disable-model-invocation: true
argument-hint: [optional-context]
allowed-tools: [Read, Glob, Grep, Bash, Edit, Write]
---

Review what happened in this session and persist non-obvious knowledge to the appropriate AGENTS.md.

## Non-Derivability Principle (不可推导原则)

**Only record information that CANNOT be derived from the codebase itself.** Before writing any insight, ask:

> Can the next agent (or human) discover this by reading the code, running `git log`, or checking existing docs?

If yes, do NOT record it. The bar is high — most knowledge belongs in code comments or commit messages, not in AGENTS.md.

## What to record

Only discoveries that pass the non-derivability test:

1. **Hidden dependencies**: Files/modules that must be changed together but are not obviously connected
2. **Misleading errors**: Error messages that point to the wrong location or cause
3. **Workarounds and quirks**: Project-specific behaviors that differ from standard patterns
4. **Critical ordering**: Operations that must happen in a specific sequence

## What NOT to record (derivable from code — skip these)

- Code patterns, architecture, file structure — visible by reading the code
- Git history or recent changes — `git log` / `git blame` is authoritative
- Debugging solutions or fix recipes — the fix is in the code, the commit message has the context
- Anything already in AGENTS.md, docs/rules/, or README
- Standard language behavior
- Ephemeral session details (what you tried, what failed temporarily)

## Pre-Write Verification (写入前验证)

Before writing any insight, verify it is still true:

1. If the insight mentions a **file path**: `ls` or `cat` to confirm the file still exists
2. If the insight mentions a **function or type**: `grep` to confirm it is still present
3. If the insight mentions a **behavior or constraint**: run the relevant command to confirm
4. If verification fails: the insight is stale — do NOT record it

## Where to write

Choose the nearest AGENTS.md to the affected code:

| Scope of insight | Target file |
|---|---|
| Affects entire project | Root `AGENTS.md` (under `## Hidden Knowledge` section) |
| Affects a specific package | `<package>/AGENTS.md` |
| Affects a specific module | Create `<package>/<module>/AGENTS.md` if needed |

## Format

Add insights as a `## Hidden Knowledge` section (create if not exists) at the end of the target AGENTS.md. Each insight is 1-3 lines.

## Anti-Staleness (防漂移)

When you encounter an existing insight while working:
- If the insight references something that has **changed or been removed**: delete or update it
- If the insight contradicts what you observe in the code: trust the code, update the insight

## Procedure

1. Review the conversation history for non-obvious discoveries
2. **Filter through non-derivability test**: can this be derived from code? If yes, skip
3. **Verify each insight is still true** (grep/cat/ls the referenced paths)
4. For each verified insight, determine the correct target AGENTS.md
5. **Check existing Hidden Knowledge**: remove any stale entries you encounter
6. Append to existing `## Hidden Knowledge` section or create one
7. Keep each insight to 1-3 lines — do not write essays
8. Report what you added and where
