#!/bin/bash
# Quick workflow validation script using act --list

set -e

COMPILERS=("basic" "bf" "whitespace" "karel" "krl" "tpe" "urs" "vhdl" "ini" "json")

echo "Validating GitHub Actions workflows for all compilers..."
echo "=============================================="
echo ""

PASSED=0
FAILED=0
FAILED_COMPILERS=""

for compiler in "${COMPILERS[@]}"; do
    if [ -d "$compiler" ]; then
        printf "%-15s " "$compiler:"
        cd "$compiler"
        
        if act -W .github/workflows/build-and-test.yml --list >/dev/null 2>&1; then
            echo "✅ OK"
            PASSED=$((PASSED + 1))
        else
            echo "❌ FAILED"
            FAILED=$((FAILED + 1))
            FAILED_COMPILERS="$FAILED_COMPILERS $compiler"
        fi
        
        cd ..
    else
        printf "%-15s " "$compiler:"
        echo "⚠️  SKIPPED (not found)"
    fi
done

echo ""
echo "=============================================="
echo "Validation Summary:"
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
if [ $FAILED -gt 0 ]; then
    echo "  Failed compilers:$FAILED_COMPILERS"
    exit 1
fi
echo "=============================================="
