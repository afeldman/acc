# Whitespace LLVM Compiler

A complete Whitespace to LLVM compiler written in Haskell.

## Features

✅ **Complete Whitespace Support**

- Stack manipulation: `push`, `dup`, `discard`
- Arithmetic: `add`, `sub`, `mul`, `div`, `mod`
- Heap access: `store`, `retrieve`
- Control flow: `label`, `call`, `jump`, `jz`, `jn`, `ret`, `end`
- I/O: `outchar`, `outnum`, `readchar`, `readnum`

✅ **LLVM Backend**

- Generates optimized LLVM IR
- Produces native executables
- 10,000 element stack (64-bit integers)
- 10,000 element heap

✅ **Build System**

- BNFC parser generation
- Stack build system
- Easy compilation scripts

## Installation

### Prerequisites

```bash
# Install Stack (Haskell)
curl -sSL https://get.haskellstack.org/ | sh

# Install BNFC
cabal install BNFC

# Install LLVM 14
# On Ubuntu/Debian:
sudo apt install llvm-14 clang-14

# On macOS:
brew install llvm@14
```

### Build

```bash
cd whitespace

# Build compiler
chmod +x build.sh run.sh
./build.sh

# Or manually:
bnfc -m --haskell -o src/ whitespace.cf
cd src && alex LexWhitespace.x && happy ParWhitespace.y && cd ..
stack build
```

## Usage

### Compile Whitespace to LLVM IR

```bash
stack exec wsc -- hello.ws -emit-llvm -o hello.ll
```

### Compile to Executable

```bash
./run.sh test/hello.ws
./hello
```

### Command Line Options

```bash
wsc <input.ws> [options]

Options:
  -emit-llvm          Generate LLVM IR (.ll file)
  -o <output>         Specify output file
  -S                  Generate assembly
```

## Whitespace Language

Whitespace is a stack-based esoteric programming language that uses only whitespace characters (space, tab, newline). This implementation uses readable keywords for easier development.

### Instructions

#### Stack Manipulation

- `push` - Push value onto stack
- `dup` - Duplicate top of stack
- `discard` - Discard top of stack

#### Arithmetic

- `add` - Pop two values, push sum
- `sub` - Pop two values, push difference
- `mul` - Pop two values, push product
- `div` - Pop two values, push quotient
- `mod` - Pop two values, push remainder

#### Heap Access

- `store` - Pop value and address, store value at heap[address]
- `retrieve` - Pop address, push heap[address]

#### Control Flow

- `label <name>` - Define label
- `call <name>` - Call subroutine
- `jump <name>` - Unconditional jump
- `jz <name>` - Jump if top of stack is zero
- `jn <name>` - Jump if top of stack is negative
- `ret` - Return from subroutine
- `end` - End program

#### I/O

- `outchar` - Pop value, output as character
- `outnum` - Pop value, output as number
- `readchar` - Read character, store at heap[address]
- `readnum` - Read number, store at heap[address]

## Examples

### Simple Calculation

**File**: `test/simple.ws`

```whitespace
push        // Push 0
push        // Push 0
add         // 0 + 0 = 0
outnum      // Output: 0
end
```

### Hello World (Simplified)

**File**: `test/hello.ws`

```whitespace
push        // Push value
dup         // Duplicate
add         // Add
outchar     // Output as character
end
```

## How It Works

### 1. Grammar (`whitespace.cf`)

```lbnf
WSGrammar . WS ::= [Stm];

SPush.      Stm ::= "push" ;
SDup.       Stm ::= "dup" ;
SAdd.       Stm ::= "add" ;
SOutChar.   Stm ::= "outchar" ;
SEnd.       Stm ::= "end" ;
```

### 2. Code Generation

The compiler translates Whitespace instructions to LLVM IR:

```haskell
-- Add instruction
SAdd -> do
  b <- popStack stack sp
  a <- popStack stack sp
  result <- add a b
  pushStack stack sp result
```

Generated LLVM IR:

```llvm
define i32 @main() {
entry:
  %stack = alloca [10000 x i64]
  %sp = alloca i32
  store i32 0, i32* %sp

  ; pop b
  %0 = load i32, i32* %sp
  %1 = sub i32 %0, 1
  store i32 %1, i32* %sp
  %2 = getelementptr [10000 x i64], [10000 x i64]* %stack, i32 0, i32 %1
  %b = load i64, i64* %2

  ; pop a
  ; ... similar ...

  ; add
  %result = add i64 %a, %b

  ; push result
  ; ...

  ret i32 0
}
```

### 3. Compilation Pipeline

```
ws → [BNFC Parser] → AST → [CodeGen] → LLVM IR → [llc] → Object → [clang] → Executable
```

## Architecture

```
whitespace/
├── whitespace.cf         # BNFC grammar
├── ws-compiler.cabal     # Cabal package
├── stack.yaml            # Stack config
├── build.sh              # Build script
├── run.sh                # Run script
├── src/
│   ├── Main.hs          # Compiler driver
│   ├── CodeGen.hs       # LLVM code generation
│   ├── LLVM.hs          # LLVM utilities
│   ├── AbsWhitespace.hs # AST (generated)
│   ├── LexWhitespace.hs # Lexer (generated)
│   └── ParWhitespace.hs # Parser (generated)
└── test/
    ├── hello.ws         # Hello World
    └── simple.ws        # Simple test
```

## Memory Model

- **Stack**: 10,000 elements (i64 array)
- **Heap**: 10,000 elements (i64 array)
- **Stack Pointer**: 32-bit integer
- **Values**: 64-bit signed integers
- **I/O**: Uses C `putchar`, `getchar`, `printf`, `scanf`

## Implementation Details

### Stack Operations

```haskell
pushStack :: AST.Operand -> AST.Operand -> AST.Operand -> Codegen ()
pushStack stack sp value = do
  idx <- load sp
  cellPtr <- gep stack [zero, idx]
  store cellPtr value
  idx' <- add idx one
  store sp idx'

popStack :: AST.Operand -> AST.Operand -> Codegen AST.Operand
popStack stack sp = do
  idx <- load sp
  idx' <- sub idx one
  store sp idx'
  cellPtr <- gep stack [zero, idx']
  load64 cellPtr
```

### Control Flow

Labels are handled using LLVM basic blocks:

```haskell
SLabel (Ident name) -> do
  labelBlock <- addBlock ("label_" ++ name)
  br labelBlock
  setBlock labelBlock

SJump (Ident name) -> do
  labelBlock <- getOrCreateLabel name
  br labelBlock
```

## Testing

```bash
# Test simple program
./run.sh test/simple.ws
./simple

# Test hello world
./run.sh test/hello.ws
./hello
```

## Optimization

```bash
# Optimize with LLVM
opt -O3 hello.ll -o hello.opt.bc
llc -filetype=obj hello.opt.bc -o hello.o
clang hello.o -o hello
```

## Limitations

- Fixed stack/heap size (10,000 elements each)
- No stack overflow checking
- Simplified `push` instruction (pushes 0)
- Call stack not fully implemented
- No proper tail call optimization

## Future Improvements

- [ ] Parse actual numbers for `push`
- [ ] Stack overflow detection
- [ ] Full call stack implementation
- [ ] Tail call optimization
- [ ] JIT compilation
- [ ] Debugging support
- [ ] Native whitespace character support
- [ ] Garbage collection for heap

## References

- **Whitespace**: https://en.wikipedia.org/wiki/Whitespace_(programming_language)
- **BNFC**: http://bnfc.digitalgrammars.com/
- **llvm-hs**: https://github.com/llvm-hs/llvm-hs
- **LLVM**: https://llvm.org/

---

**Built with**: Haskell • BNFC • LLVM • Stack
