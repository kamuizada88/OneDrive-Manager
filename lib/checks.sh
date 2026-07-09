#!/usr/bin/env bash
# checks.sh - Verificações pré-instalação

check_internet() {
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        print_error "Sem conexão com a internet."
        exit 1
    fi
}

check_distro() {
    if ! detect_distro; then
        exit 1
    fi
}

check_disk_space() {
    local needed=100  # MB
    local available
    available=$(df -m "$HOME" | awk 'NR==2 {print $4}')
    if (( available < needed )); then
        print_error "Espaço em disco insuficiente (necessário ${needed}MB)."
        exit 1
    fi
}

check_systemd() {
    if ! command -v systemctl &>/dev/null; then
        print_error "systemd não encontrado."
        exit 1
    fi
}