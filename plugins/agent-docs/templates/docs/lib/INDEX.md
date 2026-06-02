# Lib — Third-Party Library Notes

Project-specific usage notes for third-party libraries/frameworks. **Not generic tutorials** — only document the parts of a library that have non-obvious behavior in *this* codebase: known pitfalls, our chosen idioms, gotchas, version constraints.

## Libraries

<!-- TODO: Add a row when you discover a non-obvious behavior or settle on a project idiom for a library. -->

| Document | Library / Framework | When to Read |
|----------|---------------------|--------------|
| _none yet_ | — | — |

## Good Candidates

Add a lib doc when it captures project-specific knowledge that is not obvious from upstream docs or source code:

- The library has a footgun the team keeps hitting
- The project chose one option from several (e.g., "we use `resty` v3 not v2 — here's why")
- The official docs are incomplete or misleading for this use case
- The project has a wrapper or convention around the library

Structure:
- **Library and version** — what we use
- **Why this library** — alternatives considered (optional)
- **Project idioms** — how we use it here
- **Pitfalls** — concrete bugs we've hit
- **Reference** — link to official docs

## Anti-Patterns

- Copying the library's tutorial into our docs — link to upstream
- Documenting every feature — only document non-obvious parts
- Stale version numbers — pin and update when you bump
