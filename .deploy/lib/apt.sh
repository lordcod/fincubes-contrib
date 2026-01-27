#!/bin/bash
set -e

ensure_pkg() {
    local pkg="$1"

    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y "$pkg"
    fi
}
