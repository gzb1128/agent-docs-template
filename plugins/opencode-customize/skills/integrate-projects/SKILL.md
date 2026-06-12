---
name: integrate-projects
description: Use when a project needs persistent access to multiple external project directories through opencode — integrating paths and descriptions as references so opencode can read those codebases without prompting. Triggers on "integrate projects", "add external projects", "link codebases", or "configure project references".
---

# Integrate External Projects

Configure an opencode project to access multiple external codebases persistently, skipping permission prompts and giving the agent the context it needs to work across them.

## What This Skill Does

One thing: **`references` in `opencode.json`**.

- opencode injects each reference's `name`, `path`, and `description` into the agent's system prompt at session start — the agent knows what each external codebase is and when to consult it without reading any files upfront.
- Referenced directories are automatically added to the `external_directory` allowlist — no permission prompts.
- The agent can then freely use `read`/`glob`/`grep` to explore those directories on demand.

Do NOT modify the project's `AGENTS.md` for this purpose. `AGENTS.md` belongs to the project's own knowledge. References are the right mechanism: each external project stays independent, the agent integrates them via the reference descriptions.

Optionally: **`permission.edit` deny rules** — only when the user wants read-only access to a referenced path.

**Key insight: `references` are automatically allowed.** opencode wires referenced directories into the `external_directory` allowlist at agent-initialization time. Do NOT add `permission.external_directory` allow rules for referenced paths, and do NOT add `"*": "ask"` anywhere in `permission.external_directory` — both break the auto-allow because opencode evaluates the LAST matching rule (`findLast`), and a user-added catch-all will override the built-in reference allowlist regardless of which config file it appears in.

**Always edit project-level config, never user-level (`~/.config/opencode/opencode.json`).**

## Workflow

### Step 1: Gather project information

Ask the user for each external project they want to integrate:

| Field | Required | Example |
|-------|----------|---------|
| **Absolute path** | Yes | `/Users/name/code/my-lib`, `~/code/api-server` |
| **Description** | Yes, or auto-infer | "Shared types and utilities consumed by this service" |
| **Alias** | No | Short name for `@` autocomplete. Defaults to directory basename. |
| **Read-only** | No | Deny `edit` for that path. Default: false. |

Accept input in any natural form. If a path exists, read its `AGENTS.md`, `README.md`, or `package.json` (first found) to auto-generate a richer description.

### Step 2: Update `opencode.json`

**How opencode loads config:** It walks up from cwd to the worktree root looking for `opencode.json` / `opencode.jsonc`, and separately loads `opencode.json` / `opencode.jsonc` from any `.opencode/` directory found along that walk. Both are loaded and deep-merged if both exist — there is no priority order between them. Check which file already exists and edit that one. If none exists, create `.opencode/opencode.json`.

#### references

```json
{
  "references": {
    "my-lib": {
      "path": "/Users/name/code/my-lib",
      "description": "Use for shared utility functions and type definitions"
    },
    "api-server": {
      "path": "~/code/api-server",
      "description": "Use for REST API endpoint definitions and request/response schemas"
    }
  }
}
```

- Alias key defaults to the directory basename.
- `path` must be absolute or use `~/`. Never relative paths — they resolve from the config file's directory, not the cwd.
- `description` starts with "Use for..." — this surfaces in the agent's system context to guide when it consults the reference.
- Do NOT add `permission.external_directory` rules for these paths — they are auto-allowed.

#### permission.edit (read-only paths only)

Only add when the user requests read-only access:

```json
{
  "permission": {
    "edit": {
      "/Users/name/code/my-lib/**": "deny"
    }
  }
}
```

Do NOT add `"*": "ask"` catch-alls in any permission block. The default is already `ask` for unmatched patterns, and an explicit catch-all overrides the built-in reference allowlist.

Deep-merge all changes: preserve all existing fields the user didn't ask to change.

### Step 3: Report

| Alias | Path | Access | Added |
|-------|------|--------|-------|
| my-lib | /Users/name/code/my-lib | read+write | ✓ |
| api-server | ~/code/api-server | read-only | ✓ |

Remind the user: **Restart opencode for changes to take effect.**

## Edge cases

- **Path does not exist**: Warn. Still write config (mark as `[missing]` in summary). The directory may be created later.
- **Path is inside current project**: Skip — already accessible. Tell the user.
- **Duplicate alias**: Ask whether to update the existing entry or use a different alias.
- **No opencode.json**: Create `.opencode/opencode.json` with `$schema` + new fields only.

## Common Mistakes

- **Adding `"*": "ask"` in any config file**: opencode uses `findLast` — the LAST matching rule wins. Any `"*": "ask"` in any config file is merged after the built-in reference allowlist, overrides it, and causes permission prompts. Never add it to `permission.external_directory`.
- **Modifying `AGENTS.md`**: Do not add integration context to the project's `AGENTS.md`. That file belongs to the project's own knowledge. The `description` field in `references` is the right place — opencode injects it into the agent's system prompt directly.
- **Forgetting to restart opencode**: Config changes have no effect until restart.
