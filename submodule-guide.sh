#!/bin/bash
# Step-by-step guide to convert ACC to submodules

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║  ACC → Submodules Conversion Guide                            ║
╚════════════════════════════════════════════════════════════════╝

PREREQUISITE: All compiler repos must be on GitHub first!

══════════════════════════════════════════════════════════════════
STEP 1: Push all compilers to GitHub
══════════════════════════════════════════════════════════════════

Option A - Using gh CLI (recommended):
  brew install gh
  gh auth login
  
  cd ~/Projects/fanuc/compilers/karel-compiler
  gh repo create karel-compiler --public --source . --push

  # Repeat for all 10 projects

Option B - Manual for each project:
  1. Create repo on GitHub: https://github.com/new
  2. Then:
     cd ~/Projects/fanuc/compilers/karel-compiler
     git remote add origin git@github.com:afeldman/karel-compiler.git
     git push -u origin main

Option C - Interactive script:
  cd ~/Projects/compiler/acc
  ./create-repos-interactive.sh

══════════════════════════════════════════════════════════════════
STEP 2: Convert ACC to submodules
══════════════════════════════════════════════════════════════════

After all repos are on GitHub:

  cd ~/Projects/compiler/acc
  ./convert-to-submodules.sh afeldman

This will:
  ✓ Remove local directories (bf/, karel/, etc.)
  ✓ Add them as git submodules from GitHub
  ✓ Update .gitmodules
  ✓ Commit changes

══════════════════════════════════════════════════════════════════
STEP 3: Clone ACC with submodules (on other machines)
══════════════════════════════════════════════════════════════════

  git clone --recursive git@github.com:afeldman/acc.git

Or:
  git clone git@github.com:afeldman/acc.git
  cd acc
  git submodule update --init --recursive

══════════════════════════════════════════════════════════════════
STEP 4: Update submodules
══════════════════════════════════════════════════════════════════

Update all:
  git submodule update --remote
  git add .
  git commit -m "Update all submodules"

Update single:
  cd karel/
  git pull origin main
  cd ..
  git add karel/
  git commit -m "Update karel submodule"

══════════════════════════════════════════════════════════════════
CURRENT STATUS CHECK
══════════════════════════════════════════════════════════════════

EOF

echo "Checking which repos are already on GitHub..."
echo ""

GITHUB_USER="afeldman"
PROJECTS=(
    "karel-compiler"
    "fanuc-tpe-compiler"
    "brainfuck-compiler"
    "whitespace-compiler"
    "kuka-krl-compiler"
    "universal-robots-compiler"
    "basic-compiler"
    "ini-parser"
    "json-parser"
    "vhdl-compiler"
)

for project in "${PROJECTS[@]}"; do
    if git ls-remote "git@github.com:${GITHUB_USER}/${project}.git" &>/dev/null; then
        echo "✅ $project - exists on GitHub"
    else
        echo "❌ $project - NOT on GitHub yet"
    fi
done

echo ""
echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "Next action:"
echo "  If all are ✅: Run ./convert-to-submodules.sh afeldman"
echo "  If some are ❌: Push missing repos first (see STEP 1)"
echo ""
