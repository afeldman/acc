#!/bin/bash
# Build all ACC compilers using Docker container
# Output: Compiled executables in each compiler directory

set -e

COMPILERS=("basic" "bf" "whitespace" "karel" "krl" "tpe" "urs" "vhdl" "ini" "json")
BUILD_DIR="build-output"

echo "======================================"
echo "ACC Compiler Build (Docker)"
echo "======================================"
echo ""

# Create output directory
mkdir -p "$BUILD_DIR"

# Build each compiler
for compiler in "${COMPILERS[@]}"; do
    if [ -d "$compiler" ]; then
        echo "Building $compiler..."
        
        # Run build in Docker
        docker-compose run --rm acc-dev bash -c "
            cd $compiler && \
            echo '  Generating parser...' && \
            bnfc -m --haskell *.cf 2>&1 | grep -E '(rules accepted|writing)' && \
            cd src && \
            echo '  Running Alex...' && \
            alex Lex*.x 2>&1 | head -3 && \
            echo '  Running Happy...' && \
            happy Par*.y 2>&1 | head -3 && \
            cd .. && \
            echo '  Building with Stack...' && \
            stack build --copy-bins --local-bin-path=. 2>&1 | grep -E '(Building|Completed)' && \
            echo '  ✅ Build complete'
        "
        
        if [ $? -eq 0 ]; then
            # Copy executable to output
            EXEC_NAME="${compiler}c"
            if [ "$compiler" = "ini" ]; then
                EXEC_NAME="ini-parser"
            elif [ "$compiler" = "json" ]; then
                EXEC_NAME="json-parser"
            elif [ "$compiler" = "bf" ]; then
                EXEC_NAME="bfc"
            elif [ "$compiler" = "whitespace" ]; then
                EXEC_NAME="wsc"
            fi
            
            if [ -f "$compiler/$EXEC_NAME" ]; then
                cp "$compiler/$EXEC_NAME" "$BUILD_DIR/"
                echo "  📦 Executable: $BUILD_DIR/$EXEC_NAME"
            fi
            echo ""
        else
            echo "  ❌ Build failed for $compiler"
            echo ""
        fi
    else
        echo "⚠️  Skipping $compiler (directory not found)"
        echo ""
    fi
done

echo "======================================"
echo "Build Summary"
echo "======================================"
echo "Executables in $BUILD_DIR/:"
ls -lh "$BUILD_DIR" 2>/dev/null || echo "  (none)"
echo ""
echo "Done!"
