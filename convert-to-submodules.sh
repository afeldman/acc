#!/bin/bash
# Convert ACC to umbrella repository with submodules from GitHub

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GITHUB_USER="${1:-afeldman}"

echo "=== ACC Submodule Converter ==="
echo ""
echo "Converting ACC to umbrella repository with submodules from GitHub"
echo "GitHub user: $GITHUB_USER"
echo ""
echo "⚠️  WARNING: This will delete local compiler directories!"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Submodules to add (directory:repo-name)
SUBMODULES=(
    "bf:brainfuck-compiler"
    "whitespace:whitespace-compiler"
    "karel:karel-compiler"
    "krl:kuka-krl-compiler"
    "tpe:fanuc-tpe-compiler"
    "urs:universal-robots-compiler"
    "basic:basic-compiler"
    "ini:ini-parser"
    "json:json-parser"
    "vhdl:vhdl-compiler"
)

# Process each submodule
for submodule_info in "${SUBMODULES[@]}"; do
    IFS=':' read -r dir repo_name <<< "$submodule_info"
    
    echo ""
    echo "=========================================="
    echo "Processing: $dir → $repo_name"
    echo "=========================================="
    
    # Check if directory exists
    if [ ! -d "$dir" ]; then
        echo "⚠️  Directory $dir doesn't exist, skipping..."
        continue
    fi
    
    # Remove from git tracking
    echo "📦 Removing $dir from git..."
    git rm -rf "$dir" 2>/dev/null || true
    
    # Actually delete the directory
    echo "🗑️  Deleting local directory..."
    rm -rf "$dir"
    
    # Add as submodule from GitHub
    REPO_URL="git@github.com:${GITHUB_USER}/${repo_name}.git"
    echo "➕ Adding submodule: $REPO_URL"
    
    if git submodule add "$REPO_URL" "$dir"; then
        echo "✅ Added $repo_name as submodule in $dir/"
    else
        echo "❌ Failed to add submodule"
        echo "   Check if repo exists: https://github.com/${GITHUB_USER}/${repo_name}"
    fi
done

# Update README
echo ""
echo "=========================================="
echo "Updating README..."
echo "=========================================="

if [ -f "README.submodules.md" ]; then
    echo "📝 Replacing README with submodules version..."
    mv README.md README.old.md
    mv README.submodules.md README.md
    git add README.md README.old.md
fi

# Commit the changes
echo ""
echo "=========================================="
echo "Committing changes..."
echo "=========================================="

git add .gitmodules 2>/dev/null || true
git commit -m "Convert to umbrella repository with submodules

Moved individual compilers to separate repositories:
$(for sm in "${SUBMODULES[@]}"; do
    IFS=':' read -r dir repo_name <<< "$sm"
    echo "  - $repo_name ($dir/)"
done)

Each compiler is now maintained independently as a git submodule.
"

echo ""
echo "✅ ACC converted to umbrella repository!"
echo ""
echo "Submodules added:"
for sm in "${SUBMODULES[@]}"; do
    IFS=':' read -r dir repo_name <<< "$sm"
    echo "  - $dir/ → https://github.com/${GITHUB_USER}/${repo_name}"
done
echo ""
echo "Next steps:"
echo ""
echo "1. Initialize submodules on other machines:"
echo "   git clone --recursive git@github.com:${GITHUB_USER}/acc.git"
echo ""
echo "2. Update all submodules:"
echo "   git submodule update --remote"
echo ""
echo "3. Update a specific submodule:"
echo "   cd karel/ && git pull origin main && cd .."
echo "   git add karel/ && git commit -m 'Update karel submodule'"
echo ""
