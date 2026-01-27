#!/bin/bash
set -e

log() {
    echo
    echo "=== $1 ==="
}

require_file() {
    if [ ! -f "$1" ]; then
        echo "Файл не найден: $1"
        exit 1
    fi
}
