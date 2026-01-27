#!/bin/bash
set -e

source "$(dirname "$0")/apt.sh"

sync_repo() {
    ensure_pkg git

    local repo="$1"
    local dir="$2"
    local branch="${3:-main}"

    if [ ! -d "$dir/.git" ]; then
        git clone "$repo" "$dir"
    else
        cd "$dir"
        git fetch origin "$branch"
        git reset --hard "origin/$branch"
    fi
}
