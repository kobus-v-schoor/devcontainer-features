#!/usr/bin/env bash

PI_VERSION="${VERSION:-"latest"}"
PI_PACKAGE="@earendil-works/pi-coding-agent"

set -e

echo "Installing Pi Coding Agent..."

# Install Pi globally via npm
if [ "${PI_VERSION}" = "latest" ]; then
    npm install -g --ignore-scripts --no-fund --no-audit --progress=false "${PI_PACKAGE}"
else
    npm install -g --ignore-scripts --no-fund --no-audit --progress=false "${PI_PACKAGE}@${PI_VERSION}"
fi

# Verify installation
if command -v pi > /dev/null 2>&1; then
    pi_version_installed=$(pi --version 2>/dev/null || echo "unknown")
    echo "Pi Coding Agent ${pi_version_installed} installed successfully."
else
    echo "(!) Pi was installed, but the 'pi' command is not available on PATH."
    npm_global_bin="$(npm prefix -g 2>/dev/null || npm config get prefix 2>/dev/null)/bin"
    if [ -d "${npm_global_bin}" ]; then
        echo "    npm global bin directory: ${npm_global_bin}"
        echo "    Add it to your PATH if needed."
    fi
    exit 1
fi

echo "Done!"
