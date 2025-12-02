# Haskell LLVM Compiler Development Environment
FROM ubuntu:22.04

LABEL maintainer="Anton Feldmann"
LABEL description="Haskell + LLVM + BNFC development environment for ACC compiler projects"
LABEL version="2.0.0"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="/root/.local/bin:/root/.cabal/bin:/root/.ghcup/bin:${PATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    curl \
    wget \
    git \
    pkg-config \
    # LLVM dependencies
    llvm-14 \
    llvm-14-dev \
    llvm-14-runtime \
    llvm-14-tools \
    clang-14 \
    libedit-dev \
    libffi-dev \
    libncurses5-dev \
    libncursesw5-dev \
    zlib1g-dev \
    libtinfo-dev \
    libgmp-dev \
    # Utilities
    vim \
    tree \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Install GHCup (Haskell installer)
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
    BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
    BOOTSTRAP_HASKELL_GHC_VERSION=9.4.8 \
    BOOTSTRAP_HASKELL_CABAL_VERSION=3.10.2.0 \
    BOOTSTRAP_HASKELL_INSTALL_STACK=1 \
    BOOTSTRAP_HASKELL_INSTALL_HLS=1 \
    BOOTSTRAP_HASKELL_ADJUST_BASHRC=1 \
    sh

# Install alex and happy via cabal
RUN /root/.ghcup/bin/cabal update && \
    /root/.ghcup/bin/cabal install alex happy

# Create symbolic links for LLVM tools
RUN update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-14 100 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 100 && \
    update-alternatives --install /usr/bin/opt opt /usr/bin/opt-14 100 && \
    update-alternatives --install /usr/bin/llc llc /usr/bin/llc-14 100 && \
    update-alternatives --install /usr/bin/lli lli /usr/bin/lli-14 100

# Install BNFC via cabal
RUN /root/.ghcup/bin/cabal install BNFC

# Create workspace directory
WORKDIR /workspace

# Verify installations
RUN echo "=== Versions ===" && \
    /root/.ghcup/bin/ghc --version && \
    /root/.ghcup/bin/stack --version && \
    /root/.ghcup/bin/cabal --version && \
    /root/.cabal/bin/bnfc --version && \
    llvm-config --version && \
    /root/.cabal/bin/alex --version && \
    /root/.cabal/bin/happy --version

# Create helpful scripts
RUN echo '#!/bin/bash\n\
echo "=== ACC Compiler Development Environment ==="\n\
echo ""\n\
echo "Installed Tools:"\n\
echo "  GHC:        $(/root/.ghcup/bin/ghc --version | head -1)"\n\
echo "  Stack:      $(/root/.ghcup/bin/stack --version | head -1)"\n\
echo "  Cabal:      $(/root/.ghcup/bin/cabal --version | head -1)"\n\
echo "  BNFC:       $(/root/.cabal/bin/bnfc --version 2>&1 | head -1)"\n\
echo "  LLVM:       $(llvm-config --version)"\n\
echo "  Alex:       $(/root/.cabal/bin/alex --version | head -1)"\n\
echo "  Happy:      $(/root/.cabal/bin/happy --version | head -1)"\n\
echo ""\n\
echo "Quick Start:"\n\
echo "  1. Generate parser:  bnfc -m --haskell -d grammar.cf"\n\
echo "  2. Build project:    stack build"\n\
echo "  3. Run tests:        stack test"\n\
echo "  4. LLVM IR:          llvm-as example.ll -o example.bc"\n\
echo ""\n\
echo "Available Commands:"\n\
echo "  bnfc         - BNF Converter"\n\
echo "  stack        - Haskell Stack build tool"\n\
echo "  ghc          - Glasgow Haskell Compiler"\n\
echo "  llvm-config  - LLVM configuration tool"\n\
echo "  opt          - LLVM optimizer"\n\
echo "  llc          - LLVM static compiler"\n\
echo "  clang        - C/C++ compiler"\n\
' > /usr/local/bin/info && chmod +x /usr/local/bin/info

# Default command shows info
CMD ["info"]
