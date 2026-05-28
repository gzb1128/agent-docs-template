# Runbooks — Operational Procedures

**Deterministic operational procedures.** No diagnosis, no troubleshooting. Each runbook is a checklist that produces a predictable outcome given the preconditions.

If diagnosis is needed → `docs/troubleshoot/INDEX.md` instead.

## Runbooks

<!-- TODO: Add rows as you formalize operational procedures. -->

| Document | Operation | Preconditions |
|----------|-----------|---------------|
| _none yet_ | — | — |

## How to Add a Runbook

1. The procedure must be **deterministic** — same inputs always produce the same outcome.
2. File name: `<verb-object>.md` (e.g., `rotate-tls-cert.md`, `restart-worker.md`).
3. Structure:
   - **Purpose** — one sentence
   - **Preconditions** — access, tools, state required
   - **Steps** — numbered, copy-pasteable
   - **Verification** — how to confirm success
   - **Rollback** — if applicable
4. Add a row to this INDEX.

## When NOT to Add a Runbook

- Procedure requires judgment / diagnosis → use `docs/troubleshoot/`
- One-off migration → put in `docs/plans/YYYY-MM-DD-<feature>.md`
- Developer workflow (build, test) → root `AGENTS.md` "Quick Reference"
