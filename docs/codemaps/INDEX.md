# Code Maps Index

Code maps provide a navigable view of the system architecture. **Maps, not encyclopedias** — use tables that map concepts to file paths, link to source, never copy code content into the map.

## Available Maps

<!-- TODO: Add one row per component. Delete this placeholder when populated. -->

| Document | Description | Target Audience |
|----------|-------------|-----------------|
| _none yet — see `docs/_templates/codemap.md` for the template_ | — | — |

## When to Create a Code Map

Create a codemap for a component when ANY of:

- It has 3+ consumer packages
- It implements a state machine or non-trivial protocol
- A new contributor would need > 30 minutes to navigate it from source alone
- It crosses module boundaries (e.g., API + DB + worker)

Do NOT create a codemap for:

- Single-file utilities
- Generated code (link to the generator instead)
- Code that's about to be replaced

## Code Map Depth Guidelines

Document depth scales with the module's **consumer count and interface complexity**:

| Module role | Criteria | Recommended depth |
|-------------|----------|-------------------|
| Core | 3+ consumer packages, has state machine, cross-module constraints | ~200-300 lines |
| Standard | 1-2 consumer packages, no state machine | ~100 lines |
| Leaf | No internal consumers, self-contained | ≤ 50 lines |

Quick check: `rg "<package-path>" --glob '*.<ext>' | wc -l`. > 20 references = core; < 5 = leaf.

## Naming

- `docs/codemaps/<component>.md` for flat structure
- `docs/codemaps/<area>/<component>.md` if you have 10+ codemaps in one area

## Anti-Patterns

| ❌ Don't | ✅ Do |
|---------|------|
| Copy function bodies into the codemap | Link to `path/to/file.go:42` |
| Copy entire YAML configs | Table: file → purpose → key fields |
| Write a tutorial in the codemap | Tutorials go in `docs/runbooks/` or `docs/verify/` |
| Update only the codemap when source changes | Update both, or just link to source |
