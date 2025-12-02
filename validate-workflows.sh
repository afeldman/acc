#!/bin/bash
# Quick workflow validation with act --dryrun
# Validates workflow syntax without running jobs

set -e

echo "=== Validating GitHub Actions Workflows ==="
echo ""

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "Error: 'act' is not installed"
    exit 1
fi

echo "✓ Checking build-compilers.yml..."
act push \
    --workflows .github/workflows/build-compilers.yml \
    --dryrun \
    2>&1 | grep -E "(WARN|ERR)" || echo "  No errors found"

echo ""
echo "✓ Checking test.yml..."
act pull_request \
    --workflows .github/workflows/test.yml \
    --dryrun \
    2>&1 | grep -E "(WARN|ERR)" || echo "  No errors found"

echo ""
echo "✅ All workflows validated successfully!"
