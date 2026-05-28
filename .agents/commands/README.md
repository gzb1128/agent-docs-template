# Manual-Trigger Commands

These markdown files are **command bodies, not skills**. They live here as
ready-to-use prompts that you should wire into your own agent's command system
(slash commands, custom triggers, etc.) and invoke **deliberately** — not
automatically during normal work.

## Why "commands" and not "skills"?

Skills get auto-loaded into the agent's attention budget and influence every
turn. The two commands here (`learn`, `remember`) describe **session-bracketing
chores** — knowledge harvesting at the end of a session, knowledge auditing on
demand. If the model is constantly weighing "should I learn this now?" mid-task,
it splits attention and produces lower-quality work.

Keeping them as manually-triggered commands gives you:

- **Predictable context cost** — the prompts only enter the model when you ask
- **Sharper outputs** — the model focuses fully on the meta-task when invoked
- **Better failure modes** — a forgotten `/learn` at session end is recoverable;
  a half-baked auto-learn polluting `AGENTS.md` is not

## What's here

| Command | Purpose | When to invoke |
|---------|---------|----------------|
| [learn.md](learn.md) | Persist non-obvious insights from the current session to the right `AGENTS.md`. Enforces the [Non-Derivability Principle (不可推导原则)](../../docs/rules/INDEX.md). | At the end of a session that uncovered hidden dependencies, misleading errors, workarounds, or critical ordering |
| [remember.md](remember.md) | Audit existing `## Hidden Knowledge` sections for staleness, duplication, misplacement. Reports proposals; never auto-applies. | Periodically, or when `AGENTS.md` files start to feel noisy or stale |

## How to wire them up

The exact mechanism depends on your agent. Pick the one that matches:

| Agent | Where to put the command | Trigger |
|-------|--------------------------|---------|
| **opencode** | `.opencode/command/learn.md`, `.opencode/command/remember.md` (symlink or copy) | `/learn`, `/remember` |
| **Claude Code** | `.claude/commands/learn.md`, `.claude/commands/remember.md` | `/learn`, `/remember` |
| **Codex CLI** | Your custom prompt-launcher / shell alias | `codex < .agents/commands/learn.md` or similar |
| **Other / custom** | Wherever your agent reads command definitions | Whatever invocation syntax it uses |

**Recommended: symlink, don't copy.** That way upstream improvements to the
command body flow through automatically:

```bash
# Example for opencode:
mkdir -p .opencode/command
ln -s ../../.agents/commands/learn.md    .opencode/command/learn.md
ln -s ../../.agents/commands/remember.md .opencode/command/remember.md
```

If your agent does not support symlinks for command discovery, copy the files
and re-sync them when the template updates.

## Do NOT promote these to skills

If you find yourself thinking "this command would be nice as a skill so the
model can fire it automatically" — resist. The whole point of putting them here
is that the human (or the controlling agent loop) decides *when* knowledge
persistence and auditing happen. Skills that fire on their own will pollute
`AGENTS.md` faster than `/remember` can clean it.

## Adding more commands

The `learn`/`remember` pair is a starting set. Reasonable additions follow the
same pattern — chores that benefit from focused, on-demand invocation rather
than ambient skill-style activation. Examples your team may want to add:

- `/audit-codemaps` — verify codemap file paths still exist
- `/rotate-design` — move stale design docs to an archive
- `/release-notes` — diff the last tag and draft a changelog entry

Keep one principle in mind when adding: **if the model should think about it
every turn, it's a skill; if a human (or the controlling loop) should decide
when to run it, it's a command.**
