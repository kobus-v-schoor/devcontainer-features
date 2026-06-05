#!/bin/sh

NEOVIM_VERSION="${VERSION:-"latest"}"

set -e

if [ "${NEOVIM_VERSION}" = "none" ]; then
    echo "Skipping Neovim installation per 'none' version option."
    exit 0
fi

echo "Installing Neovim and ripgrep from official system repositories..."

if command -v apt-get >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y -qq neovim ripgrep
    rm -rf /var/lib/apt/lists/*
elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache neovim ripgrep
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y neovim ripgrep
elif command -v yum >/dev/null 2>&1; then
    yum install -y neovim ripgrep
else
    echo "(!) Package manager not found. Please install Neovim and ripgrep manually."
    exit 1
fi

# Verify installations
if command -v nvim >/dev/null 2>&1; then
    nvim_version=$(nvim --version 2>/dev/null | head -n 1 || echo "unknown")
    echo "Neovim installed: ${nvim_version}"
else
    echo "(!) Neovim was installed, but the 'nvim' command is not available on PATH."
    exit 1
fi

if command -v rg >/dev/null 2>&1; then
    rg_version=$(rg --version 2>/dev/null | head -n 1 || echo "unknown")
    echo "ripgrep installed: ${rg_version}"
else
    echo "(!) ripgrep was installed, but the 'rg' command is not available on PATH."
    exit 1
fi

echo "Done!"
