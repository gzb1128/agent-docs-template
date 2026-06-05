# Design Docs Index

Design docs capture **non-obvious decisions and rationale** that cannot be derived from source code, git history, or existing docs. They are not required for every change.

Use [../rules/non-derivability.md](../rules/non-derivability.md) as the filter: if the next agent can infer the decision by reading the code and commit message, do not add a design doc.

If you're looking for **how a design was executed**, see [../plans/INDEX.md](../plans/INDEX.md).

## Designs

<!-- Put the newest design at the top. -->

| Date | Document | Topic | When to Read |
|------|----------|-------|--------------|
| _none yet — see [../_templates/design.md](../_templates/design.md) for the template_ | — | — | — |

## How to Add a Design Doc

1. Confirm the decision is non-derivable: alternatives, tradeoffs, rollout constraints, or root cause would not be obvious from code
2. Copy [../_templates/design.md](../_templates/design.md) to `docs/design/YYYY-MM-DD-<topic>-design.md`
3. Record the decision: problem, chosen approach, important alternatives, and links to source/codemaps
4. Add a row to this INDEX with the scenario that should trigger future readers
5. If implementation needs sequencing or handoff, add a plan in [../plans/](../plans/)

## Naming

- `YYYY-MM-DD-<topic>-design.md` — date prefix keeps history browsable
- No version suffix; supersede by editing in place or creating a new dated doc with `Supersedes:` linking back

## Good Candidates

These are signals, not gates. Write a design doc only when it captures something non-derivable.

| Signal | What to record |
|--------|----------------|
| Several viable approaches | Why this approach won; what was rejected |
| Cross-module behavior or ownership boundary | The boundary and the coupling that code alone does not reveal |
| Schema/API/contract change | Compatibility, rollout, and rollback reasoning |
| Non-obvious bug root cause | Why the visible symptom pointed somewhere misleading |
| Operational ordering or migration risk | Required sequence, safety checks, rollback path |

Usually skip design docs for typo fixes, purely mechanical changes, formatting, or local refactors whose intent is obvious from the diff and commit message.

## Anti-Patterns

| Don't | Do |
|-------|----|
| Write a design doc just because a change touched code | Write one because the decision would otherwise be lost |
| Duplicate implementation details from source | Link to source/codemaps and record rationale |
| Treat design docs as mandatory paperwork | Keep the bar high: non-obvious, useful, and maintainable |
| Delete superseded designs | Mark them superseded or link forward so history remains traceable |
