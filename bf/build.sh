#!/bin/bash
# Build script for Brainfuck LLVM Compiler

set -e

echo "=== Building Brainfuck LLVM Compiler ==="

# Generate parser with BNFC
echo "1. Generating parser from bf.cf..."
bnfc -m --haskell -o src/ bf.cf

# Build lexer and parser
echo "2. Building lexer and parser..."
cd src
if [ -f LexBF.x ]; then
    alex LexBF.x -o LexBF.hs
fi
if [ -f ParBF.y ]; then
    happy ParBF.y -o ParBF.hs
fi
cd ..

# Build with Stack
echo "3. Building with Stack..."
stack build

echo ""
echo "✅ Build complete!"
echo ""
echo "Usage:"
echo "  stack exec bfc -- test/hello.bf -emit-llvm"
echo "  ./run.sh test/hello.bf"
echo ""
