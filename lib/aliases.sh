#!/usr/bin/env bash
# aliases.sh - Aliases para facilitar o uso do OneDrive

add_aliases() {
    local bashrc="$HOME/.bashrc"
    local alias_block="# Aliases do OneDrive Manager"
    local aliases=(
        "alias onedrive-status='systemctl --user status onedrive'"
        "alias onedrive-sync='onedrive -s'"
        "alias onedrive-resync='onedrive --resync'"
        "alias onedrive-start='systemctl --user start onedrive'"
        "alias onedrive-stop='systemctl --user stop onedrive'"
        "alias onedrive-restart='systemctl --user restart onedrive'"
        "alias onedrive-log='journalctl --user -u onedrive -f'"
        "alias onedrive-folder='nautilus ~/OneDrive'"
        "alias onedrive-update='$SCRIPT_DIR/update.sh'"
    )

    if grep -q "$alias_block" "$bashrc"; then
        print_info "Aliases já configurados."
        return
    fi

    echo "" >> "$bashrc"
    echo "$alias_block" >> "$bashrc"
    for alias in "${aliases[@]}"; do
        echo "$alias" >> "$bashrc"
    done

    print_success "Aliases adicionados ao ~/.bashrc"
}

remove_aliases() {
    local bashrc="$HOME/.bashrc"
    if [[ -f "$bashrc" ]]; then
        sed -i '/# Aliases do OneDrive Manager/,+12d' "$bashrc"
        print_info "Aliases removidos."
    fi
}
