# Pocket Agent Development Setup Guide
## How to Customize While Staying Updated

This guide shows you how to make custom changes to Pocket Agent while still being able to pull updates from the original repository.

---

## 1️⃣ Initial Setup

### Clone your fork
```bash
cd ~/Desktop/Projects
git clone https://github.com/g-baskin/pocket-agent.git
cd pocket-agent
```

### Add the original repo as "upstream"
```bash
git remote add upstream https://github.com/KenKaiii/pocket-agent.git
git remote -v
# Should show:
# origin    https://github.com/g-baskin/pocket-agent.git (your fork)
# upstream  https://github.com/KenKaiii/pocket-agent.git (original)
```

### Create a custom branch for your changes
```bash
git checkout -b custom-features
```

---

## 2️⃣ Making Safe Customizations

### **Where to Make Changes (Won't Conflict)**

#### ✅ **Safe to Customize:**

1. **Configuration Files**
   - `src/config/identity.ts` - Your custom identity/personality
   - `src/config/instructions.ts` - Custom system instructions
   - `.env` - Your API keys and settings (never committed)

2. **User-Specific Files**
   - Create new files in `src/tools/custom/` for your own tools
   - Add your own scripts in `scripts/custom/`
   - Custom themes in `src/renderer/themes/custom/`

3. **Settings/Preferences**
   - `~/Documents/Pocket-agent/CLAUDE.md` - User instructions
   - `~/Documents/Pocket-agent/identity.md` - Custom identity

#### ⚠️ **Higher Conflict Risk:**

1. **Core Agent Files**
   - `src/agent/index.ts` - Main agent logic (modified frequently)
   - `src/main/index.ts` - Electron main process
   - `src/channels/` - Channel handlers

2. **Package Dependencies**
   - `package.json` - Often updated with new versions
   - `package-lock.json` - Auto-generated

---

## 3️⃣ Development Workflow

### Install dependencies
```bash
npm install
```

### Run in development mode
```bash
npm run dev
```

This launches Pocket Agent with hot-reload, so you can test changes immediately.

### Build for production
```bash
npm run build
npm run package
```

---

## 4️⃣ Staying Updated with Upstream

### Fetch latest changes from original repo
```bash
git fetch upstream
```

### Merge upstream changes into your custom branch
```bash
git checkout custom-features
git merge upstream/main
```

### If there are conflicts:
```bash
# Git will mark conflicted files
# Edit them to resolve conflicts
# Then:
git add .
git commit -m "Merge upstream updates, resolved conflicts"
```

### Push your updated custom branch to your fork
```bash
git push origin custom-features
```

---

## 5️⃣ Recommended Customizations

### **Fix 1: Document Upload Bug (from our bug report)**

Create a new file: `src/main/handlers/document-upload.ts`

```typescript
// Custom document upload handler
// This won't conflict with upstream changes
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

export function handleUIDocumentUpload(file: File) {
  // Save to files directory
  const filesDir = path.join(os.homedir(), 'Documents', 'Pocket-agent', 'files');
  if (!fs.existsSync(filesDir)) {
    fs.mkdirSync(filesDir, { recursive: true });
  }

  const timestamp = Date.now();
  const sanitizedName = file.name.replace(/[^a-zA-Z0-9_.-]/g, '_');
  const localPath = path.join(filesDir, `ui_${timestamp}_${sanitizedName}`);

  // Save file
  fs.writeFileSync(localPath, file.data);

  // Return text message for agent
  return `[User uploaded: "${file.name}"]\nFile saved to: ${localPath}\n\nPlease read and analyze this file.`;
}
```

Then integrate it in your UI handler (won't conflict with upstream).

### **Fix 2: Custom Instructions**

Edit `~/Documents/Pocket-agent/CLAUDE.md`:
```markdown
# My Custom Instructions for Pocket Agent

## Communication Style
- Be concise
- Use emojis sparingly
- Always confirm before destructive actions

## Custom Behaviors
- When I upload documents, automatically summarize them
- Remember my preferred programming languages: Python, TypeScript
- Track my daily tasks and remind me

## Tools I Use
- VS Code
- Terminal
- Notion
```

### **Enhancement 3: Custom Tools**

Create `src/tools/custom/my-tools.ts`:
```typescript
// Your custom tools here
// Won't conflict with upstream tool updates

export const myCustomTools = {
  name: 'custom_action',
  description: 'My custom functionality',
  inputSchema: {
    // Your schema
  },
  async execute(params: any) {
    // Your logic
  }
};
```

---

## 6️⃣ Advanced: Branching Strategy

### Use multiple branches:

```bash
# Main custom branch (stable)
git checkout -b custom-stable

# Experimental features
git checkout -b custom-experimental

# Testing upstream updates
git checkout -b test-upstream-merge
```

### Workflow:
1. Test upstream updates in `test-upstream-merge`
2. If clean, merge to `custom-stable`
3. Cherry-pick specific features to `custom-experimental`

---

## 7️⃣ Automation Script

Create `scripts/update-from-upstream.sh`:

```bash
#!/bin/bash
# Automated upstream sync script

echo "🔄 Fetching upstream changes..."
git fetch upstream

echo "📊 Checking for conflicts..."
git merge-tree $(git merge-base HEAD upstream/main) HEAD upstream/main

echo "🔀 Merging upstream/main..."
git merge upstream/main

echo "✅ Update complete!"
echo "Run 'npm install' if package.json changed"
```

Make it executable:
```bash
chmod +x scripts/update-from-upstream.sh
```

Run it:
```bash
./scripts/update-from-upstream.sh
```

---

## 8️⃣ Best Practices

### ✅ **DO:**
- Keep custom code in separate files when possible
- Use configuration files for personalization
- Document your changes in `CUSTOM_CHANGES.md`
- Test upstream merges in a separate branch first
- Keep your fork synced regularly (weekly)

### ❌ **DON'T:**
- Modify core files unless necessary
- Commit sensitive data (.env, API keys)
- Let your fork get too far behind upstream
- Skip testing after merging upstream changes

---

## 9️⃣ Conflict Resolution Tips

When conflicts occur:

1. **Check what changed:**
   ```bash
   git diff upstream/main
   ```

2. **Your version vs Upstream:**
   ```bash
   # Keep your version:
   git checkout --ours path/to/file.ts

   # Keep upstream version:
   git checkout --theirs path/to/file.ts

   # Manual merge:
   code path/to/file.ts  # Edit manually
   ```

3. **After resolving:**
   ```bash
   git add .
   git commit -m "Merged upstream, resolved conflicts"
   ```

---

## 🔟 Testing Your Custom Build

After making changes:

```bash
# 1. Run dev mode to test
npm run dev

# 2. Run tests (if available)
npm test

# 3. Build production version
npm run build

# 4. Package the app
npm run package

# 5. Install your custom build
# macOS: dist/Pocket Agent.app
```

---

## 📋 Maintenance Checklist

Weekly:
- [ ] Fetch upstream changes: `git fetch upstream`
- [ ] Check for new releases: https://github.com/KenKaiii/pocket-agent/releases
- [ ] Review upstream commits for relevant changes

Before each merge:
- [ ] Create backup branch: `git checkout -b backup-$(date +%Y%m%d)`
- [ ] Test in separate branch first
- [ ] Run `npm install` after merge
- [ ] Test all custom features still work
- [ ] Rebuild and test packaged app

---

## 🆘 Emergency Rollback

If an upstream merge breaks everything:

```bash
# Find the commit before merge
git log --oneline

# Reset to that commit
git reset --hard <commit-hash>

# Or use the backup branch
git checkout backup-20260209
```

---

## 📚 Resources

- **Original Repo:** https://github.com/KenKaiii/pocket-agent
- **Your Fork:** https://github.com/g-baskin/pocket-agent
- **Git Workflow Guide:** https://www.atlassian.com/git/tutorials/comparing-workflows/forking-workflow
- **Electron Docs:** https://www.electronjs.org/docs/latest/

---

**Created:** February 9, 2026
**For:** Custom Pocket Agent Development
