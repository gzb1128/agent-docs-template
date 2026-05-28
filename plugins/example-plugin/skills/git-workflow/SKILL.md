---
name: git-workflow
description: This skill should be used when the user asks to "commit", "create PR", "merge", "rebase", "resolve conflict", or discusses git workflow operations. Provides guided git workflows with best practices.
version: 1.0.0
disable-model-invocation: true
argument-hint: <action> [args]
allowed-tools: [Bash, Read, Glob, Grep]
---

# Git Workflow Skill

Guide git operations with best practices and safety checks.

## Arguments

The user invoked this with: $ARGUMENTS

## Supported Actions

### commit
1. Run `git status` and `git diff --stat` to see changes
2. Stage appropriate files (never stage secrets or large binary files)
3. Generate a commit message that explains WHY (business impact), not WHAT
4. Confirm with user before committing

### pr / pull-request
1. Ensure current branch is up to date with base
2. Run lint and tests first
3. Push branch to remote
4. Create PR with descriptive title and body

### merge
1. Verify CI passes on the source branch
2. Check for merge conflicts
3. Suggest merge strategy (squash for feature branches, merge for release)
4. Execute merge

### conflict
1. Identify conflicted files with `git diff --name-only --diff-filter=U`
2. For each conflict, read the file and analyze both sides
3. Propose resolution preserving both intents where possible
4. Stage resolved files and continue rebase/merge

## Safety Rules

- Never force-push to shared branches (main, develop, release/*)
- Always verify CI passes before merging
- Never commit secrets — scan for API keys, tokens, passwords
- Prefer `--no-ff` merges to preserve branch history
