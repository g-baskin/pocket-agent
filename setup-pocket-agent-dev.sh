#!/bin/bash
# Pocket Agent Development Setup Script
# Sets up your fork with proper upstream tracking and custom branch

set -e  # Exit on error

echo "🚀 Setting up Pocket Agent development environment..."
echo ""

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECTS_DIR="$HOME/Desktop/Projects"
REPO_NAME="pocket-agent"
YOUR_FORK="g-baskin/pocket-agent"
UPSTREAM_REPO="KenKaiii/pocket-agent"

# Create Projects directory if it doesn't exist
mkdir -p "$PROJECTS_DIR"
cd "$PROJECTS_DIR"

# Check if already cloned
if [ -d "$REPO_NAME" ]; then
    echo -e "${YELLOW}⚠️  $REPO_NAME directory already exists${NC}"
    read -p "Do you want to delete it and start fresh? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$REPO_NAME"
        echo -e "${GREEN}✓${NC} Removed existing directory"
    else
        cd "$REPO_NAME"
        echo -e "${BLUE}→${NC} Using existing directory"
    fi
fi

# Clone your fork if not exists
if [ ! -d "$REPO_NAME" ]; then
    echo -e "${BLUE}→${NC} Cloning your fork..."
    git clone "https://github.com/$YOUR_FORK.git"
    cd "$REPO_NAME"
    echo -e "${GREEN}✓${NC} Fork cloned"
fi

# Add upstream remote
echo -e "${BLUE}→${NC} Adding upstream remote..."
if git remote | grep -q "^upstream$"; then
    echo -e "${YELLOW}⚠️  Upstream remote already exists${NC}"
    git remote set-url upstream "https://github.com/$UPSTREAM_REPO.git"
else
    git remote add upstream "https://github.com/$UPSTREAM_REPO.git"
fi
echo -e "${GREEN}✓${NC} Upstream configured"

# Fetch all remotes
echo -e "${BLUE}→${NC} Fetching latest from upstream..."
git fetch upstream
git fetch origin
echo -e "${GREEN}✓${NC} Remotes fetched"

# Create custom branch if it doesn't exist
echo -e "${BLUE}→${NC} Setting up custom-features branch..."
if git show-ref --verify --quiet refs/heads/custom-features; then
    echo -e "${YELLOW}⚠️  custom-features branch already exists${NC}"
    git checkout custom-features
else
    git checkout -b custom-features
    echo -e "${GREEN}✓${NC} custom-features branch created"
fi

# Install dependencies
echo -e "${BLUE}→${NC} Installing dependencies..."
if command -v npm &> /dev/null; then
    npm install
    echo -e "${GREEN}✓${NC} Dependencies installed"
else
    echo -e "${YELLOW}⚠️  npm not found. Please install Node.js and run 'npm install'${NC}"
fi

# Create custom directories
echo -e "${BLUE}→${NC} Creating custom directories..."
mkdir -p src/tools/custom
mkdir -p scripts/custom
mkdir -p .custom-config
echo -e "${GREEN}✓${NC} Custom directories created"

# Create update script
echo -e "${BLUE}→${NC} Creating update script..."
cat > scripts/update-from-upstream.sh << 'SCRIPT'
#!/bin/bash
# Automated upstream sync script

set -e

echo "🔄 Fetching upstream changes..."
git fetch upstream

echo "📊 Showing new commits from upstream..."
git log HEAD..upstream/main --oneline | head -10

echo ""
read -p "Proceed with merge? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Merge cancelled"
    exit 0
fi

echo "🔀 Merging upstream/main..."
git merge upstream/main

echo "✅ Update complete!"
echo ""
echo "Next steps:"
echo "  1. Run 'npm install' (if package.json changed)"
echo "  2. Run 'npm run dev' to test"
echo "  3. Check your custom features still work"
SCRIPT

chmod +x scripts/update-from-upstream.sh
echo -e "${GREEN}✓${NC} Update script created"

# Create CUSTOM_CHANGES.md for documentation
cat > CUSTOM_CHANGES.md << 'DOC'
# Custom Changes Log

Track your custom modifications here to make merging easier.

## Changes Made

### [Date] - Description
- **Files Modified:**
- **Reason:**
- **Notes:**

---

## Known Conflicts with Upstream

### File: src/example/file.ts
- **Issue:**
- **Resolution:**

---

## Custom Features Added

### Feature Name
- **Description:**
- **Files:**
- **Dependencies:**

DOC
echo -e "${GREEN}✓${NC} Documentation template created"

# Summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📁 Project location: $PROJECTS_DIR/$REPO_NAME"
echo "🌿 Current branch: $(git branch --show-current)"
echo ""
echo -e "${BLUE}Git remotes configured:${NC}"
git remote -v
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. cd $PROJECTS_DIR/$REPO_NAME"
echo "  2. npm run dev          # Start development mode"
echo "  3. Make your changes in src/"
echo "  4. Test thoroughly"
echo "  5. ./scripts/update-from-upstream.sh  # When ready to sync"
echo ""
echo -e "${BLUE}📚 Full guide:${NC} ~/Desktop/pocket-agent-development-setup.md"
echo ""
