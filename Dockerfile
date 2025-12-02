# Haskell LLVM Compiler Development Environment
FROM haskell:9.4.8

LABEL maintainer="Anton Feldmann"
LABEL description="Haskell + LLVM + BNFC development environment for ACC compiler projects"
LABEL version="1.0.0"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="/root/.local/bin:/root/.cabal/bin:${PATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # LLVM dependencies
    llvm-14 \
    llvm-14-dev \
    llvm-14-runtime \
    llvm-14-tools \
    clang-14 \
    libedit-dev \
    libffi-dev \
    libncurses5-dev \
    libz-dev \
    # Build tools
    build-essential \
    cmake \
    curl \
    git \
    pkg-config \
    # Haskell build tools
    alex \
    happy \
    # Utilities
    vim \
    tree \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic links for LLVM tools
RUN update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-14 100 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 100 && \
    update-alternatives --install /usr/bin/opt opt /usr/bin/opt-14 100 && \
    update-alternatives --install /usr/bin/llc llc /usr/bin/llc-14 100 && \
    update-alternatives --install /usr/bin/lli lli /usr/bin/lli-14 100

# Install Stack (latest)
RUN curl -sSL https://get.haskellstack.org/ | sh

# Configure Stack to use system GHC
RUN stack config set system-ghc --global true && \
    stack config set install-ghc --global false

# Install BNFC globally with cabal
RUN cabal update && \
    cabal install --global BNFC && \
    cabal install --global bnfc-meta

# Pre-install common Haskell packages to speed up builds
RUN stack install --resolver lts-21.25 \
    llvm-hs-14.0.0.0 \
    llvm-hs-pure-14.0.0.0 \
    llvm-hs-pretty-0.13.0.0 \
    megaparsec \
    mtl \
    transformers \
    text \
    bytestring \
    containers \
    filepath \
    directory

# Create workspace directory
WORKDIR /workspace

# Set default resolver
RUN echo "resolver: lts-21.25" > /root/.stack/global-project/stack.yaml && \
    echo "packages: []" >> /root/.stack/global-project/stack.yaml && \
    echo "" >> /root/.stack/global-project/stack.yaml && \
    echo "extra-deps:" >> /root/.stack/global-project/stack.yaml && \
    echo "  - llvm-hs-14.0.0.0" >> /root/.stack/global-project/stack.yaml && \
    echo "  - llvm-hs-pure-14.0.0.0" >> /root/.stack/global-project/stack.yaml && \
    echo "  - llvm-hs-pretty-0.13.0.0" >> /root/.stack/global-project/stack.yaml

# Verify installations
RUN echo "=== Versions ===" && \
    ghc --version && \
    stack --version && \
    cabal --version && \
    bnfc --version && \
    llvm-config --version && \
    alex --version && \
    happy --version

# Create helpful scripts
RUN echo '#!/bin/bash\n\
echo "=== ACC Compiler Development Environment ==="\n\
echo ""\n\
echo "Installed Tools:"\n\
echo "  GHC:        $(ghc --version | head -1)"\n\
echo "  Stack:      $(stack --version | head -1)"\n\
echo "  Cabal:      $(cabal --version | head -1)"\n\
echo "  BNFC:       $(bnfc --version 2>&1 | head -1)"\n\
echo "  LLVM:       $(llvm-config --version)"\n\
echo "  Alex:       $(alex --version | head -1)"\n\
echo "  Happy:      $(happy --version | head -1)"\n\
echo ""\n\
echo "Quick Start:"\n\
echo "  1. Generate parser:  bnfc -m --haskell -o build/ grammar.cf"\n\
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
