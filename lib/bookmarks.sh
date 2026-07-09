#!/usr/bin/env bash
# bookmarks.sh - Adiciona/remove pasta aos favoritos do Nautilus

add_bookmark() {
    local bookmarks_file="$HOME/.config/gtk-3.0/bookmarks"
    mkdir -p "$(dirname "$bookmarks_file")"
    touch "$bookmarks_file"

    local entry="file://$HOME/OneDrive"
    if ! grep -Fxq "$entry" "$bookmarks_file"; then
        echo "$entry" >> "$bookmarks_file"
        print_success "Pasta OneDrive adicionada aos favoritos do Nautilus."
    else
        print_info "Favorito já existe."
    fi
}

remove_bookmark() {
    local bookmarks_file="$HOME/.config/gtk-3.0/bookmarks"
    if [[ -f "$bookmarks_file" ]]; then
        sed -i "\|file://$HOME/OneDrive|d" "$bookmarks_file"
        print_info "Favorito removido."
    fi
}