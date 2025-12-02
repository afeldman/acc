#!/bin/bash
# Clean all build artifacts and executables

set -e

COMPILERS=("basic" "bf" "whitespace" "karel" "krl" "tpe" "urs" "vhdl" "ini" "json")

echo "======================================"
echo "ACC Clean Build Artifacts"
echo "======================================"
echo ""

# Clean each compiler
for compiler in "${COMPILERS[@]}"; do
    if [ -d "$compiler" ]; then
        echo "Cleaning $compiler..."
        
        # Remove Stack work directory
        if [ -d "$compiler/.stack-work" ]; then
            rm -rf "$compiler/.stack-work"
            echo "  ✓ Removed .stack-work"
        fi
        
        # Remove executables
        EXECS=("${compiler}c" "${compiler}" "bfc" "wsc" "ini-parser" "json-parser")
        for exec in "${EXECS[@]}"; do
            if [ -f "$compiler/$exec" ]; then
                rm -f "$compiler/$exec"
                echo "  ✓ Removed $exec"
            fi
        done
        
        # Remove BNFC-generated files in root (duplicates)
        if [ -f "$compiler/AbsKarel.hs" ] || [ -f "$compiler/AbsBASIC.hs" ]; then
            rm -f "$compiler"/Abs*.hs
            rm -f "$compiler"/Lex*.hs "$compiler"/Lex*.x
            rm -f "$compiler"/Par*.hs "$compiler"/Par*.y "$compiler"/Par*.info
            rm -f "$compiler"/Print*.hs
            rm -f "$compiler"/Skel*.hs
            rm -f "$compiler"/Test*.hs
            rm -f "$compiler"/ErrM.hs
            rm -f "$compiler"/Doc*.txt "$compiler"/Doc*.tex
            rm -f "$compiler"/Makefile
            echo "  ✓ Removed BNFC duplicates"
        fi
        
        echo ""
    fi
done

# Clean output directory
if [ -d "build-output" ]; then
    rm -rf build-output
    echo "✓ Removed build-output/"
    echo ""
fi

echo "======================================"
echo "Clean complete!"
echo "======================================"
