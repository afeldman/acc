#!/bin/bash
# ACC Development Container Helper Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  ACC - Compiler Development Container  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running!"
        echo "Please start Docker Desktop and try again."
        exit 1
    fi
}

# Build image
build() {
    print_header
    print_info "Building ACC development image..."
    
    docker-compose build
    
    print_success "Image built successfully!"
    echo ""
    echo "Next steps:"
    echo "  ./dev.sh start   - Start container"
    echo "  ./dev.sh shell   - Open shell"
}

# Start container
start() {
    print_info "Starting ACC development container..."
    
    docker-compose up -d
    
    print_success "Container started!"
    echo ""
    echo "Open shell with: ./dev.sh shell"
}

# Open shell
shell() {
    print_info "Opening shell in ACC container..."
    
    if ! docker-compose ps | grep -q "Up"; then
        print_warning "Container not running. Starting..."
        docker-compose up -d
        sleep 2
    fi
    
    docker-compose exec acc-dev /bin/bash
}

# Stop container
stop() {
    print_info "Stopping ACC development container..."
    
    docker-compose down
    
    print_success "Container stopped!"
}

# Clean everything
clean() {
    print_warning "This will remove the container and all volumes!"
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cleaning up..."
        docker-compose down -v
        docker rmi acc-haskell-llvm:latest 2>/dev/null || true
        print_success "Cleanup complete!"
    else
        print_info "Cancelled."
    fi
}

# View logs
logs() {
    docker-compose logs -f acc-dev
}

# Rebuild from scratch
rebuild() {
    print_info "Rebuilding from scratch..."
    
    docker-compose down -v
    docker rmi acc-haskell-llvm:latest 2>/dev/null || true
    docker-compose build --no-cache
    
    print_success "Rebuild complete!"
}

# Show status
status() {
    print_header
    
    print_info "Container status:"
    docker-compose ps
    
    echo ""
    print_info "Images:"
    docker images | grep -E "REPOSITORY|acc-haskell-llvm"
    
    echo ""
    print_info "Volumes:"
    docker volume ls | grep -E "DRIVER|acc-"
}

# Quick test
test() {
    print_info "Running quick test..."
    
    if ! docker-compose ps | grep -q "Up"; then
        print_warning "Starting container..."
        docker-compose up -d
        sleep 2
    fi
    
    print_info "Testing tools..."
    docker-compose exec -T acc-dev bash -c "
        echo '=== Tool Versions ==='
        ghc --version
        stack --version
        bnfc --version 2>&1 | head -1
        llvm-config --version
    "
    
    print_success "Test complete!"
}

# Help
show_help() {
    print_header
    
    echo "Usage: ./dev.sh [command]"
    echo ""
    echo "Commands:"
    echo "  build      Build Docker image"
    echo "  start      Start container"
    echo "  shell      Open shell in container"
    echo "  stop       Stop container"
    echo "  clean      Remove container and volumes"
    echo "  rebuild    Rebuild image from scratch"
    echo "  logs       View container logs"
    echo "  status     Show container status"
    echo "  test       Run quick test"
    echo "  help       Show this help"
    echo ""
    echo "Examples:"
    echo "  ./dev.sh build && ./dev.sh shell"
    echo "  ./dev.sh start && ./dev.sh shell"
    echo ""
}

# Main
main() {
    check_docker
    
    case "${1:-help}" in
        build)
            build
            ;;
        start)
            start
            ;;
        shell)
            shell
            ;;
        stop)
            stop
            ;;
        clean)
            clean
            ;;
        rebuild)
            rebuild
            ;;
        logs)
            logs
            ;;
        status)
            status
            ;;
        test)
            test
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
