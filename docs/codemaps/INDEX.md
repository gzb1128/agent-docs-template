# Code Maps Index

Code maps provide a navigable view of system architecture. **Maps, not encyclopedias** — map concepts to file paths, link to source, and avoid copying code/config content.

Use the [Non-Derivability Principle](../rules/non-derivability.md): a codemap should record boundaries, ownership, workflows, and cross-module relationships that are hard to infer from a single file scan.

## Available Maps

<!-- TODO: Add one row per component. Delete this placeholder when populated. -->

| Document | Description | Target Audience |
|----------|-------------|-----------------|
| _none yet — see [../_templates/codemap.md](../_templates/codemap.md) for the template_ | — | — |

## Creation Guidance

These are signals, not gates. Create or update a codemap when it helps future agents navigate something non-obvious:

- Component boundaries and ownership are not obvious from directory names
- A workflow crosses modules (e.g., API + DB + worker)
- A state machine, protocol, or lifecycle is easier to understand as a map
- A new contributor repeatedly asks "where does this start?"

Usually skip a dedicated codemap for single-file utilities, generated code, or code that is about to be replaced.

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

| Don't | Do |
|-------|----|
| Copy function bodies into the codemap | Link to `path/to/file.go:42` |
| Copy entire YAML configs | Table: file → purpose → key fields |
| Write a tutorial in the codemap | Tutorials go in `docs/runbooks/` or `docs/verify/` |
| Update only the codemap when source changes | Update both, or just link to source |
