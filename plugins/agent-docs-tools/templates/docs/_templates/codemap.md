# Code Map: {{COMPONENT_NAME}}

> Template — copy to `docs/codemaps/<component>.md` and customize.
> Delete this blockquote when filling in.

**Role:** {{COMPONENT_ROLE}} <!-- e.g., "HTTP API server", "async task executor" -->

## Quick Reference

| Action | File / Command |
|--------|----------------|
| Entry point | `path/to/main.go:1` |
| Tests | `go test ./path/...` |
| Key config | `config/component.yaml` |

## Architecture

<!-- 1-3 paragraphs OR a small diagram. Keep it focused on this component. -->

```
                  ┌────────────┐
   incoming   →   │ {{NAME}}   │   →   downstream
                  └────────────┘
```

## File Index

| Concept | File |
|---------|------|
| HTTP routing | `path/to/router.go` |
| Request handlers | `path/to/handlers/*.go` |
| Domain model | `path/to/model.go` |

<!-- Keep file paths up to date. Link to specific lines (`file.go:42`) when stable. -->

## Critical Invariants

<!-- Hard rules that callers must respect, or that this component guarantees. -->

- {{INVARIANT_1}}
- {{INVARIANT_2}}

## Related Maps

- [Related component A](./component-a.md)
- [Related rule](../rules/{{RULE_NAME}}.md)

## What This Map Does NOT Cover

<!-- Explicitly list what's out of scope so agents don't expect to find it here. -->

- Implementation details of individual handlers — see source
- Database schema — see [database.md](./database.md)
