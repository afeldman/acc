# Karel LLVM Compiler

Ein vollständiger LLVM-basierter Compiler für die Karel-Programmiersprache (FANUC Robotics) mit integriertem C-ähnlichem Präprozessor.

## Features

### Compiler

- **LLVM Backend**: Generiert nativen Maschinencode über LLVM IR
- **AKU Module Support**: Integration mit Anton Karel Utils Library
- **Built-in Functions**: String, Math und Array-Operationen
- **Optimierungen**: LLVM-Optimierungspipeline

### Präprozessor

Karel enthält einen vollständigen C-ähnlichen Präprozessor mit `%` als Präfix:

- `%INCLUDE "file"` - Include-Dateien einbinden
- `%DEFINE name value` - Makros definieren
- `%UNDEF name` - Makros entfernen
- `%IFDEF name` - Bedingte Kompilierung
- `%IFNDEF name` - Negierte Bedingung
- `%IF expression` - Ausdrucks-Bedingungen
- `%ELSE` - Alternative
- `%ENDIF` - Block-Ende

Siehe [PREPROCESSOR.md](PREPROCESSOR.md) für vollständige Dokumentation.

## Installation

### Voraussetzungen

1. **Haskell Stack**:

```bash
# macOS
brew install haskell-stack

# Linux
curl -sSL https://get.haskellstack.org/ | sh
```

2. **LLVM** (Version 14, 15 oder 16):

```bash
# macOS
brew install llvm@14

# Ubuntu/Debian
sudo apt-get install llvm-14 llvm-14-dev
```

3. **BNFC, Alex, Happy**:

```bash
stack install BNFC alex happy
```

### Compiler bauen

```bash
# Mit Task (empfohlen)
task build:karel

# Oder manuell
cd karel
bnfc -m --haskell karel.cf
cd src
alex LexKarel.x
happy ParKarel.y
cd ..
stack build
```

## Verwendung

### Mit Ninja (empfohlen)

```bash
# Projekt konfigurieren
./configure.py

# Bauen
ninja

# Nur LLVM IR
ninja llvm

# Aufräumen
ninja clean
```

Siehe [NINJA.md](NINJA.md) für vollständige Ninja-Dokumentation.

### Direkte Kompilierung

```bash
# Karel zu Objektdatei kompilieren
karelc program.kl -o program.o

# LLVM IR ausgeben
karelc program.kl -emit-llvm -o program.ll

# Assembly ausgeben
karelc program.kl -S -o program.s
```

### Präprozessor

```bash
# Mit Präprozessor (Standard)
karelc program.kl -o program.o

# Nur Präprozessor ausführen
karelc program.kl --precompile

# Präprozessor überspringen
karelc program.kl --no-precompile -o program.o

# Benutzerdefinierter AKU-Pfad
karelc program.kl --aku-path /path/to/aku -o program.o
```

## Beispiele

### Hello World

```karel
PROGRAM hello_world
BEGIN
  WRITE('Hello from Karel!')
END hello_world
```

### Mit Präprozessor

```karel
%DEFINE DEBUG 1
%DEFINE VERSION 2

PROGRAM example
BEGIN
  %IFDEF DEBUG
    WRITE('Debug mode enabled')
  %ENDIF

  %IF VERSION >= 2
    WRITE('Using API v2')
  %ELSE
    WRITE('Using API v1')
  %ENDIF
END example
```

## Präprozessor-Features

Der Karel-Präprozessor ist äquivalent zum C-Präprozessor:

| C          | Karel      | Funktion              |
| ---------- | ---------- | --------------------- |
| `#define`  | `%DEFINE`  | Makros definieren     |
| `#undef`   | `%UNDEF`   | Makros entfernen      |
| `#ifdef`   | `%IFDEF`   | Bedingte Kompilierung |
| `#ifndef`  | `%IFNDEF`  | Negierte Bedingung    |
| `#if`      | `%IF`      | Ausdrucks-Bedingungen |
| `#else`    | `%ELSE`    | Alternative           |
| `#endif`   | `%ENDIF`   | Block-Ende            |
| `#include` | `%INCLUDE` | Include-Dateien       |

Siehe [PREPROCESSOR.md](PREPROCESSOR.md) für vollständige Dokumentation und Beispiele.
