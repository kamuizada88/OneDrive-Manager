#!/usr/bin/env bash
# configure.sh - Configuração do cliente

configure_onedrive() {
    local config_dir="$HOME/.config/onedrive"
    local config_file="$config_dir/config"
    mkdir -p "$config_dir"

    # Backup se existir
    if [[ -f "$config_file" ]]; then
        backup_file "$config_file"
    fi

    # Cria ou atualiza config
    cat > "$config_file" <<EOF
# Configuração gerada pelo OneDrive Manager
sync_dir = "$HOME/OneDrive"
skip_file = "~*.tmp|~*.log|*.part"
EOF

    # Cria pasta alvo
    mkdir -p "$HOME/OneDrive"

    print_success "Configuração criada em $config_file"
}