# Custom Changes Log

Track your custom modifications here to make merging easier.

---

## 📝 Changes Made

### [2026-02-09] - Initial Setup
- **Branch Created:** `custom-features`
- **Upstream Configured:** KenKaiii/pocket-agent
- **Custom Directories:** src/tools/custom, scripts/custom, .custom-config
- **Files Added:**
  - `pocket-agent-document-upload-bug-report.md` (bug documentation)
  - `pocket-agent-development-setup.md` (development guide)
  - `scripts/update-from-upstream.sh` (sync script)
  - This file

---

## 🐛 Known Issues to Fix

### Document Upload Bug
- **Issue:** UI sends documents with invalid `type: 'document'` to API
- **Status:** Bug reported to upstream
- **Workaround:** Save files manually to ~/Documents/Pocket-agent/files/
- **Planned Fix:** Create custom UI document handler in src/main/handlers/

---

## ⚠️ Known Conflicts with Upstream

*None yet - track conflicts here as they occur*

### Example Format:
**File:** `src/agent/index.ts`
- **Conflict:** Custom tool definitions vs upstream tool updates
- **Resolution:** Kept custom tools in separate file, merged upstream changes
- **Date Resolved:** YYYY-MM-DD

---

## ✨ Custom Features to Add

### Planned Enhancements:
- [ ] Fix document upload handler
- [ ] Custom system instructions
- [ ] Additional tools in src/tools/custom/
- [ ] Theme customizations
- [ ] Keyboard shortcuts

### Implemented Features:
*Track completed features here*

---

## 📚 Resources

- **Your Fork:** https://github.com/g-baskin/pocket-agent
- **Upstream:** https://github.com/KenKaiii/pocket-agent
- **Latest Upstream Release:** v2.2.5
- **Your Current Version:** v2.2.5 (check package.json)

---

## 🔄 Merge History

### Last Upstream Sync: Never (fresh fork)
- **Commit:** Initial clone
- **Conflicts:** None
- **Notes:** Clean start

---

**Created:** 2026-02-09
**Branch:** custom-features
