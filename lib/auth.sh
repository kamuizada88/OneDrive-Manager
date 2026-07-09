#!/usr/bin/env bash
# auth.sh - Verifica e orienta autenticação

check_auth() {
    local config_dir="$HOME/.config/onedrive"
    local config_file="$config_dir/config"
    if [[ -f "$config_file" ]] && grep -q "refresh_token" "$config_file"; then
        print_success "Autenticação já realizada."
        return 0
    else
        print_warn "Nenhum token de atualização encontrado."
        print_info "Para autenticar, execute 'onedrive' e siga as instruções."
        return 1
    fi
}