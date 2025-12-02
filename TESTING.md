# GitHub Actions Local Testing

Dieses Projekt nutzt [act](https://github.com/nektos/act) zum lokalen Testen der GitHub Actions Workflows.

## Installation

```bash
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Windows (via chocolatey)
choco install act-cli
```

## Verwendung

### Schnelltest aller Workflows

```bash
# Validiere Workflow-Syntax
./validate-workflows.sh

# Teste Build-Workflow
./test-workflow.sh build

# Teste Test-Workflow
./test-workflow.sh test
```

### Einzelne Jobs testen

```bash
# Nur Brainfuck-Compiler bauen
./test-workflow.sh bf

# Nur Whitespace-Compiler bauen
./test-workflow.sh ws

# Nur Grammatiken validieren
./test-workflow.sh grammars
```

### Verfügbare Befehle

```bash
./test-workflow.sh list    # Zeigt alle verfügbaren Tests
```

## Workflow-Übersicht

### Build & Release (`build-compilers.yml`)

- **Trigger**: Push zu main/master
- **Jobs**:
  - `build-brainfuck` - Baut Brainfuck-Compiler
  - `build-whitespace` - Baut Whitespace-Compiler
  - `build-grammars` - Validiert BNFC-Grammatiken
  - `release` - Erstellt GitHub Release

### Testing (`test.yml`)

- **Trigger**: Pull Requests
- **Jobs**:
  - `test-brainfuck` - Testet BF-Beispiele
  - `test-whitespace` - Testet WS-Beispiele

## Tipps

### Schnellerer Test ohne Docker-Pull

```bash
# Cache Docker-Images
docker pull catthehacker/ubuntu:act-latest

# Verwende --reuse für Container-Wiederverwendung
act push --reuse
```

### Debug-Modus

```bash
# Verbose Output
act push --verbose

# Mit Shell-Zugang bei Fehler
act push --shell-debug
```

### Nur bestimmte Jobs

```bash
# Einzelner Job
act push --job build-brainfuck

# Workflow-Liste anzeigen
act -l
```

## Konfiguration

Die Datei `.actrc` enthält Standard-Konfiguration:

- Docker-Images (catthehacker/ubuntu)
- Container-Architektur (linux/amd64)
- Artifact-Pfad (/tmp/act-artifacts)

## Bekannte Einschränkungen

- `actions/upload-artifact@v4` benötigt `--artifact-server-path`
- `softprops/action-gh-release` funktioniert nur mit echtem GITHUB_TOKEN
- LLVM-Installation kann bei act länger dauern

## Troubleshooting

### "act: command not found"

```bash
brew install act  # macOS
```

### Docker-Fehler

```bash
# Docker starten
docker info

# Docker-Images aktualisieren
docker pull catthehacker/ubuntu:act-latest
```

### Workflow-Fehler

```bash
# Syntax prüfen
./validate-workflows.sh

# Verbose-Modus
act push --verbose --dry-run
```

## Weitere Informationen

- [act Documentation](https://github.com/nektos/act)
- [GitHub Actions Docs](https://docs.github.com/actions)
- [catthehacker Images](https://github.com/catthehacker/docker_images)
