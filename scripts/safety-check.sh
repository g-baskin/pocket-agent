#!/bin/bash
# Privacy & Safety Check - Run before pushing to GitHub

echo "🔒 Privacy Safety Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$(dirname "$0")/.."

# Check if there are staged changes
STAGED=$(git diff --staged --name-only)
if [ -z "$STAGED" ]; then
    echo "ℹ️  No staged changes to check"
    echo ""
    echo "To check unstaged changes: git diff"
    exit 0
fi

echo "📝 Files staged for commit:"
git diff --staged --name-only
echo ""

# Check for common sensitive patterns
echo "🔍 Scanning for sensitive data..."
FOUND_SECRETS=0

# Search staged content for patterns
if git diff --staged | grep -qE "(sk-ant-|sk-|api[_-]?key.*=|password.*=|secret.*=|token.*=|[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})"; then
    echo "⚠️  WARNING: Potential sensitive data detected!"
    echo ""
    echo "Found in staged changes:"
    git diff --staged | grep -E "(sk-ant-|sk-|api[_-]?key|password|secret|token|@.*\.(com|net|org))" | head -5
    echo ""
    FOUND_SECRETS=1
fi

# Check for ignored files being committed
echo ""
echo "🚫 Checking for .gitignore violations..."
IGNORED_FILES=$(git ls-files -i --exclude-standard)
if [ -n "$IGNORED_FILES" ]; then
    echo "⚠️  WARNING: These ignored files are tracked:"
    echo "$IGNORED_FILES"
    echo ""
    FOUND_SECRETS=1
fi

# Check for .env files
if git diff --staged --name-only | grep -qE "\.env|config\.json|.*\.key|.*\.secret"; then
    echo "⚠️  WARNING: Environment or secret files detected!"
    git diff --staged --name-only | grep -E "\.env|config\.json|.*\.key|.*\.secret"
    echo ""
    FOUND_SECRETS=1
fi

# Check for database files
if git diff --staged --name-only | grep -qE "\.db$|\.sqlite"; then
    echo "⚠️  WARNING: Database files detected (may contain personal data)!"
    git diff --staged --name-only | grep -E "\.db$|\.sqlite"
    echo ""
    FOUND_SECRETS=1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FOUND_SECRETS -eq 1 ]; then
    echo "❌ SAFETY CHECK FAILED"
    echo ""
    echo "Action required:"
    echo "  1. Remove sensitive data from files"
    echo "  2. Unstage files: git reset HEAD <file>"
    echo "  3. Add to .gitignore if needed"
    echo "  4. Run this check again"
    echo ""
    exit 1
else
    echo "✅ SAFETY CHECK PASSED"
    echo ""
    echo "No obvious sensitive data detected."
    echo "Still review your changes manually:"
    echo "  git diff --staged"
    echo ""
    echo "Safe to commit and push to YOUR fork."
    exit 0
fi
