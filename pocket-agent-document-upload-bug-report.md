# Pocket Agent Bug Report: Document Upload Failure

## Issue Summary
When attempting to upload PDF or document files through the Pocket Agent UI, the application returns an API error indicating an invalid content type `'document'` is being used.

## Error Message
```
API Error: 400
{
  "error": {
    "type": "invalid_request_error",
    "message": "messages.12.content.1: Input tag 'document' found using 'type' does not match any of the expected tags: 'image', 'server_tool_use', 'text', 'thinking', 'tool_result', 'tool_use', 'web_search_tool_result'"
  },
  "request_id": "006bf8cf-0635-11f1-a61e-00163e76c0c3",
  "type": "error"
}
```

## Steps to Reproduce
1. Open Pocket Agent application
2. Attempt to upload a PDF or document file through the UI
3. Observe API error 400

## Expected Behavior
Documents should be handled similarly to the Telegram channel implementation:
1. Save document to local files directory
2. Provide file path to Claude in a text message
3. Allow Claude to use the Read tool to access the file

## Actual Behavior
The UI appears to be sending documents as content blocks with `type: 'document'`, which Claude's API does not support.

## Technical Analysis

### Root Cause
The Claude API only accepts these content types in message content blocks:
- `image`
- `server_tool_use`
- `text`
- `thinking`
- `tool_result`
- `tool_use`
- `web_search_tool_result`

The `document` type is **not supported**.

### Current Code Location

**File:** `/Applications/Pocket Agent.app/Contents/Resources/app/dist/agent/index.js`

**Lines 295-309** show how images are currently handled:
```javascript
// Build content blocks for images
const contentBlocks = images && images.length > 0
    ? [
        { type: 'text', text: userMessage },
        ...images.map(img => ({
            type: 'image',
            source: {
                type: 'base64',
                media_type: img.mediaType,
                data: img.data,
            },
        })),
    ]
    : undefined;
turnResult = await existingSession.send(userMessage, contentBlocks);
```

### Working Reference Implementation

**File:** `/Applications/Pocket Agent.app/Contents/Resources/app/dist/channels/telegram/handlers/documents.js`

**Lines 186-196** show the correct approach:
```javascript
// Build prompt for agent - tell it the file path so it can use Read tool
const prompt = caption
    ? `${caption}\n\n[User sent a ${fileType} via Telegram: "${fileName}"]\nFile saved to: ${localPath}\n\nPlease read and analyze this file.`
    : `[User sent a ${fileType} via Telegram: "${fileName}"]\nFile saved to: ${localPath}\n\nPlease read and analyze this file.`;

return AgentManager.processMessage(prompt, 'telegram', sessionId, undefined, {
    hasAttachment: true,
    attachmentType: 'document',
});
```

Note: The `attachmentType: 'document'` here is just metadata for the database, not sent to the API.

## Suggested Fix

The UI document upload handler should:

1. **Save the document to disk:**
   ```javascript
   const filesDir = path.join(os.homedir(), 'Documents', 'Pocket-agent', 'files');
   const localPath = path.join(filesDir, uniqueFilename);
   fs.writeFileSync(localPath, documentBuffer);
   ```

2. **Create a text message with the file path:**
   ```javascript
   const prompt = `[User uploaded a ${fileType}: "${fileName}"]\n` +
                  `File saved to: ${localPath}\n\n` +
                  `Please read and analyze this file.`;
   ```

3. **Send as text message (not as content block):**
   ```javascript
   return AgentManager.processMessage(prompt, 'default', sessionId, undefined, {
       hasAttachment: true,
       attachmentType: 'document',
   });
   ```

4. **Do NOT try to send documents as content blocks** - unlike images (which can be base64 encoded), documents must be accessed via the Read tool.

## Workarounds for Users

### Option 1: Manual File Placement
1. Save your PDF/document to: `/Users/[username]/Documents/Pocket-agent/files/`
2. Message Pocket Agent: "Please read and analyze the file at /Users/[username]/Documents/Pocket-agent/files/your-file.pdf"

### Option 2: Use Telegram Channel
The Telegram channel handler already implements document uploads correctly. Send documents via Telegram bot instead of the main UI.

## Environment
- **OS:** macOS
- **Pocket Agent Version:** 1.0.14 (based on DMG file found)
- **Installation Path:** `/Applications/Pocket Agent.app`
- **Date Reported:** February 9, 2026

## Additional Notes

The inconsistency between the Telegram handler (which works correctly) and the UI handler (which attempts to use an invalid content type) suggests this may have been an oversight when implementing UI file uploads.

The fix should be straightforward - mirror the Telegram document handler's approach for UI uploads.

## Files for Reference

**Main Agent:** `/Applications/Pocket Agent.app/Contents/Resources/app/dist/agent/index.js`
**Telegram Document Handler (working example):** `/Applications/Pocket Agent.app/Contents/Resources/app/dist/channels/telegram/handlers/documents.js`

---

**Report Generated:** February 9, 2026
**Analyzed By:** Claude Code CLI
