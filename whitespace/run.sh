#!/bin/bash
# Run Whitespace compiler and generate executable

set -e

if [ -z "$1" ]; then
    echo "Usage: ./run.sh <file.ws>"
    exit 1
fi

INPUT=$1
BASENAME=$(basename "$INPUT" .ws)

echo "=== Compiling $INPUT ==="

# Compile to LLVM IR
echo "1. Generating LLVM IR..."
stack exec wsc -- "$INPUT" -emit-llvm -o "${BASENAME}.ll"

# Compile to object file
echo "2. Compiling to object file..."
llc -filetype=obj "${BASENAME}.ll" -o "${BASENAME}.o"

# Link with C runtime
echo "3. Linking..."
clang "${BASENAME}.o" -o "${BASENAME}"

echo ""
echo "✅ Compilation successful!"
echo "   Output: ${BASENAME}"
echo ""
echo "Run with: ./${BASENAME}"
