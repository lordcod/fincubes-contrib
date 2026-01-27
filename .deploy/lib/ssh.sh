#!/bin/bash
set -e

source "$(dirname "$0")/apt.sh"

ensure_github_ssh() {
    ensure_pkg git
    ensure_pkg openssh-client

    local key="$HOME/.ssh/id_ed25519"

    if [ ! -f "$key" ]; then
        ssh-keygen -t ed25519 -f "$key" -N ""
        echo "Добавь ключ в GitHub:"
        cat "$key.pub"
        exit 1
    fi

    ssh -T git@github.com || true
}
