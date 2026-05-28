# Lib — Third-Party Library Notes

Project-specific usage notes for third-party libraries/frameworks. **Not generic tutorials** — only document the parts of a library that have non-obvious behavior in *this* codebase: known pitfalls, our chosen idioms, gotchas, version constraints.

## Libraries

<!-- TODO: Add a row when you discover a non-obvious behavior or settle on a project idiom for a library. -->

| Document | Library / Framework | When to Read |
|----------|---------------------|--------------|
| _none yet_ | — | — |

## How to Add a Lib Doc

Only add a lib doc when ONE of:

- The library has a well-known footgun the team keeps hitting
- We've chosen one option from several (e.g., "we use `resty` v3 not v2 — here's why")
- The official docs are incomplete or misleading for our use case
- We have a project-specific wrapper / convention around the library

Structure:
- **Library and version** — what we use
- **Why this library** — alternatives considered (optional)
- **Project idioms** — how we use it here
- **Pitfalls** — concrete bugs we've hit
- **Reference** — link to official docs

## Anti-Patterns

- ❌ Copying the library's tutorial into our docs — link to upstream
- ❌ Documenting every feature — only document non-obvious parts
- ❌ Stale version numbers — pin and update when you bump
