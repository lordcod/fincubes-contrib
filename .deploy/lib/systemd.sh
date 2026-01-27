#!/bin/bash
set -e

setup_systemd_service() {
    local service_name="$1"
    local service_file="$2"

    echo "=== Настройка systemd: $service_name ==="

    if [ ! -f "$service_file" ]; then
        echo "Systemd файл не найден: $service_file"
        return 1
    fi

    sudo cp "$service_file" "/etc/systemd/system/$service_name"
    sudo systemctl daemon-reload
    sudo systemctl enable "$service_name"

    echo "Systemd сервис $service_name установлен."
}
