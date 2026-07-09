#!/usr/bin/env bash
# aliases.sh - Aliases para facilitar o uso do OneDrive Manager
# Requer: colors.sh

# Marcadores idempotentes - imunes a mudanças no número de aliases
readonly ALIAS_MARK_BEGIN="# BEGIN OneDrive Manager Aliases"
readonly ALIAS_MARK_END="# END OneDrive Manager Aliases"

# -------------------------------------------------------------------
# add_aliases - Insere bloco de aliases no ~/.bashrc de forma idempotente
# -------------------------------------------------------------------
add_aliases() {
    local bashrc="$HOME/.bashrc"
    local script_dir="${SCRIPT_DIR:-$HOME/.local/share/onedrive-manager}"

    touch "$bashrc"

    # Se já existe o bloco, remove antes de reinserir (permite atualizar)
    if grep -Fq "$ALIAS_MARK_BEGIN" "$bashrc"; then
        print_info "Aliases já existem - atualizando..."
        remove_aliases
    fi

    # Garante linha em branco antes do bloco (leitura fica mais limpa)
    if [[ -s "$bashrc" && "$(tail -c1 "$bashrc")" != "" ]]; then
        echo "" >> "$bashrc"
    fi

    {
        echo "$ALIAS_MARK_BEGIN"
        echo "alias onedrive-status='systemctl --user status onedrive'"
        echo "alias onedrive-sync='onedrive --synchronize --verbose'"
        echo "alias onedrive-dryrun='onedrive --synchronize --dry-run --verbose'"
        echo "alias onedrive-resync='onedrive --resync'"
        echo "alias onedrive-start='systemctl --user start onedrive'"
        echo "alias onedrive-stop='systemctl --user stop onedrive'"
        echo "alias onedrive-restart='systemctl --user restart onedrive'"
        echo "alias onedrive-log='journalctl --user -u onedrive -f'"
        echo "alias onedrive-folder='xdg-open \"\$HOME/OneDrive\"'"
        echo "alias onedrive-update='$script_dir/update.sh'"
        echo "alias onedrive-manager='$script_dir/install.sh'"
        echo "$ALIAS_MARK_END"
    } >> "$bashrc"

    print_success "Aliases adicionados ao $bashrc"
    print_info "Rode 'source ~/.bashrc' ou abra um novo terminal para carregar."
}

# -------------------------------------------------------------------
# remove_aliases - Remove bloco de aliases usando os marcadores
# Imune a add/remove de novos aliases no futuro
# -------------------------------------------------------------------
remove_aliases() {
    local bashrc="$HOME/.bashrc"

    if [[ ! -f "$bashrc" ]]; then
        return 0
    fi

    if ! grep -Fq "$ALIAS_MARK