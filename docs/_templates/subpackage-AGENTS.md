# {{MODULE_NAME}}

> Template — copy to `<sub-package>/AGENTS.md` for complex modules.
> Use this ONLY when the module meets at least one criterion in the parent repo's
> `docs/rules/document-conventions.md` ("When to Add a Sub-Package AGENTS.md").
>
> **Before committing this file, replace every `{{REPO_ROOT}}` with the relative
> path from this file's location back to the repo root** (e.g., `..` for a
> top-level package, `../..` for `internal/foo/`, `../../..` for `internal/foo/bar/`).

<one-sentence description of what this module does>

## Quick Reference

| Action | Command / File |
|--------|----------------|
| Run tests | `{{TEST_COMMAND}}` |
| Key entry | `file.ext:line` |
| State definitions | `state.ext:line` |

## Boundary

<!-- What this module owns vs. what's owned elsewhere. Cuts off entire classes of "where do I put this?" questions. -->

```
                    ┌────────────┐
   inputs       →   │ {{MODULE}} │   →   outputs
                    └────────────┘
```

| Concern | Owner |
|---------|-------|
| {{CONCERN_A}} | this module |
| {{CONCERN_B}} | `path/to/other/module/` |

## State Machine / Core Flow

<!-- If the module has explicit states, draw the transitions and list invalid transitions. -->

```
init  →  doing  →  done
              ↘  failed
```

## Critical Invariants

- {{INVARIANT_1}}
- {{INVARIANT_2}}

## Documentation Sync

When you modify this module, ALSO update:

| Change | Must update |
|--------|-------------|
| Add a new state | `state.ext`, this AGENTS.md, `{{REPO_ROOT}}/docs/codemaps/{{THIS}}.md` |
| Change wire protocol | `{{REPO_ROOT}}/docs/codemaps/{{THIS}}.md`, downstream consumers' docs |

## Common Pitfalls

- {{PITFALL_1}}
- {{PITFALL_2}}

## Related Docs

- [{{REPO_ROOT}}/docs/codemaps/{{THIS}}.md]({{REPO_ROOT}}/docs/codemaps/{{THIS}}.md)
- [{{REPO_ROOT}}/docs/rules/document-conventions.md]({{REPO_ROOT}}/docs/rules/document-conventions.md)
