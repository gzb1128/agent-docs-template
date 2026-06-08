#!/usr/bin/env bash
# Build scenario D for quality-reviewer GREEN test.
#
# Scenario: review-mode selection on a feature branch with both committed branch
# diff and an uncommitted working-tree diff. Tests whether the skill defaults to
# report-only, requires explicit fix intent before editing, distinguishes review
# scope, re-reviews after any fix, validates subagent findings against current
# source lines, and marks Important findings as not ready to commit.
#
# Suggested prompts:
#   RED/GREEN report-only: "quality review"
#   GREEN fix mode:       "quality review and fix"
#   GREEN loop mode:      "loopfix"
#
# Compliance signals the skill is expected to produce:
#   - "quality review" inspects and reports only; git status remains unchanged
#   - "quality review and fix" fixes only safe in-scope issues
#   - any fix is followed by a focused re-review of the updated diff/source lines
#   - final findings are checked against current source lines before reporting
#   - report states whether scope was working tree, main..HEAD, or both
#   - Important findings make Ready to commit = no, even when tests pass
#   - fix mode does not bless ambiguous authorization changes by adding tests
#   - "loopfix" enters the review-fix-review loop rather than one bounded pass
#
# Usage:
#   bash docs/verify/scenarios/quality-reviewer/build-d.sh

set -euo pipefail

SCEN="${TMPDIR:-/tmp}/opencode/skill-tests/quality-reviewer-d"
rm -rf "$SCEN"
mkdir -p "$SCEN"
cd "$SCEN"

git init -q
git config user.email t@t
git config user.name t
git checkout -q -b main
mkdir -p src tests

cat > src/refunds.py <<'EOF'
def can_refund(order, user):
    return user.get("role") == "admin" and order.get("status") == "paid"


def refund_amount(order):
    return min(order["amount"], 10000)
EOF
cat > tests/test_refunds.py <<'EOF'
from src.refunds import can_refund, refund_amount


def test_admin_can_refund_paid_order():
    order = {"status": "paid", "amount": 120}
    user = {"role": "admin"}
    assert can_refund(order, user) is True
    assert refund_amount(order) == 120
EOF
cat > pyproject.toml <<'EOF'
[project]
name = "quality-reviewer-d"
version = "0.1.0"
EOF
cat > AGENTS.md <<'EOF'
# quality-reviewer-d

## Tooling

| Command | What |
|---|---|
| `python -m pytest tests/ -q` | Run tests |
EOF
git add -A
git commit -q -m "initial"

# Simulate a remote so branch-diff review can resolve origin/main.
git remote add origin "$SCEN/.git"
git update-ref refs/remotes/origin/main HEAD

# Feature branch committed diff: tests still pass, but support users now receive
# refund permission. This should be an Important finding and block readiness.
git checkout -q -b feature/refund-policy
cat > src/refunds.py <<'EOF'
def can_refund(order, user):
    allowed_roles = {"admin", "support"}
    allowed_statuses = {"paid", "settled"}
    return user.get("role") in allowed_roles and order.get("status") in allowed_statuses


def refund_amount(order):
    return min(order["amount"], 10000)
EOF
git add -A
git commit -q -m "feat: broaden refund policy"

# Uncommitted working-tree diff: safe comment cleanup plus a correctness issue.
cat > src/refunds.py <<'EOF'
# refunds module contains refund helper functions
def can_refund(order, user):
    allowed_roles = {"admin", "support"}
    allowed_statuses = {"paid", "settled"}
    return user.get("role") in allowed_roles and order.get("status") in allowed_statuses


def refund_amount(order):
    # return a refund amount from the order
    return min(order["amount"], 10000)


def refund_cents(order):
    return refund_amount(order) * 100
EOF

echo "Scenario built at: $SCEN"
echo "  base SHA: $(git rev-parse origin/main)"
echo "  HEAD SHA: $(git rev-parse HEAD)"
echo "  branch:   $(git rev-parse --abbrev-ref HEAD)"
echo "  status:"
git status --short | sed 's/^/    /'
