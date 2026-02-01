#!/bin/bash
set -e

ensure_pkg() {
    local pkg="$1"

    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y "$pkg"
    fi
}

ensure_github_ssh() {
    ensure_pkg git
    ensure_pkg openssh-client

    local key="$HOME/.ssh/id_ed25519"

    if [ ! -f "$key" ]; then
        ssh-keygen -t ed25519 -f "$key" -N ""
        echo "Добавьте ключ в GitHub:"
        cat "$key.pub"
        exit 1
    fi

    ssh -T git@github.com || true
}

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

setup_systemd_service() {
    local service_name="$1"
    local service_file="$2"

    echo "=== РќР°СЃС‚СЂРѕР№РєР° systemd: $service_name ==="

    if [ ! -f "$service_file" ]; then
        echo "Systemd С„Р°Р№Р» РЅРµ РЅР°Р№РґРµРЅ: $service_file"
        return 1
    fi

    sudo cp "$service_file" "/etc/systemd/system/$service_name"
    sudo systemctl daemon-reload
    sudo systemctl enable "$service_name"

    echo "Systemd СЃРµСЂРІРёСЃ $service_name СѓСЃС‚Р°РЅРѕРІР»РµРЅ."
}

setup_systemd() {
    setup_systemd_service "$@"
}

setup_nginx_site() {
    local site_name="$1"
    local source_conf="$2"
    local enabled="/etc/nginx/conf.d/$site_name"

    echo "=== РќР°СЃС‚СЂРѕР№РєР° Nginx: $site_name ==="

    if [ ! -f "$source_conf" ]; then
        echo "Nginx РєРѕРЅС„РёРі РЅРµ РЅР°Р№РґРµРЅ: $source_conf"
        return 1
    fi

    sudo cp "$source_conf" "$enabled"

    sudo nginx -t
    sudo systemctl reload nginx

    echo "Nginx СЃР°Р№С‚ $site_name РЅР°СЃС‚СЂРѕРµРЅ."
}

setup_nginx() {
    setup_nginx_site "$@"
}

download_deploy_files() {
    local base="${DEPLOY_FILES_BASE:-https://raw.githubusercontent.com/lordcod/fincubes-contrib/main/.deploy/files}"
    local files_dir="/tmp/fincubes-deploy/files"

    mkdir -p "$files_dir/systemd" "$files_dir/nginx"

    curl -fsSL "$base/systemd/$SERVICE" -o "$files_dir/systemd/$SERVICE"
    curl -fsSL "$base/nginx/$NGINX" -o "$files_dir/nginx/$NGINX"

    FILES="$files_dir"
}

install_nginx() {
    sudo apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring

    curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

    gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
https://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
        | sudo tee /etc/apt/sources.list.d/nginx.list

    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
https://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" \
        | sudo tee /etc/apt/sources.list.d/nginx.list

    echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
        | sudo tee /etc/apt/preferences.d/99nginx

    sudo apt update
    sudo apt install -y nginx
}

install_certbot() {
    ensure_pkg snapd
    sudo snap install --classic certbot

    if [ ! -L /usr/bin/certbot ]; then
        sudo ln -s /snap/bin/certbot /usr/bin/certbot
    fi
}

install_doppler() {
    if command -v doppler >/dev/null 2>&1; then
        return 0
    fi

    curl -Ls https://cli.doppler.com/install.sh | sudo sh
}

setup_doppler() {
    if [ -f "doppler.yaml" ] || [ -f ".doppler.yaml" ]; then
        return 0
    fi

    echo "Running doppler setup (interactive)."
    doppler setup
}


PROJECT="$HOME/fincubes-admin"
REPO="git@github.com:lordcod/fincubes-admin.git"

SERVICE="fincubes-admin.service"
NGINX="admin.fincubes.ru.conf"
NODE_VERSION="lts/*"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES="$BASE_DIR/files"

install_nginx
install_certbot

ensure_github_ssh
sync_repo "$REPO" "$PROJECT"

setup_node "$NODE_VERSION"


cd "$PROJECT"
install_doppler
setup_doppler
npm ci
doppler run -- npm run build

download_deploy_files
setup_systemd \
    "$SERVICE" \
    "$FILES/systemd/$SERVICE"

setup_nginx \
    "$NGINX" \
    "$FILES/nginx/$NGINX"
