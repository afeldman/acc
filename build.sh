#!/bin/bash
# Build a single compiler using Docker container
# Usage: ./build.sh <compiler-name>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <compiler-name>"
    echo ""
    echo "Available compilers:"
    echo "  basic, bf, whitespace, karel, krl, tpe, urs, vhdl, ini, json"
    exit 1
fi

COMPILER=$1

if [ ! -d "$COMPILER" ]; then
    echo "Error: Compiler '$COMPILER' not found"
    exit 1
fi

echo "======================================"
echo "Building $COMPILER compiler (Docker)"
echo "======================================"
echo ""

# Run build in Docker
docker-compose run --rm acc-dev bash -c "
    cd $COMPILER && \
    echo 'Step 1: Generating parser with BNFC...' && \
    bnfc -m --haskell *.cf && \
    echo '' && \
    echo 'Step 2: Running Alex (lexer)...' && \
    cd src && alex Lex*.x && \
    echo '' && \
    echo 'Step 3: Running Happy (parser)...' && \
    happy Par*.y && \
    echo '' && \
    echo 'Step 4: Building with Stack...' && \
    cd .. && stack build --copy-bins --local-bin-path=. && \
    echo '' && \
    echo '✅ Build complete!'
"

# Find executable name
EXEC_NAME="${COMPILER}c"
if [ "$COMPILER" = "ini" ]; then
    EXEC_NAME="ini-parser"
elif [ "$COMPILER" = "json" ]; then
    EXEC_NAME="json-parser"
elif [ "$COMPILER" = "bf" ]; then
    EXEC_NAME="bfc"
elif [ "$COMPILER" = "whitespace" ]; then
    EXEC_NAME="wsc"
fi

if [ -f "$COMPILER/$EXEC_NAME" ]; then
    echo ""
    echo "======================================"
    echo "Executable: $COMPILER/$EXEC_NAME"
    ls -lh "$COMPILER/$EXEC_NAME"
    echo "======================================"
else
    echo ""
    echo "Warning: Executable not found at $COMPILER/$EXEC_NAME"
fi
