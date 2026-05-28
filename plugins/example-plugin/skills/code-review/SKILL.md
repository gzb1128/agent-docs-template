---
name: code-review
description: This skill should be used when the user asks to "review code", "check my changes", "review PR", or discusses code quality. Provides structured code review with bug detection, security analysis, and performance suggestions.
version: 1.0.0
---

# Code Review Skill

Perform a structured code review on recently changed files or specified code.

## Review Checklist

When reviewing code, systematically check:

1. **Correctness**: Logic errors, off-by-one errors, unhandled edge cases
2. **Security**: Input validation, SQL injection, XSS, secrets in code
3. **Performance**: N+1 queries, unnecessary allocations, missing indices
4. **Readability**: Naming conventions, function length, comments where needed
5. **Testing**: Test coverage for new logic, edge case tests

## Process

1. Use `git diff` to identify changed files
2. Read each changed file
3. For each file, evaluate against the checklist above
4. Report findings as a prioritized list (Critical > Warning > Suggestion)
5. Provide actionable fix suggestions with code snippets

## Output Format

For each finding:
- **Severity**: Critical / Warning / Suggestion
- **File**: path/to/file:line_number
- **Issue**: One-line description
- **Fix**: Suggested code change
