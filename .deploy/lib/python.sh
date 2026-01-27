#!/bin/bash
set -e

source "$(dirname "$0")/apt.sh"

setup_python() {
    ensure_pkg python3
    ensure_pkg python3-pip
    export PATH="$HOME/.local/bin:$PATH"
}

setup_python_venv() {
    ensure_pkg python3-venv

    local venv="$1"

    python3 -m venv "$venv"
    source "$venv/bin/activate"
}

setup_poetry() {
    ensure_pkg curl
    
    if ! command -v poetry >/dev/null; then
        curl -sSL https://install.python-poetry.org | python3 -
    fi
}