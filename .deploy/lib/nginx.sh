#!/bin/bash
set -e

setup_nginx_site() {
    local site_name="$1"
    local source_conf="$2"
    local enabled="/etc/nginx/conf.d/$site_name"

    echo "=== Настройка Nginx: $site_name ==="

    if [ ! -f "$source_conf" ]; then
        echo "Nginx конфиг не найден: $source_conf"
        return 1
    fi

    sudo cp "$source_conf" "$enabled"

    sudo nginx -t
    sudo systemctl reload nginx

    echo "Nginx сайт $site_name настроен."
}
