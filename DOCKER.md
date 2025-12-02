# ACC - Anton Compiler Collection

## 🐳 Docker Quick Start

### Build Development Image

```bash
# Build the Haskell + LLVM + Stack image
make docker-build

# Or using docker-compose directly
docker-compose build
```

### Run Development Container

```bash
# Start container
make docker-run

# Open shell in container
make docker-shell

# You're now in the development environment!
```

### Inside the Container

```bash
# Show environment info
info

# Build Karel compiler
cd karel
task

# Test parser
./build/TestKarel test/simple.kl

# Build with Stack
stack build

# Run tests
stack test
```

### Container Features

✅ **Haskell 9.4.8** (GHC + Stack + Cabal)  
✅ **LLVM 14** (llvm-config, opt, llc, lli)  
✅ **BNFC** (BNF Converter)  
✅ **Alex & Happy** (Lexer & Parser generators)  
✅ **Pre-installed LLVM-HS** (Haskell LLVM bindings)  
✅ **Persistent volumes** (Stack cache, Cabal packages)

## 📁 Project Structure

```
acc/
├── Dockerfile           # Haskell + LLVM development image
├── docker-compose.yml   # Container orchestration
├── stack.yaml          # Global Stack configuration
├── Makefile            # Build automation
│
├── karel/              # FANUC Karel compiler
│   ├── karel.cf
│   ├── Taskfile.yaml
│   └── test/
│
├── krl/                # KUKA Robot Language
├── tpe/                # FANUC Teach Pendant
├── urs/                # Universal Robots Script
└── ...
```

## 🚀 Development Workflow

### 1. Start Container

```bash
# Build and start
make docker-build
make docker-run
make docker-shell
```

### 2. Develop Inside Container

```bash
# Generate parser from BNFC grammar
cd karel
bnfc -m --haskell -o build/ karel.cf

# Build with make
cd build && make

# Or use Task
task default

# Test parser
./build/TestKarel test/simple.kl
```

### 3. Add LLVM Backend

```bash
# Create Stack project
stack new karel-llvm

# Add dependencies to package.yaml
# dependencies:
#   - llvm-hs
#   - llvm-hs-pure
#   - llvm-hs-pretty

# Build
stack build

# Run
stack exec karel-llvm-exe
```

## 🔧 Docker Commands

```bash
# Build image
make docker-build

# Start container (detached)
make docker-run

# Open shell
make docker-shell

# View logs
make docker-logs

# Stop container
make docker-stop

# Clean everything
make docker-clean

# Rebuild from scratch
make docker-rebuild
```

## 📦 Installed Tools

### Haskell

- **GHC**: 9.4.8
- **Stack**: Latest
- **Cabal**: Latest
- **Alex**: Lexer generator
- **Happy**: Parser generator
- **BNFC**: BNF Converter

### LLVM

- **LLVM**: 14.0
- **llvm-config**: Configuration tool
- **opt**: LLVM optimizer
- **llc**: LLVM static compiler
- **lli**: LLVM interpreter
- **clang**: C/C++ compiler

### Haskell Libraries (Pre-installed)

- `llvm-hs` - LLVM bindings
- `llvm-hs-pure` - Pure LLVM types
- `llvm-hs-pretty` - Pretty printer
- `megaparsec` - Parser combinators
- `mtl` - Monad transformers
- `text`, `bytestring`, `containers`

## 🏗️ Stack Configuration

The `stack.yaml` is pre-configured with:

```yaml
resolver: lts-21.25 # GHC 9.4.8

extra-deps:
  - llvm-hs-14.0.0.0
  - llvm-hs-pure-14.0.0.0
  - llvm-hs-pretty-0.13.0.0

extra-include-dirs:
  - /usr/lib/llvm-14/include

extra-lib-dirs:
  - /usr/lib/llvm-14/lib
```

No need to fight with Stack configuration - it just works! ✅

## 💾 Persistent Volumes

Docker volumes persist your build cache:

- `acc-stack-work` - Stack build cache
- `acc-cabal` - Cabal packages
- `acc-stack` - Stack global config

Benefits:

- Faster rebuilds
- No need to re-download dependencies
- Persistent across container restarts

## 🧪 Testing

```bash
# Inside container

# Test Karel parser
cd karel
task
./build/TestKarel test/simple.kl

# Run Stack tests
stack test

# Build and test all projects
cd /workspace
make stack-test
```

## 🔍 Troubleshooting

### Stack Issues

```bash
# Clear Stack cache
stack clean --full

# Rebuild
stack build --force-dirty
```

### LLVM Issues

```bash
# Check LLVM version
llvm-config --version

# Check include paths
llvm-config --includedir

# Check lib paths
llvm-config --libdir
```

### Docker Issues

```bash
# Rebuild image
make docker-rebuild

# Remove volumes
docker volume rm acc-stack-work acc-cabal acc-stack

# Start fresh
make docker-clean
make docker-build
make docker-run
```

## 📚 Usage Examples

### Example 1: Generate Parser

```bash
# Inside container
cd karel
bnfc -m --haskell -o build/ karel.cf
cd build
make
./TestKarel ../test/simple.kl
```

### Example 2: Stack Project

```bash
# Create new Stack project
stack new my-compiler

cd my-compiler

# Add to package.yaml
cat >> package.yaml << EOF
dependencies:
  - llvm-hs
  - llvm-hs-pure
  - llvm-hs-pretty
EOF

# Build
stack build

# Run
stack exec my-compiler-exe
```

### Example 3: LLVM IR

```bash
# Write LLVM IR
cat > example.ll << EOF
define i32 @add(i32 %a, i32 %b) {
  %sum = add i32 %a, %b
  ret i32 %sum
}
EOF

# Assemble to bitcode
llvm-as example.ll -o example.bc

# Optimize
opt -O3 example.bc -o example.opt.bc

# Compile to object
llc example.opt.bc -o example.o

# Link
clang example.o -o example
```

## 🎯 Next Steps

1. **✅ Build Karel Parser**: `cd karel && task`
2. **✅ Test Parser**: `./build/TestKarel test/simple.kl`
3. **🚧 Implement Semantic Analysis**: Type checking, symbol tables
4. **🚧 LLVM Code Generation**: Haskell AST → LLVM IR
5. **🚧 Runtime Library**: C runtime for robot functions
6. **🚧 Optimization**: LLVM passes, dead code elimination
7. **🚧 CLI Tool**: `karelc` compiler command

## 🔗 Resources

- **BNFC**: http://bnfc.digitalgrammars.com/
- **llvm-hs**: https://github.com/llvm-hs/llvm-hs
- **Stack**: https://docs.haskellstack.org/
- **LLVM Tutorial**: https://www.stephendiehl.com/llvm/

---

**Ready to build compilers! 🚀**
