#!/bin/bash
set -e

PROJECT="$HOME/fincubes-fastapi"
VENV="$HOME/fincubes-venv"
REPO="git@github.com:lordcod/fincubes-fastapi.git"

SERVICE="fincubes-fastapi.service"
NGINX="api.fincubes.ru.conf"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="$BASE_DIR/lib"
FILES="$BASE_DIR/files"

source "$LIB/ssh.sh"
source "$LIB/git.sh"
source "$LIB/python.sh"
source "$LIB/systemd.sh"
source "$LIB/nginx.sh"

ensure_github_ssh
sync_repo "$REPO" "$PROJECT"
setup_python
setup_python_venv "$VENV"
setup_poetry

cd "$PROJECT"
poetry install

setup_systemd \
    "$SERVICE" \
    "$FILES/systemd/$SERVICE"

setup_nginx \
    "$NGINX" \
    "$FILES/nginx/$NGINX"
