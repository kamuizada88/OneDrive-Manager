#!/usr/bin/env bash
# functions.sh - Funções utilitárias genéricas

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
        cp "$file" "$backup"
        print_info "Backup criado: $backup"
    fi
}

append_unique() {
    local file="$1"
    local line="$2"
    if ! grep -Fxq "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
    fi
}

is_installed() {
    command -v "$1" &>/dev/null
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local yn
    read -p "$prompt (s/N) " yn
    [[ "$yn" =~ ^[Ss]$ ]] && return 0 || return 1
}