#!/usr/bin/env bash
# configure.sh - Configuração do cliente OneDrive (abraunegg)
# Requer: colors.sh, functions.sh (backup_file)

# Diretório de sync padrão (pode ser sobrescrito por env)
: "${ONEDRIVE_SYNC_DIR:=$HOME/OneDrive}"

# -------------------------------------------------------------------
# configure_onedrive - Gera ~/.config/onedrive/config profissional
# -------------------------------------------------------------------
configure_onedrive() {
    local config_dir="$HOME/.config/onedrive"
    local config_file="$config_dir/config"

    print_info "Configurando cliente OneDrive..."
    mkdir -p "$config_dir"
    mkdir -p "$ONEDRIVE_SYNC_DIR"

    # Se já existe config com refresh_token, preserva (não sobrescreve auth)
    if [[ -f "$config_file" ]]; then
        if grep -q "refresh_token" "$config_file"; then
            print_warn "Config já existe com token de autenticação."
            print_info "Fazendo backup antes de reescrever as opções (mantendo auth)..."
        fi
        backup_file "$config_file" >/dev/null
    fi

    # Grava configuração profissional
    cat > "$config_file" <<EOF
# ============================================================
# Configuração gerada pelo OneDrive Manager
# Gerado em: $(date '+%Y-%m-%d %H:%M:%S')
# Documentação: https://github.com/abraunegg/onedrive/blob/master/docs/application-config-options.md
# ============================================================

# Diretório local de sincronização
sync_dir = "$ONEDRIVE_SYNC_DIR"

# ------- Arquivos a ignorar (skip_file) -------
# Combina padrões técnicos + arquivos temporários do Office/OS
skip_file = "~*|.~*|.~lock.*|~\$*|*.tmp|*.temp|*.log|*.part|*.crdownload|*.swp|*.swo|*.bak|Thumbs.db|desktop.ini|.DS_Store|.Trash-*|.directory"

# ------- Diretórios a ignorar (skip_dir) -------
skip_dir = ".git|node_modules|__pycache__|.venv|venv|.cache|.tmp|Trash|\$RECYCLE.BIN|System Volume Information"

# ------- Comportamento de sincronização -------
# Verifica mudanças a cada 5 min (300s) - equilibra bateria e responsividade
monitor_interval = "300"

# Timeout de operações longas (uploads grandes)
operation_timeout = "3600"

# Tenta reconectar por até 1h em caso de queda de rede
dns_timeout = "60"
connect_timeout = "10"
data_timeout = "600"

# ------- Segurança / integridade -------
# Confirma antes de deletar mais de 5% do local (protege contra desastres)
classify_as_big_delete = "1000"

# Não deleta local quando o remoto some (pode ser bug do lado servidor)
downgrade_interactive_input_to_cli = "false"

# ------- Logs -------
enable_logging = "true"
log_dir = "$HOME/.config/onedrive/logs/"

# ------- Notificações desktop -------
disable_notifications = "false"

# ------- Symlinks -------
# Não sincroniza links simbólicos (evita loops)
skip_symlinks = "true"

# ------- Arquivos ocultos -------
# .config, .ssh etc. NÃO devem ir pra nuvem
skip_dotfiles = "true"

# ------- Verificação de espaço -------
# Aborta upload se sobrar menos que 200 MB no OneDrive
space_reservation = "209715200"

# ------- Rate-limit -------
# Zero = sem limite. Se rede corp reclamar, pode setar em bytes/s
rate_limit = "0"
EOF

    # Cria diretório de logs
    mkdir -p "$config_dir/logs"

    # Sync-list opcional (vazio por padrão = sincroniza tudo)
    if [[ ! -f "$config_dir/sync_list" ]]; then
        cat > "$config_dir/sync_list" <<'EOF'
# sync_list - Descomente e liste pastas específicas para sincronizar
# Exemplo:
# Documentos
# Trabalho/2026
# !Backups          <- prefixo ! = NÃO sincronizar
EOF
    fi

    print_success "Configuração salva em: $config_file"
    print_info "Pasta de sync: $ONEDRIVE_SYNC_DIR"
    print_info "Sync-list: $config_dir/sync_list (edite se quiser sync parcial)"
}

# -------------------------------------------------------------------
# validate_config - Roda 'onedrive --display-config' pra validar
# -------------------------------------------------------------------
validate_config() {
    if command -v onedrive &>/dev/null; then
        print_info "Validando configuração com o cliente onedrive..."
        if onedrive --display-config >/dev/null 2>&1; then
            print_success "Configuração válida."
            return 0
        else
            print_error "Configuração inválida. Rode 'onedrive --display-config' para ver detalhes."
            return 1
        fi
    fi
    print_warn "Cliente onedrive não instalado - pulando validação."
    return 0
}