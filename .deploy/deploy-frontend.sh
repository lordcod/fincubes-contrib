#!/bin/bash
set -e

PROJECT="$HOME/fincubes-nextjs"
REPO="git@github.com:lordcod/fincubes-nextjs.git"

SERVICE="fincubes-frontend.service"
NGINX="frontend.fincubes.ru.conf"
NODE_VERSION="lts/*"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="$BASE_DIR/lib"
FILES="$BASE_DIR/files"

source "$LIB/ssh.sh"
source "$LIB/git.sh"
source "$LIB/node.sh"
source "$LIB/systemd.sh"
source "$LIB/nginx.sh"

ensure_github_ssh
sync_repo "$REPO" "$PROJECT"

setup_node "$NODE_VERSION"

cd "$PROJECT"
npm ci
npm run build

setup_systemd \
    "$SERVICE" \
    "$FILES/systemd/$SERVICE"

setup_nginx \
    "$NGINX" \
    "$FILES/nginx/$NGINX"
