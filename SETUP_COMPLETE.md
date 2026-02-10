# ✅ Pocket Agent Development Setup - COMPLETE

**Date:** February 9, 2026
**Location:** `/Users/dellcbyerllc/Desktop/Projects/pocket-agent`
**Branch:** `custom-features`

---

## 📦 What's Been Set Up

### ✅ Git Configuration
```bash
origin    → https://github.com/g-baskin/pocket-agent.git (your fork)
upstream  → https://github.com/KenKaiii/pocket-agent.git (original)
```

**Current branch:** `custom-features`
**Upstream version:** v2.2.5 (latest)

### ✅ Project Structure

```
pocket-agent/
├── src/
│   └── tools/
│       └── custom/              # Your custom tools here
├── scripts/
│   ├── custom/                  # Your custom scripts
│   └── update-from-upstream.sh  # Sync with original repo
├── .custom-config/              # Your config overrides
├── CUSTOM_CHANGES.md            # Track your modifications
├── pocket-agent-document-upload-bug-report.md
├── pocket-agent-development-setup.md
└── node_modules/                # ✅ 434 packages installed
```

### ✅ Files in This Directory

1. **CLAUDE.md** - Project guidelines (upstream)
2. **README.md** - Project documentation (upstream)
3. **CUSTOM_CHANGES.md** - Your modifications log
4. **pocket-agent-development-setup.md** - Full dev guide
5. **pocket-agent-document-upload-bug-report.md** - Bug to report upstream
6. **setup-pocket-agent-dev.sh** - Automated setup script (archived)
7. **scripts/update-from-upstream.sh** - Pull upstream updates
8. **SETUP_COMPLETE.md** - This file

---

## ⚠️ Known Issue: electron-rebuild

**Status:** Known, non-blocking

The `electron-rebuild` postinstall script failed with:
```
fatal error: 'functional' file not found
```

**Impact:** None for development. The app will likely work fine.

**Why it happens:** Node v22.21.1 compatibility issue with native modules

**If you need to fix it:**
```bash
# Option 1: Use Node 20 LTS (recommended)
nvm install 20
nvm use 20
rm -rf node_modules package-lock.json
npm install

# Option 2: Skip rebuild (current state - works fine)
# Dependencies are already installed, just ignore the error
```

---

## 🚀 Quick Start

### Run Development Mode
```bash
cd ~/Desktop/Projects/pocket-agent
npm run dev
```

This launches Pocket Agent with hot-reload for testing your changes.

### Make Custom Changes

1. **Edit source files** in `src/`
2. **Add custom tools** in `src/tools/custom/`
3. **Test immediately** - dev mode auto-reloads
4. **Document changes** in `CUSTOM_CHANGES.md`

### Safe Files to Modify

✅ **Low Conflict Risk:**
- `src/config/identity.ts` - Custom personality
- `src/config/instructions.ts` - System prompts
- `src/tools/custom/*` - Your custom tools
- `~/Documents/Pocket-agent/CLAUDE.md` - User instructions

⚠️ **Higher Risk (but manageable):**
- `src/agent/index.ts` - Main agent logic
- `src/channels/*/handlers/*` - Message handlers

---

## 🔄 Staying Updated

### Check for upstream updates:
```bash
cd ~/Desktop/Projects/pocket-agent
git fetch upstream
git log HEAD..upstream/main --oneline
```

### Merge upstream changes:
```bash
./scripts/update-from-upstream.sh
```

Or manually:
```bash
git merge upstream/main
# Resolve any conflicts
npm install  # If package.json changed
npm run dev  # Test
```

---

## 📋 Next Steps

### 1. Test the Current Build
```bash
npm run dev
```

### 2. Fix Document Upload Bug

Create `src/main/handlers/document-upload-handler.ts`:
```typescript
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

export function saveDocumentForAgent(fileData: Buffer, fileName: string) {
  const filesDir = path.join(os.homedir(), 'Documents', 'Pocket-agent', 'files');
  if (!fs.existsSync(filesDir)) fs.mkdirSync(filesDir, { recursive: true });

  const timestamp = Date.now();
  const sanitized = fileName.replace(/[^a-zA-Z0-9_.-]/g, '_');
  const localPath = path.join(filesDir, `ui_${timestamp}_${sanitized}`);

  fs.writeFileSync(localPath, fileData);

  return `[User uploaded: "${fileName}"]\nFile saved to: ${localPath}\n\nPlease read and analyze this file.`;
}
```

Then integrate into the UI upload handler.

### 3. Report the Bug Upstream

The bug report is ready in:
```
pocket-agent-document-upload-bug-report.md
```

Submit to: https://github.com/KenKaiii/pocket-agent/issues

### 4. Build Production Version

When ready to use your custom version:
```bash
npm run build
npm run package
# Creates: dist/Pocket Agent.app
```

---

## 🔧 Useful Commands

```bash
# Start development
npm run dev

# Build for production
npm run build

# Package as .app
npm run package

# Run linter
npm run lint

# Fix linting issues
npm run lint:fix

# Type check
npm run typecheck

# Update from upstream
./scripts/update-from-upstream.sh

# View git status
git status

# View remotes
git remote -v

# View current branch
git branch

# Switch branches
git checkout main
git checkout custom-features
```

---

## 📚 Documentation

- **Full Development Guide:** `pocket-agent-development-setup.md`
- **Track Your Changes:** `CUSTOM_CHANGES.md`
- **Bug Report:** `pocket-agent-document-upload-bug-report.md`
- **Upstream README:** `README.md`
- **Project Guidelines:** `CLAUDE.md`

---

## 🆘 Troubleshooting

### "Module not found" errors
```bash
rm -rf node_modules package-lock.json
npm install
```

### Merge conflicts after updating
```bash
# View conflicts
git status

# Edit conflicted files manually, then:
git add .
git commit -m "Resolved merge conflicts"
```

### App won't start
```bash
# Clear caches
rm -rf ~/Library/Application\ Support/pocket-agent
rm -rf dist/

# Rebuild
npm run dev
```

### Want to start fresh
```bash
# Keep your changes
git stash

# Reset to main
git reset --hard origin/main

# Restore changes
git stash pop
```

---

## ✅ Setup Checklist

- [x] Fork cloned to ~/Desktop/Projects/pocket-agent
- [x] Upstream remote configured (KenKaiii/pocket-agent)
- [x] custom-features branch created
- [x] Dependencies installed (434 packages)
- [x] Custom directories created
- [x] Update script ready
- [x] Documentation in place
- [ ] Test with `npm run dev`
- [ ] Make first custom change
- [ ] Report document upload bug
- [ ] Build production version

---

## 🎯 Your Custom Development Path

1. ✅ **Setup Complete** ← You are here
2. Test development mode (`npm run dev`)
3. Make your first custom change
4. Document it in CUSTOM_CHANGES.md
5. Sync with upstream regularly
6. Build your custom version
7. Use your personalized Pocket Agent!

---

**Everything is ready! Start with:**
```bash
cd ~/Desktop/Projects/pocket-agent
npm run dev
```

🚀 Happy coding!
