#!/bin/bash
set -e

source "$(dirname "$0")/apt.sh"

setup_node() {
    ensure_pkg curl
    ensure_pkg ca-certificates

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    \. "$HOME/.nvm/nvm.sh"

    local version="24"

    nvm install "$version"
    nvm use "$version"

    node -v
    npm -v
}
