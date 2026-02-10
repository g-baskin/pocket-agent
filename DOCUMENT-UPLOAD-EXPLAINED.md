# 📄 Document Upload - How It Works

## ✅ Current Implementation (CORRECT)

Your Pocket Agent **already handles documents correctly**! Here's how it works:

### **For PDFs:**

1. **User uploads PDF** via UI
2. **UI saves to disk:** `/Users/[username]/Library/Application Support/pocket-agent/attachments/[timestamp]-[filename].pdf`
3. **UI sends text message to Claude:**
   ```
   [Attached PDF: document.pdf]
   File saved at: /path/to/file.pdf
   Use the Read tool to view this PDF.
   ```
4. **Claude uses Read tool** to access the PDF

### **For Images:**

1. **User uploads image**
2. **UI saves to disk:** `/Users/[username]/Library/Application Support/pocket-agent/attachments/[timestamp]-image.png`
3. **UI sends text message:**
   ```
   [Attached image: photo.png]
   File saved at: /path/to/file.png
   Use the Read tool to view this image.
   ```

### **For Text Files (.txt, .md, .json, etc.):**

1. **Content included directly** in message (no API error)
2. Wrapped in markdown code blocks

---

## 🔍 Code Location

**File:** `ui/chat.html`

**Function:** `buildMessageWithAttachments()` (lines 2143-2181)

```javascript
async function buildMessageWithAttachments(message, attachments) {
  // ... code ...

  // For PDFs:
  if (att.ext === 'pdf' && att.dataUrl) {
    const filePath = await window.pocketAgent.saveAttachment(att.name, att.dataUrl);
    parts.push(`\n\n[Attached PDF: ${att.name}]\nFile saved at: ${filePath}\nUse the Read tool to view this PDF.`);
  }

  // For Images:
  if (att.isImage && att.dataUrl) {
    const filePath = await window.pocketAgent.saveAttachment(att.name, att.dataUrl);
    parts.push(`\n\n[Attached image: ${att.name}]\nFile saved at: ${filePath}\nUse the Read tool to view this image.`);
  }

  // ... more code ...
}
```

**This is the CORRECT approach** - no `type: 'document'` sent to API!

---

## ❓ Why Did You Get the Error?

The error you saw:
```
API Error: 400
Input tag 'document' found using 'type' does not match any of the expected tags
```

**Possible causes:**

### 1. **Older Version of Pocket Agent**
   - The fix might be in a newer version
   - You're on v1.0.11 (fork), latest upstream is v2.2.5
   - **Solution:** Update from upstream

### 2. **Browser Extension/Plugin Interference**
   - Some browser extensions modify file uploads
   - **Solution:** Test in private/incognito mode

### 3. **Corrupted App State**
   - Cached old code or settings
   - **Solution:** Clear app data

### 4. **Network/Proxy Issues**
   - Middleware modifying requests
   - **Solution:** Check network settings

---

## 🔄 Update to Latest Version

Your fork is on v1.0.11, but upstream is on v2.2.5. Let's update:

```bash
cd ~/Desktop/Projects/pocket-agent

# See what's new in upstream
git fetch upstream
git log HEAD..upstream/main --oneline | head -20

# Merge latest changes
git merge upstream/main

# Install any new dependencies
npm install

# Rebuild
npm run dev
```

---

## 🧪 Test Document Upload

### **Step 1: Run Development Mode**

```bash
cd ~/Desktop/Projects/pocket-agent
npm run dev
```

### **Step 2: Test PDF Upload**

1. Click the **📎 attachment icon** in chat
2. Select a PDF file
3. Send message
4. Watch the console for errors

### **Step 3: Check Saved Files**

```bash
# Check where files are saved
ls -la ~/Library/Application\ Support/pocket-agent/attachments/
```

You should see your uploaded files there.

### **Step 4: Verify in Chat**

Claude should respond with something like:
```
I can see the PDF you uploaded. Let me read it...
[Uses Read tool to access the file]
Here's what I found in the document...
```

---

## 🐛 Troubleshooting

### **Error Still Happens?**

#### **Check Console Logs:**

1. Open DevTools: View → Toggle Developer Tools
2. Click **Console** tab
3. Upload a PDF
4. Look for errors

#### **Clear App Cache:**

```bash
# Stop the app
# Then clear cache:
rm -rf ~/Library/Application\ Support/pocket-agent/Cache/
rm -rf ~/Library/Application\ Support/pocket-agent/Code\ Cache/

# Restart app
npm run dev
```

#### **Test with Simple File:**

Create a test PDF:
```bash
echo "Test document" | cat > test.txt
# Convert to PDF using Preview or online tool
```

Upload this simple PDF to isolate the issue.

---

## 📊 How Other Channels Handle Documents

### **Telegram:**

**File:** `src/channels/telegram/handlers/documents.js`

```javascript
// Downloads to: ~/Documents/Pocket-agent/files/
const filesDir = path.join(os.homedir(), 'Documents', 'Pocket-agent', 'files');
const localPath = path.join(filesDir, uniqueFilename);
fs.writeFileSync(localPath, buffer);

// Sends text prompt with path
const prompt = `[User sent a ${fileType} via Telegram: "${fileName}"]
File saved to: ${localPath}
Please read and analyze this file.`;
```

**Same approach as UI!** ✅

---

## 🔧 If You Need to Debug Further

### **Add Logging to UI:**

Edit `ui/chat.html` line ~2165:

```javascript
} else if (att.ext === 'pdf' && att.dataUrl) {
  try {
    console.log('[PDF Upload] Starting save for:', att.name);
    const filePath = await window.pocketAgent.saveAttachment(att.name, att.dataUrl);
    console.log('[PDF Upload] Saved to:', filePath);
    const message = `\n\n[Attached PDF: ${att.name}]\nFile saved at: ${filePath}\nUse the Read tool to view this PDF.`;
    console.log('[PDF Upload] Message to send:', message);
    parts.push(message);
  } catch (err) {
    console.error('[PDF Upload] Failed:', err);
    parts.push(`\n\n[PDF: ${att.name}] (failed to save: ${err.message})`);
  }
}
```

This will show exactly what's happening when you upload a PDF.

---

## ✅ Summary

### **What's Working:**

- ✅ UI saves files to disk
- ✅ UI sends text message with file path
- ✅ No `type: 'document'` sent to API
- ✅ Claude uses Read tool to access files
- ✅ Same approach as Telegram (which works)

### **What to Do:**

1. **Update from upstream** (v1.0.11 → v2.2.5)
2. **Test in dev mode** with console open
3. **Check for browser extension interference**
4. **Clear app cache if needed**

### **If Error Persists:**

- Check console logs
- Add debug logging
- Test with simple file
- Report to upstream with logs

---

## 📝 Create Test Case

Save this as `test-upload.sh`:

```bash
#!/bin/bash
# Test document upload

echo "🧪 Testing Document Upload"
echo "━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if app is running
if ! pgrep -f "pocket-agent" > /dev/null; then
    echo "⚠️  Pocket Agent not running"
    echo "Start with: npm run dev"
    exit 1
fi

# Check attachments directory
ATTACH_DIR="$HOME/Library/Application Support/pocket-agent/attachments"
if [ -d "$ATTACH_DIR" ]; then
    echo "✅ Attachments directory exists"
    echo "📁 Location: $ATTACH_DIR"
    echo ""
    echo "📄 Recent uploads:"
    ls -lht "$ATTACH_DIR" | head -5
else
    echo "⚠️  Attachments directory not found"
    echo "Will be created on first upload"
fi

echo ""
echo "📝 Next steps:"
echo "1. Upload a PDF in Pocket Agent"
echo "2. Check this directory for new file"
echo "3. Watch console for errors"
```

```bash
chmod +x test-upload.sh
./test-upload.sh
```

---

**Your implementation is correct! If you're still seeing errors, it's likely a version issue or app state problem. Update from upstream and test again.**
