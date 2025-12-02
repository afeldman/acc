# ACC - Advanced Compiler Collection

A collection of LLVM-based compilers for various programming languages, built with Haskell and BNFC.

![Build Status](https://github.com/yourusername/acc/workflows/Build%20Compilers/badge.svg)

## 🚀 Quick Start

### Download Pre-built Compilers

Visit the [Releases](https://github.com/yourusername/acc/releases) page to download pre-built compilers:

```bash
# Download and extract Brainfuck compiler
wget https://github.com/yourusername/acc/releases/latest/download/bf-compiler.tar.gz
tar -xzf bf-compiler.tar.gz
cd bf

# Compile and run
./bfc test/hello.bf -emit-llvm
llc -filetype=obj hello.ll
clang hello.o -o hello
./hello
```

### Build from Source

#### Prerequisites

- Docker (recommended) or:
  - Haskell Stack
  - LLVM 14
  - BNFC 2.9.6+

#### Using Docker

```bash
# Build Docker environment
make docker-build

# Enter development shell
./dev.sh

# Inside container, build compilers
cd bf && ./build.sh
cd ../whitespace && ./build.sh
```

#### Native Build

```bash
# Install dependencies
brew install llvm@14 stack  # macOS
# or
sudo apt install llvm-14 haskell-stack  # Ubuntu

# Install BNFC
stack install BNFC

# Build Brainfuck compiler
cd bf
./build.sh

# Build Whitespace compiler
cd ../whitespace
./build.sh
```

## 📦 Compilers

### Brainfuck Compiler (`bfc`)

LLVM-based compiler for the Brainfuck esoteric language.

**Features:**

- ✅ Full Brainfuck support (8 commands)
- ✅ 30,000 byte tape
- ✅ LLVM IR generation
- ✅ Native executable output

**Usage:**

```bash
bfc hello.bf -emit-llvm -o hello.ll
bfc program.bf -o program
```

[Full Documentation →](bf/README.md)

### Whitespace Compiler (`wsc`)

LLVM-based compiler for the Whitespace stack-based language.

**Features:**

- ✅ Complete Whitespace instruction set
- ✅ Stack + Heap memory model
- ✅ 10,000 element stack/heap
- ✅ Integer arithmetic
- ✅ Control flow (labels, jumps, calls)

**Usage:**

```bash
wsc program.ws -emit-llvm -o program.ll
wsc source.ws -o executable
```

[Full Documentation →](whitespace/README.md)

## 📝 BNFC Grammars

Validated BNFC grammars for 10 programming languages:

| Language       | Rules | Description                      |
| -------------- | ----- | -------------------------------- |
| **Karel**      | 357   | FANUC robot programming language |
| **KRL**        | 137   | KUKA Robot Language 8.x          |
| **TPE**        | 93    | FANUC Teach Pendant Editor       |
| **URS**        | 45    | Universal Robots Script          |
| **VHDL**       | 207   | Hardware description language    |
| **Brainfuck**  | 11    | Esoteric minimalist language     |
| **JSON**       | 18    | Data interchange format          |
| **INI**        | 9     | Configuration file format        |
| **BASIC**      | 36    | Classic BASIC dialect            |
| **Whitespace** | 25    | Stack-based esoteric language    |

### Using Grammars

```bash
# Download grammars
wget https://github.com/yourusername/acc/releases/latest/download/grammars.tar.gz
tar -xzf grammars.tar.gz
cd grammars

# Generate parser
bnfc -m --haskell karel.cf
make
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Source Code                          │
│         (.bf, .ws, .karel, .krl, etc.)                │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              BNFC Parser Generator                     │
│         (Lexer + Parser + AST)                        │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              Haskell Compiler                          │
│         (CodeGen.hs → LLVM AST)                       │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                  LLVM Backend                          │
│         (Optimization + Code Generation)               │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              Native Executable                         │
│         (x86_64, ARM, etc.)                           │
└─────────────────────────────────────────────────────────┘
```

## 🔧 Development

### Project Structure

```
acc/
├── .github/workflows/      # CI/CD pipelines
│   ├── build-compilers.yml # Build and release
│   └── test.yml            # Testing
├── bf/                     # Brainfuck compiler
│   ├── src/
│   │   ├── CodeGen.hs     # LLVM code generation
│   │   ├── LLVM.hs        # LLVM utilities
│   │   └── Main.hs        # CLI driver
│   ├── test/              # Test programs
│   ├── bf.cf              # BNFC grammar
│   ├── build.sh           # Build script
│   └── README.md
├── whitespace/            # Whitespace compiler
│   ├── src/
│   │   ├── CodeGen.hs    # Stack-based codegen
│   │   ├── LLVM.hs       # LLVM utilities
│   │   └── Main.hs       # CLI driver
│   ├── test/             # Test programs
│   ├── whitespace.cf     # BNFC grammar
│   ├── build.sh          # Build script
│   └── README.md
├── karel/                # FANUC Karel grammar
├── krl/                  # KUKA KRL grammar
├── tpe/                  # FANUC TPE grammar
├── urs/                  # Universal Robots grammar
├── vhdl/                 # VHDL grammar
├── json/                 # JSON grammar
├── ini/                  # INI grammar
├── basic/                # BASIC grammar
├── Dockerfile            # Development environment
├── docker-compose.yml    # Docker setup
└── README.md
```

### Adding a New Compiler

1. **Create grammar file** (`language.cf`):

```lbnf
Program . Prog ::= [Stm];
SStatement. Stm ::= "keyword" ;
```

2. **Generate parser**:

```bash
bnfc -m --haskell language.cf
alex LexLanguage.x
happy ParLanguage.y
```

3. **Implement CodeGen**:

```haskell
module CodeGen where
import qualified LLVM.AST as AST

codegenModule :: Prog -> AST.Module
codegenModule prog = ...
```

4. **Create CLI driver**:

```haskell
module Main where
import ParLanguage

main :: IO ()
main = ...
```

5. **Add to CI/CD** (`.github/workflows/build-compilers.yml`)

### Running Tests

```bash
# Test Brainfuck compiler
cd bf
./build.sh
stack exec bfc -- test/hello.bf -emit-llvm

# Test Whitespace compiler
cd whitespace
./build.sh
stack exec wsc -- test/simple.ws -emit-llvm
```

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open a Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🔗 Resources

- **BNFC**: http://bnfc.digitalgrammars.com/
- **LLVM**: https://llvm.org/
- **llvm-hs**: https://github.com/llvm-hs/llvm-hs
- **Stack**: https://docs.haskellstack.org/

## 🏆 Acknowledgments

Built with:

- Haskell 9.4.8
- LLVM 14
- BNFC 2.9.6
- Stack LTS 21.25

---

**Made with ❤️ for compiler enthusiasts**
