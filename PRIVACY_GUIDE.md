# 🔒 Privacy & Security Guide for Pocket Agent Fork

**Important:** Your fork is SEPARATE from the upstream repo. Your personal info stays private unless you explicitly make it public.

---

## 🎯 How GitHub Forks Work

### Your Fork vs. Upstream

```
KenKaiii/pocket-agent (upstream)
    ↓ (you forked it)
g-baskin/pocket-agent (YOUR fork)
    ↑
Your changes stay HERE
    ↑
Upstream CANNOT see your changes
    ↑
Unless you create a Pull Request
```

### Key Points:

1. **Your fork is YOURS** - It's a separate repository
2. **Upstream maintainer CANNOT see your fork** automatically
3. **Your changes stay on your fork** unless you send a Pull Request
4. **Even if your fork is public**, people have to specifically look for it

---

## 🛡️ What's Protected (Already in .gitignore)

### ✅ Automatically Ignored:

```bash
# API Keys & Secrets
.env
.env.local
*.key
*.secret
*.token
config.json

# Your Conversations & Data
*.db
*.db-journal
*.sqlite
*.sqlite3

# Personal Files
.custom-config/
NOTES.md
TODO-private.md
*-private.md
*-personal.*
*.local.md

# System Files
node_modules/
dist/
.DS_Store

# Build artifacts
release/
*.cer
```

---

## ⚠️ What Could Be Exposed (If You're Not Careful)

### ❌ DO NOT Commit:

1. **API Keys** - Never hardcode in source files
   ```typescript
   // ❌ BAD - This would be visible on GitHub
   const API_KEY = "sk-ant-1234567890";

   // ✅ GOOD - Use environment variables
   const API_KEY = process.env.ANTHROPIC_API_KEY;
   ```

2. **Personal Information in Code Comments**
   ```typescript
   // ❌ BAD
   // My email: your.email@gmail.com
   // My address: 123 Main St

   // ✅ GOOD
   // Contact info loaded from environment
   ```

3. **Database Files** - Already protected, but double-check

4. **Custom Instructions with Personal Details**
   - Use `-private.md` or `-local.md` suffix (auto-ignored)

---

## ✅ Safe Development Workflow

### Before You Push - ALWAYS Check:

```bash
# 1. See what will be committed
git status

# 2. See the actual changes
git diff

# 3. Check staged files
git diff --staged

# 4. Dry run - see what would be pushed
git push --dry-run origin custom-features
```

### Safe Push Checklist:

```bash
# Step 1: Review changes
cd ~/Desktop/Projects/pocket-agent
git status

# Step 2: Check for sensitive data
git diff | grep -i "api.key\|password\|secret\|token\|email.*@"

# Step 3: If clean, commit
git add <specific-files>  # DON'T use "git add ."
git commit -m "Description of changes"

# Step 4: Verify before push
git log -1 --stat  # See what's in the commit
git show  # See full commit content

# Step 5: Push to YOUR fork (not upstream)
git push origin custom-features
```

---

## 🚀 Recommended: Use Personal Branch

Keep sensitive work on a LOCAL-ONLY branch:

```bash
# Create a private local branch
git checkout -b custom-private

# Make changes with personal info
# ... edit files ...

# This branch NEVER gets pushed
# Only merge safe changes to custom-features
```

### Workflow:

```
custom-private (local only - has personal info)
    ↓ cherry-pick safe changes
custom-features (safe to push to YOUR fork)
    ↓ (optional) pull request
upstream/main (original repo)
```

---

## 📋 Best Practices

### 1. Use Environment Variables

Create `.env` (already gitignored):
```bash
# .env - NEVER COMMITTED
ANTHROPIC_API_KEY=sk-ant-your-key-here
OPENAI_API_KEY=sk-your-openai-key
TELEGRAM_BOT_TOKEN=123456:ABC-DEF
MY_EMAIL=you@example.com
```

Load in code:
```typescript
import * as dotenv from 'dotenv';
dotenv.config();

const apiKey = process.env.ANTHROPIC_API_KEY;
```

### 2. Separate Personal Config

Create `.custom-config/` (already gitignored):
```
.custom-config/
├── identity.json
├── custom-prompts.txt
└── personal-settings.json
```

### 3. Use Suffixes for Personal Files

Any file ending with these is auto-ignored:
- `*-private.md`
- `*-personal.*`
- `*.local.md`

Examples:
- `prompts-private.md` ✅ Safe
- `config-personal.json` ✅ Safe
- `identity.local.md` ✅ Safe

### 4. Review Commits Before Pushing

```bash
# See what you're about to push
git log origin/custom-features..HEAD

# See the actual diff
git diff origin/custom-features..HEAD

# If you see personal info, DO NOT PUSH
```

---

## 🔍 Verify Your Privacy Right Now

Run this to check what would be exposed:

```bash
cd ~/Desktop/Projects/pocket-agent

echo "🔍 Checking for sensitive data..."
echo ""

# Check staged files
echo "📝 Staged files (would be committed):"
git diff --staged --name-only
echo ""

# Check for common sensitive patterns
echo "⚠️  Searching for potential secrets in tracked files:"
git grep -i "api.key\|password\|secret.*=\|token.*=" src/ || echo "✅ None found"
echo ""

# Check what's ignored vs tracked
echo "📊 File status:"
git status --short
echo ""

echo "✅ Review complete. If you see sensitive data above, DON'T PUSH!"
```

---

## 🆘 Emergency: Accidentally Committed Sensitive Data

### If you HAVEN'T pushed yet:

```bash
# Remove last commit (keep changes)
git reset HEAD~1

# Remove file from staging
git reset HEAD <file-with-secrets>

# Edit file to remove secrets
code <file-with-secrets>

# Re-commit without secrets
git add <file-with-secrets>
git commit -m "Fixed version without secrets"
```

### If you ALREADY pushed:

```bash
# 1. Remove from commit history (DANGEROUS)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/sensitive/file" \
  --prune-empty --tag-name-filter cat -- --all

# 2. Force push (overwrites GitHub)
git push origin custom-features --force

# 3. Rotate compromised secrets immediately
# - Generate new API keys
# - Update .env with new keys
```

**Better:** Delete the fork and start fresh if secrets are exposed.

---

## 📊 Privacy Levels

### Level 1: Public Fork (Safest for Code Sharing)
- ✅ Code changes visible
- ❌ No personal info committed
- ❌ No API keys
- ❌ No conversation history
- ✅ Can accept contributions

### Level 2: Private Fork (More Control)
Go to: https://github.com/g-baskin/pocket-agent/settings
- Set repository to **Private**
- Only you can see it
- Can still pull updates from upstream
- Can't accept public contributions

### Level 3: Local Only (Maximum Privacy)
- Don't push to GitHub at all
- Keep everything local
- Manual backup to external drive
- No collaboration features

---

## 🎯 Recommended Setup for You

Based on your concern about privacy:

```bash
# 1. Keep sensitive work local
git checkout -b custom-private  # Local only

# 2. Create clean branch for code-only changes
git checkout -b custom-features  # Safe to push

# 3. Only push code changes, never personal info
# Use .gitignore (already configured)
# Review before every push

# 4. Consider making your fork private
# Go to: https://github.com/g-baskin/pocket-agent/settings
```

---

## ✅ Privacy Checklist

Before pushing to YOUR fork:

- [ ] Ran `git status` to see what's being committed
- [ ] Ran `git diff` to see actual changes
- [ ] Checked for API keys, emails, personal info
- [ ] Verified `.env` files are NOT being committed
- [ ] Verified database files are NOT being committed
- [ ] Used descriptive but generic commit messages
- [ ] Pushing to `origin` (YOUR fork), not `upstream`
- [ ] Comfortable with code being visible on YOUR fork

---

## 🔐 Summary

### What Upstream (KenKaiii) CAN'T See:
- ❌ Your fork's content (unless they look for it)
- ❌ Your commits on your fork
- ❌ Your branches
- ❌ Your personal files
- ❌ Your .env files
- ❌ Your database files

### What Upstream CAN See:
- ✅ Your Pull Requests (if you create one)
- ✅ Your issues on their repo
- ✅ Your comments on their issues/PRs

### What's On YOUR Fork (if public):
- ✅ Code you commit and push
- ❌ Files in .gitignore (protected)
- ❌ Local branches you don't push

---

## 🛠️ Tools to Help

### Check before push:
```bash
# Save this as scripts/safety-check.sh
#!/bin/bash
echo "🔒 Privacy Safety Check"
echo "━━━━━━━━━━━━━━━━━━━━"
git diff --staged | grep -E "(api[_-]?key|password|secret|token|@.*\.com)" && \
  echo "⚠️  WARNING: Potential sensitive data detected!" || \
  echo "✅ No obvious secrets found"
```

### Pre-commit hook:
```bash
# .git/hooks/pre-commit
#!/bin/bash
if git diff --cached | grep -qE "sk-ant-|password.*=|secret.*="; then
  echo "❌ BLOCKED: Sensitive data detected in commit!"
  exit 1
fi
```

---

**Created:** 2026-02-09
**Your Privacy:** Maximum Priority
**Your Fork:** https://github.com/g-baskin/pocket-agent (YOU control this)
**Upstream:** https://github.com/KenKaiii/pocket-agent (They can't see your fork)
