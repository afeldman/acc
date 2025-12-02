# ACC Build System

Docker-basiertes Build-System für alle ACC Compiler.

## Voraussetzungen

- Docker & Docker Compose installiert
- Docker Image muss gebaut sein: `docker-compose build`

## Alle Compiler bauen

```bash
./build-all.sh
```

Baut alle 10 Compiler und kopiert die Executables nach `build-output/`:

- `basicc` - BASIC Compiler
- `bfc` - Brainfuck Compiler
- `wsc` - Whitespace Compiler
- `karelc` - Karel Compiler
- `krlc` - KUKA KRL Compiler
- `tpec` - FANUC TPE Compiler
- `ursc` - Universal Robots Compiler
- `vhdlc` - VHDL Compiler
- `ini-parser` - INI Parser
- `json-parser` - JSON Parser

## Einzelnen Compiler bauen

```bash
./build.sh <compiler-name>
```

Beispiele:

```bash
./build.sh basic
./build.sh karel
./build.sh bf
```

Das Executable wird in das jeweilige Compiler-Verzeichnis kopiert:

```bash
basic/basicc
karel/karelc
bf/bfc
```

## Verwendung der Compiler

Nach dem Build können die Compiler verwendet werden:

```bash
# BASIC Compiler
./basic/basicc examples/hello.bas -o hello.ll

# Karel Compiler
./karel/karelc test/simple.kl -o simple.ll

# Brainfuck Compiler
./bf/bfc examples/hello.bf
```

## Build-Prozess

Für jeden Compiler:

1. **BNFC** - Generiert Parser aus `.cf` Grammar
2. **Alex** - Generiert Lexer aus `.x` Datei
3. **Happy** - Generiert Parser aus `.y` Datei
4. **Stack** - Kompiliert Haskell Code zu Executable

## Troubleshooting

### Docker Image nicht vorhanden

```bash
docker-compose build
```

### Alte Build-Artefakte löschen

```bash
# Einzelner Compiler
rm -rf <compiler>/.stack-work

# Alle Compiler
find . -name ".stack-work" -type d -exec rm -rf {} +
```

### Verbose Build

Entferne `grep` Filter in den Scripts um vollständige Ausgabe zu sehen.

## Clean Build

```bash
# Löscht alle Build-Artefakte und Executables
./clean.sh
```
