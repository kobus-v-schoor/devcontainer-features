#!/usr/bin/env bash

CODEX_VERSION="${VERSION:-"latest"}"
CODEX_PACKAGE="@openai/codex"

set -e

if [ "${CODEX_VERSION}" = "none" ]; then
    echo "Skipping Codex CLI installation per 'none' version option."
    exit 0
fi

echo "Installing Codex CLI..."

# Ensure Node.js and npm are available
if ! command -v npm >/dev/null 2>&1; then
    echo "(!) npm is required to install Codex CLI but was not found on this system."
    echo "    Please install Node.js / npm (e.g. via the 'ghcr.io/devcontainers/features/node' feature)"
    echo "    or use a base image that already includes Node.js."
    exit 1
fi

node_version=$(node --version 2>/dev/null || echo "unknown")
npm_version=$(npm --version 2>/dev/null || echo "unknown")
echo "Node.js ${node_version}, npm ${npm_version}"

# Install Codex CLI globally via npm
if [ "${CODEX_VERSION}" = "latest" ]; then
    npm install -g --no-fund --no-audit --progress=false "${CODEX_PACKAGE}"
else
    npm install -g --no-fund --no-audit --progress=false "${CODEX_PACKAGE}@${CODEX_VERSION}"
fi

# Verify installation
if command -v codex >/dev/null 2>&1; then
    codex_version_installed=$(codex --version 2>/dev/null || echo "unknown")
    echo "Codex CLI ${codex_version_installed} installed successfully."
else
    echo "(!) Codex CLI was installed, but the 'codex' command is not available on PATH."
    npm_global_bin="$(npm prefix -g 2>/dev/null || npm config get prefix 2>/dev/null)/bin"
    if [ -d "${npm_global_bin}" ]; then
        echo "    npm global bin directory: ${npm_global_bin}"
        echo "    Add it to your PATH if needed."
    fi
    exit 1
fi

echo "Done!"
