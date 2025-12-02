# ACC Makefile
# Build automation for all ACC compiler projects

.PHONY: help docker-build docker-run docker-shell docker-stop docker-clean \
        karel krl tpe urs vhdl bf clean-all

# Default target
.DEFAULT_GOAL := help

##@ General

help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Docker

docker-build: ## Build Docker development image
	@echo "🐳 Building ACC Haskell LLVM Docker image..."
	docker-compose build

docker-run: ## Run Docker container (detached)
	@echo "🚀 Starting ACC development container..."
	docker-compose up -d

docker-shell: ## Open shell in development container
	@echo "💻 Opening shell in ACC container..."
	docker-compose exec acc-dev /bin/bash

docker-logs: ## View container logs
	docker-compose logs -f acc-dev

docker-stop: ## Stop Docker container
	@echo "🛑 Stopping ACC development container..."
	docker-compose down

docker-clean: ## Remove Docker container and volumes
	@echo "🧹 Cleaning up Docker resources..."
	docker-compose down -v
	docker rmi acc-haskell-llvm:latest 2>/dev/null || true

docker-rebuild: docker-clean docker-build ## Rebuild Docker image from scratch

##@ Karel Compiler

karel: ## Build Karel compiler
	@echo "🤖 Building Karel compiler..."
	cd karel && task default

karel-test: ## Test Karel parser
	@echo "🧪 Testing Karel parser..."
	cd karel && ./build/TestKarel test/simple.kl

karel-clean: ## Clean Karel build artifacts
	@echo "🧹 Cleaning Karel build..."
	cd karel && rm -rf build/

##@ KRL Compiler

krl: ## Build KRL compiler
	@echo "🤖 Building KRL compiler..."
	cd krl && task default

krl-clean: ## Clean KRL build artifacts
	cd krl && rm -rf build/

##@ TPE Compiler

tpe: ## Build TPE compiler
	@echo "🤖 Building TPE compiler..."
	cd tpe && task default

tpe-clean: ## Clean TPE build artifacts
	cd tpe && rm -rf build/

##@ Development

stack-setup: ## Setup Stack dependencies
	@echo "📦 Installing Stack dependencies..."
	stack setup
	stack build --only-dependencies

stack-build: ## Build all Stack projects
	@echo "🔨 Building Stack projects..."
	stack build

stack-test: ## Run Stack tests
	@echo "🧪 Running tests..."
	stack test

stack-clean: ## Clean Stack build artifacts
	@echo "🧹 Cleaning Stack work..."
	stack clean

##@ Cleanup

clean-all: ## Clean all build artifacts
	@echo "🧹 Cleaning all projects..."
	find . -type d -name "build" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".stack-work" -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.hi" -delete
	find . -name "*.o" -delete
	@echo "✅ Cleanup complete"

##@ Info

info: ## Show environment info
	@echo "=== ACC Compiler Collection ==="
	@echo ""
	@echo "Projects:"
	@echo "  • karel      - FANUC Karel compiler"
	@echo "  • krl        - KUKA Robot Language"
	@echo "  • tpe        - FANUC Teach Pendant"
	@echo "  • urs        - Universal Robots Script"
	@echo "  • vhdl       - VHDL compiler"
	@echo "  • bf         - Brainfuck compiler"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build   - Build development image"
	@echo "  make docker-shell   - Open shell in container"
	@echo ""
	@echo "Build:"
	@echo "  make karel          - Build Karel compiler"
	@echo "  make stack-build    - Build all Stack projects"
