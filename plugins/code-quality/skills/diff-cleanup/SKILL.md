---
name: diff-cleanup
description: Use when the user asks to remove AI slop, clean up AI-generated code, strip bloated comments, or simplify code on a feature branch. Triggers on "remove slop", "clean up AI code", "remove unnecessary comments", "simplify this diff", "this code feels bloated".
---

# Diff Cleanup

Remove AI-generated bloat from a feature branch's diff.

You already have good instincts for what looks like slop (restating-the-code comments, dead type-system-redundant guards, manual loops that reflow a one-liner). The three rules below address what agents skip without guidance.

## Three required rules

### 1. Diff against the base branch, not the working tree

```bash
git fetch origin --quiet 2>/dev/null
BASE=$(git merge-base HEAD origin/main 2>/dev/null \
    || git merge-base HEAD origin/master 2>/dev/null \
    || git rev-parse HEAD~1)
git diff "$BASE"...HEAD
```

`git diff` alone only shows the working tree. Branch-scope cleanup needs the whole feature branch. If you cannot determine the base, ask.

### 2. Check authorship before removing anything

For each candidate removal:

```bash
git blame -L <start>,<end> -- <file>
```

**Only remove lines whose commit is on the current feature branch (after `$BASE`).** Lines predating the branch are human-authored. Leave them alone, even if they look slop-like.

### 3. Respect the design vs. style boundary

You are removing **low-value tokens within a chosen design**. You are not redesigning.

| In scope | Out of scope |
|---|---|
| Restating-the-code comments | Whether a builder/factory pattern is justified |
| Type-system-redundant runtime guards | Whether the function should exist at all |
| Reflowed loops with no behavior change | Whether the data model is right |
| `IMPORTANT:`-style emphasis on trivia | Whether the public API is too wide |

If you find yourself wanting to redesign, **stop and flag it**. Do not silently rewrite.

## Never touch

- Comments explaining **why** (business reason, workaround, non-obvious constraint)
- Defensive checks at **public API boundaries** or on **external/untrusted input**
- Lines predating the feature branch (per rule 2)
- Test code

## Procedure

1. Resolve `$BASE` (rule 1)
2. `git diff "$BASE"...HEAD` — read the full branch diff
3. For each candidate removal, run `git blame` on the line range
4. Apply removals with Edit. Do not rewrite logic.
5. `git diff "$BASE"...HEAD --stat` to confirm
6. Report in 2–4 sentences: categories removed, design concerns flagged but not touched, final stat.
