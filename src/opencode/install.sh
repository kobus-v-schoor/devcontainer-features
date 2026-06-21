#!/usr/bin/env bash

OPENCODE_VERSION="${VERSION:-"latest"}"
OPENCODE_PACKAGE="opencode-ai"

set -e

if [ "${OPENCODE_VERSION}" = "none" ]; then
    echo "Skipping OpenCode installation per 'none' version option."
    exit 0
fi

echo "Installing OpenCode..."

# Ensure Node.js and npm are available
if ! command -v npm >/dev/null 2>&1; then
    echo "(!) npm is required to install OpenCode but was not found on this system."
    echo "    Please install Node.js / npm (e.g. via the 'ghcr.io/devcontainers/features/node' feature)"
    echo "    or use a base image that already includes Node.js."
    exit 1
fi

node_version=$(node --version 2>/dev/null || echo "unknown")
npm_version=$(npm --version 2>/dev/null || echo "unknown")
echo "Node.js ${node_version}, npm ${npm_version}"

# Install OpenCode globally via npm
if [ "${OPENCODE_VERSION}" = "latest" ]; then
    npm install -g --no-fund --no-audit --progress=false "${OPENCODE_PACKAGE}"
else
    npm install -g --no-fund --no-audit --progress=false "${OPENCODE_PACKAGE}@${OPENCODE_VERSION}"
fi

# Verify installation
if command -v opencode >/dev/null 2>&1; then
    opencode_version_installed=$(opencode --version 2>/dev/null || echo "unknown")
    echo "OpenCode ${opencode_version_installed} installed successfully."
else
    echo "(!) OpenCode was installed, but the 'opencode' command is not available on PATH."
    npm_global_bin="$(npm prefix -g 2>/dev/null || npm config get prefix 2>/dev/null)/bin"
    if [ -d "${npm_global_bin}" ]; then
        echo "    npm global bin directory: ${npm_global_bin}"
        echo "    Add it to your PATH if needed."
    fi
    exit 1
fi

echo "Done!"
