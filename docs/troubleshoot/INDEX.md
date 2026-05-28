# Troubleshoot — Diagnostic Guides

Diagnostic guides indexed by **symptom**. When an agent hits a problem, it locates the relevant doc by symptom rather than by root cause.

## Symptom Index

<!-- TODO: Add rows as you encounter recurring issues. Symptom-first, not cause-first. -->

| Symptom | Start here |
|---------|------------|
| _none yet — write the first one when you hit a recurring issue_ | — |

## How to Add a Troubleshoot Doc

1. Encountered a non-obvious issue? Write it up the same day.
2. File name: `<short-symptom>.md` (e.g., `pod-stuck-pending.md`, not `2026-05-28-incident.md`).
3. Structure:
   - **Symptom** — what the user/operator sees
   - **Likely causes** — ordered by frequency
   - **Diagnosis steps** — copy-paste commands
   - **Fix** — exact resolution
   - **Prevention** — link to relevant codemap/rule
4. Add a row to this INDEX with the symptom in user-facing language.

## When NOT to Add a Troubleshoot Doc

- One-off issues that won't recur → skip
- Operational procedures (no diagnosis needed) → `docs/runbooks/`
- "How does X work" questions → `docs/codemaps/`

## Archive Policy

When a troubleshoot doc is superseded by a better one, do NOT delete. Move it to `<topic>-archive.md` and add a row to a `<topic>-archive.md` table at the bottom of this INDEX noting why and which doc supersedes it.
