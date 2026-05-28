# Example Plugin

A demonstration plugin for the agent-docs-template marketplace.

## Skills

### code-review
Model-invoked skill that activates when the user discusses code review, PR review, or code quality.

```
/example-plugin:code-review
```

### git-workflow
User-invoked slash command for guided git operations (commit, PR, merge, conflict resolution).

```
/example-plugin:git-workflow commit
/example-plugin:git-workflow pr
/example-plugin:git-workflow merge
/example-plugin:git-workflow conflict
```

## Installation

```bash
/plugin marketplace add ./path/to/this/repo
/plugin install example-plugin@agent-docs-plugins
```
