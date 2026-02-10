#!/bin/bash
# Verify repository is private

echo "🔒 Checking Repository Privacy Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Try to access the repo (will fail if private and not authenticated)
echo "Checking: https://github.com/g-baskin/pocket-agent"
echo ""

STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://github.com/g-baskin/pocket-agent)

if [ "$STATUS" == "404" ]; then
    echo "✅ PRIVATE: Repository returns 404 (only visible when logged in)"
    echo ""
    echo "Your repository is now PRIVATE!"
    echo "✓ Only you can see it"
    echo "✓ Not visible to public"
    echo "✓ Safe to push your changes"
elif [ "$STATUS" == "200" ]; then
    echo "⚠️  PUBLIC: Repository is still publicly accessible"
    echo ""
    echo "Action needed:"
    echo "1. Go to: https://github.com/g-baskin/pocket-agent/settings"
    echo "2. Scroll to 'Danger Zone'"
    echo "3. Click 'Change visibility'"
    echo "4. Select 'Make private'"
else
    echo "❓ Status code: $STATUS"
    echo "Could not determine visibility (may require authentication)"
fi

echo ""
