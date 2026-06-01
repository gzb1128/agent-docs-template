---
name: quality-reviewer
description: Use when local code changes need a quality pass before commit, before opening a PR, or before claiming work is complete. Triggers on "review my changes", "quality check", "run quality gates", "ready to commit", "check before merge". Do NOT use for remote MR/PR review.
---

# Quality Reviewer

Run a structured quality pass on local changes. Do not commit. Fix safe in-scope issues, flag the rest, then report.

You will naturally inspect the diff, detect the toolchain (`go.mod`, `package.json`, `pyproject.toml`, `Cargo.toml`, `Makefile`), and decide what to lint and test. The rules below address what baseline testing showed agents skip.

## Three required behaviors

### 1. Run the review in three independent passes — not one linear scan

Baseline testing showed a single-pass review misses correctness issues that a focused pass would catch. Run three reviews against the diff, each with one question only:

| Pass | Single question to ask the diff |
|---|---|
| **Simplify** | What unnecessary complexity, duplication, dead code, or hand-rolled utility could be removed without changing behavior? |
| **Correctness** | Where could this be wrong? Edge cases, error paths, narrowed failure tolerance, mutation of caller-owned data, broken invariants, missing tests for new branches. |
| **Efficiency** | Where does this do more work than needed? N+1 calls, repeated I/O on hot paths, unbounded growth, leaked goroutines/handles, redundant writes. |

If the Task tool is available, dispatch the three passes in parallel as subagents. Otherwise do them inline as three separate read-throughs of the diff with the question above held in mind. **Do not collapse into one pass.**

### 2. Grep for callers of changed public symbols

Before claiming the diff is safe, for each public function/method/exported symbol whose **signature, return shape, or error contract changed**:

```bash
git grep -n '<symbol>' -- ':!vendor' ':!node_modules'
```

Baseline testing: agents flagged correctness risks ("might break callers") without ever checking whether callers exist. Either the risk is real (callers must change) or it isn't (no callers). Find out which.

### 3. Verify "skip" claims before honoring them

The user can skip gates explicitly. But verify the skip is justified before complying.

| User says | Before honoring, verify |
|---|---|
| "skip tests, they take too long" | Run a fast subset (`-run`/`--testPathPattern`/single file). If the affected suite finishes in < 30s, run it anyway and tell the user. |
| "skip lint" | Honor it. Lint is taste; tests are correctness. |
| "production is down, just commit" | Refusing to commit is incomplete. Pair every refusal with a concrete next step the user can take in <2 minutes (revert SHA, minimal diff, what bug to confirm). |

## Standard procedure

1. **Scope the diff.** `git status`, `git diff --stat`, `git diff`, `git diff --cached`. If empty, say so and stop.
2. **Detect toolchain.** Probe project files. If `AGENTS.md` declares lint/test commands, prefer those.
3. **Three-pass review** (rule 1). Apply fixes that are clearly correct and in scope. Flag the rest.
4. **Diff hygiene.** `git diff --check` for whitespace/conflict markers.
5. **Lint.** Run the detected linter on changed paths. If the linter is genuinely unavailable, say so explicitly — do not silently skip. Try one alternative (e.g., `go vet`/`gofmt` if `golangci-lint` missing).
6. **Tests.** Run the focused test command for affected modules. Use a writable cache if the default is blocked. If no tests exist for the changed code, say so — that is itself a finding.
7. **Caller check** (rule 2) for any changed public symbol.
8. **Report** in the structure below. Do not freeform-narrate.

## Report format (use these headings)

```
### Fixed
- <file>:<line> — what changed and why

### Flagged (not fixed)
- <file>:<line> — issue, severity (Critical/Important/Minor), why not auto-fixed

### Gates
- Three-pass review: <pass/issues found>
- Diff hygiene: <pass/fail>
- Lint: <command run> → <pass/fail/unavailable>
- Tests: <command run> → <pass/fail/none-exist>
- Caller check: <symbols checked> → <findings>

### Verdict
Ready to commit: <yes / no / yes-after-flags-resolved>
If no: one concrete next step the user can take in <2 minutes.
```

## Never

- Skip a gate silently. If a tool is unavailable, name it and say so.
- Refuse to commit without offering a concrete <2-minute next step.
- Argue with sub-pass output in the final report. Apply real findings, drop false positives, move on.
- Treat "I'm tired" / "it's urgent" as permission to skip gates. The user must explicitly name the gate.
