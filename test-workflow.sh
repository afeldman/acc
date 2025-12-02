#!/bin/bash
# Local GitHub Actions testing with act
# Usage: ./test-workflow.sh [workflow-name]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== ACC GitHub Actions Local Testing ===${NC}\n"

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo -e "${RED}Error: 'act' is not installed${NC}"
    echo "Install with: brew install act (macOS) or see https://github.com/nektos/act"
    exit 1
fi

# Default workflow
WORKFLOW=${1:-build-compilers}

case $WORKFLOW in
    build|build-compilers)
        echo -e "${YELLOW}Testing Build & Release Workflow${NC}\n"
        act push \
            --workflows .github/workflows/build-compilers.yml \
            --container-architecture linux/amd64 \
            --artifact-server-path /tmp/artifacts \
            -P ubuntu-latest=catthehacker/ubuntu:act-latest
        ;;
    
    test)
        echo -e "${YELLOW}Testing Test Workflow${NC}\n"
        act pull_request \
            --workflows .github/workflows/test.yml \
            --container-architecture linux/amd64 \
            -P ubuntu-latest=catthehacker/ubuntu:act-latest
        ;;
    
    bf|brainfuck)
        echo -e "${YELLOW}Testing Brainfuck Compiler Job Only${NC}\n"
        act push \
            --workflows .github/workflows/build-compilers.yml \
            --job build-brainfuck \
            --container-architecture linux/amd64 \
            -P ubuntu-latest=catthehacker/ubuntu:act-latest
        ;;
    
    ws|whitespace)
        echo -e "${YELLOW}Testing Whitespace Compiler Job Only${NC}\n"
        act push \
            --workflows .github/workflows/build-compilers.yml \
            --job build-whitespace \
            --container-architecture linux/amd64 \
            -P ubuntu-latest=catthehacker/ubuntu:act-latest
        ;;
    
    grammars)
        echo -e "${YELLOW}Testing Grammar Validation Job Only${NC}\n"
        act push \
            --workflows .github/workflows/build-compilers.yml \
            --job build-grammars \
            --container-architecture linux/amd64 \
            -P ubuntu-latest=catthehacker/ubuntu:act-latest
        ;;
    
    list)
        echo -e "${YELLOW}Available workflows:${NC}"
        echo "  build, build-compilers  - Full build & release workflow"
        echo "  test                    - Test workflow (PR checks)"
        echo "  bf, brainfuck          - Brainfuck compiler only"
        echo "  ws, whitespace         - Whitespace compiler only"
        echo "  grammars               - Grammar validation only"
        echo ""
        echo -e "${YELLOW}Usage:${NC}"
        echo "  ./test-workflow.sh [workflow-name]"
        echo ""
        echo -e "${YELLOW}Examples:${NC}"
        echo "  ./test-workflow.sh build"
        echo "  ./test-workflow.sh bf"
        echo "  ./test-workflow.sh test"
        ;;
    
    *)
        echo -e "${RED}Unknown workflow: $WORKFLOW${NC}"
        echo "Run './test-workflow.sh list' to see available workflows"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Test completed!${NC}"
