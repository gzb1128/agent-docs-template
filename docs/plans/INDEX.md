# Plans Index

Implementation plans capture **non-obvious execution strategy**: sequencing, files to touch, verification, rollback, and handoff context. They are useful when the execution path cannot be safely inferred from a single small diff.

Plans often link to a design doc in [../design/](../design/), but that is not a hard requirement. If the rationale is already clear, link the issue, codemap, commit, or other source of context instead.

## Plans

<!-- TODO: Add one row per plan, newest at the top. -->

| Date | Document | Status | Linked Context |
|------|----------|--------|----------------|
| _none yet — see [../_templates/plan.md](../_templates/plan.md) for the template_ | — | — | — |

## How to Add a Plan

1. Confirm the plan captures something non-derivable: execution order, risk, rollback, or handoff context
2. Copy [../_templates/plan.md](../_templates/plan.md) to `docs/plans/YYYY-MM-DD-<feature>.md`
3. Link the strongest context source: design doc, issue, codemap, or prior commit
4. Break work into independently verifiable tasks with exact commands where useful
5. Update `Status` as work proceeds: `Pending` → `In Progress` → `Done` (or `Cancelled`)
6. Add a row to this INDEX

## Naming

- `YYYY-MM-DD-<feature>.md` — date prefix keeps history browsable
- No `-plan` suffix needed; the directory provides context
- If 1:1 with a design, matching the date is convenient but not required

## Good Candidates

These are signals, not gates. Write a plan when it reduces execution risk or improves handoff.

| Signal | What to record |
|--------|----------------|
| Work spans several files or modules | Task order, files, and verification commands |
| Migration, rollout, or rollback risk | Safe sequence and fallback path |
| Multiple agents or people may execute it | Handoff contract and review checkpoints |
| Tests or verification are easy to get wrong | Exact commands and expected outputs |
| Follow-up work from a design doc | Scope split and implementation order |

Usually skip plans for typo fixes, pure formatting, direct one-file fixes, or changes where the commit message is sufficient execution history.

## Status Lifecycle

`Pending` → `In Progress` → `Done`

Use `Cancelled` (not delete) when scope changes. Keep the file; link forward to the replacement plan if one exists. The execution history is the audit trail.

## Anti-Patterns

| Don't | Do |
|-------|----|
| Write a plan as mandatory paperwork | Write one when sequencing or verification would otherwise be lost |
| Use vague steps ("add error handling") | Name the files, commands, and expected checks |
| Delete completed plans | Leave them at `Done` when they explain useful history |
| Force every plan to have a design doc | Link the strongest available context source |
