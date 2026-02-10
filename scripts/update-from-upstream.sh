#!/bin/bash
# Automated upstream sync script for Pocket Agent

set -e

echo "🔄 Fetching upstream changes..."
git fetch upstream

echo ""
echo "📊 New commits from upstream:"
git log HEAD..upstream/main --oneline --graph | head -15

echo ""
read -p "Proceed with merge? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Merge cancelled"
    exit 0
fi

echo ""
echo "🔀 Merging upstream/main into custom-features..."
git merge upstream/main

echo ""
echo "✅ Update complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Run: npm install (if package.json changed)"
echo "  2. Test: npm run dev"
echo "  3. Verify your custom features still work"
echo "  4. Build: npm run build && npm run package"
echo ""
