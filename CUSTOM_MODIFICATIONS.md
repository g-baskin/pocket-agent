# Custom Modifications vs Upstream

This file tracks all custom changes made to this fork (`g-baskin/pocket-agent`) relative to the upstream repo (`KenKaiii/pocket-agent`). Use this as a checklist when merging upstream updates.

## Merge Strategy

```bash
# 1. Fetch upstream
git fetch upstream

# 2. Create a sync branch (never merge directly into main)
git checkout -b sync/upstream-YYYY-MM-DD

# 3. Merge upstream — conflicts happen here
git merge upstream/main

# 4. Resolve conflicts using this manifest as reference
# 5. Build and test: npm run build
# 6. PR to main, verify, then merge
```

---

## Modified Files

### `src/agent/index.ts`

| Location | Change | Why |
|----------|--------|-----|
| `SDKOptions` type (~line 304) | Added `betas?: string[]` field | Type support for API beta flags |
| `buildPersistentOptions()` (~line 1300) | Added `betas: ['pdfs-2024-09-25']` to SDK options | Enable PDF/document content blocks |
| Error recovery block (~line 805) | Added `isDocumentTypeError` detection | Recover from document-type 400 errors on session resume |
| Error recovery `reason` ternary (~line 816) | Added `'document content block rejected (PDF beta missing)'` | Log meaningful reason for document errors |
| Error recovery `if` condition (~line 809) | Added `\|\| isDocumentTypeError` | Include document errors in recovery flow |
| `buildCapabilitiesPrompt()` (~line 1558) | Added "Creating PDFs & Documents" section | Teach agent to use pandoc + weasyprint for PDF creation |

### `src/main/index.ts`

| Location | Change | Why |
|----------|--------|-----|
| Top of file (~line 6) | Multi-path `.env` loading (`~/.config/pocket-agent/.env` + project root) | Secrets not tied to project dir |
| Imports (~line 37) | Added `import { DriveSync } from '../sync'` | Google Drive sync feature |
| `updateTrayMenu()` (~line 600) | Added "Sync with Drive" menu item | Manual Drive sync from tray |
| `setupIPC()` (~line 2123) | Added `sync:drive` and `sync:driveStatus` IPC handlers | Drive sync from renderer |
| `initializeAgent()` (~line 2185) | Added Google Workspace MCP server config | Gmail, Drive, Docs, Sheets, Calendar access |
| `app.whenReady()` (~line 2718) | Added Drive sync on startup | Auto-sync workspace on launch |

### `src/main/preload.ts`

| Location | Change | Why |
|----------|--------|-----|
| Context bridge (~line 91) | Added `syncDrive()` and `syncDriveStatus()` | Expose Drive sync to renderer |

### `src/settings/index.ts`

| Location | Change | Why |
|----------|--------|-----|
| `SETTINGS_SCHEMA` (~line 493) | Added `google.workspace.enabled` (default: true) | Toggle Google Workspace MCP |
| `SETTINGS_SCHEMA` (~line 505) | Added `sync.drive.enabled` (default: false) | Toggle Drive sync |
| `SETTINGS_SCHEMA` (~line 513) | Added `sync.drive.folderName` (default: "Pocket Agent") | Configurable Drive folder |
| `SETTINGS_SCHEMA` (~line 521) | Added `sync.drive.syncOnStartup` (default: true) | Auto-sync toggle |
| `SETTINGS_SCHEMA` (~line 529) | Added `updates.autoCheck` (default: false) | Disable auto-updater by default |

### `ui/chat.html`

| Location | Change | Why |
|----------|--------|-----|
| Session state (~line 3687) | `MAX_TABS = 25` (was 5) | More concurrent chat sessions |

### `.env.example`

| Location | Change | Why |
|----------|--------|-----|
| Bottom of file | Added `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` | Document required env vars for Google Workspace |

---

## New Files (not in upstream)

| File | Purpose |
|------|---------|
| `src/sync/drive-client.ts` | Google Drive API client for sync |
| `src/sync/index.ts` | Sync module barrel export |
| `src/sync/sync-engine.ts` | Bidirectional file sync engine |
| `CUSTOM_MODIFICATIONS.md` | This file |

---

## Dependencies on Host Machine

| Tool | Used By | Install |
|------|---------|---------|
| pandoc | PDF creation (agent capability) | `brew install pandoc` |
| weasyprint | PDF engine for pandoc | `pip install weasyprint` |

---

## Conflict-Prone Areas

These areas are most likely to conflict during upstream merges:

1. **`src/agent/index.ts`** — Upstream frequently updates the SDK options, error handling, and capabilities prompt. Check all 6 modifications listed above.
2. **`src/main/index.ts`** — Top-of-file imports and `initializeAgent()` are high-traffic areas upstream.
3. **`src/settings/index.ts`** — New upstream settings may shift line numbers in `SETTINGS_SCHEMA`.
4. **`ui/chat.html`** — Monolithic file; upstream UI changes often touch session management.

## Post-Merge Verification

After resolving conflicts:

```bash
# 1. TypeScript compiles
npm run build

# 2. Build DMG
npm run dist:local

# 3. Test critical paths:
#    - Send a PDF via Telegram → agent reads it
#    - Resume a session that read a PDF → no 400 error
#    - Ask agent to create a PDF → pandoc pipeline works
#    - Google Workspace MCP connects
#    - Drive sync works (if enabled)
#    - Settings page shows all custom settings
#    - 25 tabs work in chat UI
```
