## OS Support

This Feature should work on recent versions of Debian/Ubuntu-based distributions with the `apt` package manager installed, as well as Alpine (apk), Fedora (dnf), and CentOS/RHEL (yum).

`bash` is required to execute the `install.sh` script.

Node.js and npm are required to install OpenCode and must be available in the container before this feature runs. The feature lists `ghcr.io/devcontainers/features/node` as a soft-dependency, but you can also provide Node.js via another method (e.g., a base image with Node.js pre-installed).

## Installation

OpenCode is installed globally via `npm install -g opencode-ai`.
