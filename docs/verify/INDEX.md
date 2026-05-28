# Verify — Verification Flow Index

**Purpose:** Dry-run and local verification flows for the system. Prefer deterministic local tests over hitting real environments. No writes to production DB, no real deploys, no Argo workflow submissions.

## Verification Flows

<!-- TODO: Add a row per verification flow. -->

| Scenario | Document | Purpose |
|----------|----------|---------|
| _none yet_ | — | — |

## When to Add a Verify Doc

Add a verify flow when:

- A change is risky enough that the team needs a repeatable local check before deploying
- The flow is reusable (not a one-off debug session)
- It can be done WITHOUT touching production resources

## Verify vs Runbook vs Troubleshoot

| Type | Trigger | Outcome |
|------|---------|---------|
| **Verify** (this dir) | "Is my change safe?" | Confidence to deploy |
| **Runbook** | "Do the operation" | State change in production |
| **Troubleshoot** | "Something's wrong" | Root cause + fix |

## Structure

Each verify doc should include:
- **Goal** — what behavior is being verified
- **Setup** — local prerequisites (no production access)
- **Steps** — copy-pasteable commands with expected output
- **Pass/Fail criteria** — exact strings or values to look for
- **Cleanup** — restore local state
