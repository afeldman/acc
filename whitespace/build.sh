 #!/bin/bash
# Build script for Whitespace LLVM Compiler

set -e

echo "=== Building Whitespace LLVM Compiler ==="

# Generate parser with BNFC
echo "1. Generating parser from whitespace.cf..."
bnfc -m --haskell -o src/ whitespace.cf

# Build lexer and parser
echo "2. Building lexer and parser..."
cd src
if [ -f LexWhitespace.x ]; then
    alex LexWhitespace.x -o LexWhitespace.hs
fi
if [ -f ParWhitespace.y ]; then
    happy ParWhitespace.y -o ParWhitespace.hs
fi
cd ..

# Build with Stack
echo "3. Building with Stack..."
stack build

echo ""
echo "✅ Build complete!"
echo ""
echo "Usage:"
echo "  stack exec wsc -- test/hello.ws -emit-llvm"
echo "  ./run.sh test/hello.ws"
echo "" 

