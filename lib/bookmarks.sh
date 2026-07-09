#!/usr/bin/env bash
# bookmarks.sh - Adiciona/remove pasta OneDrive aos favoritos do file manager
# Requer: colors.sh (print_info/success/warn/error)
# Suporta: Nautilus GTK-3, Nautilus GTK-4, Nemo (Cinnamon)

# Pasta padrão sincronizada pelo onedrive
: "${ONEDRIVE_SYNC_DIR:=$HOME/OneDrive}"
# Label que aparece na sidebar (pode conter espaços)
: "${ONEDRIVE_BOOKMARK_LABEL:=OneDrive}"

# Lista de arquivos de bookmarks que vamos manter em sincronia
_bookmark_files() {
    printf '%s\n' \
        "$HOME/.config/gtk-3.0/bookmarks" \
        "$HOME/.config/gtk-4.0/bookmarks"
}

# -------------------------------------------------------------------
# _bookmark_line - Monta a linha do bookmark em formato GTK
# Formato: file:///caminho/absoluto Label opcional
# -------------------------------------------------------------------
_bookmark_line() {
    # URI-encode do path (espaços viram %20)
    local path_encoded
    path_encoded="$(printf '%s' "$ONEDRIVE_SYNC_DIR" | \
        sed -e 's/ /%20/g' -e 's/#/%23/g' -e 's/?/%3F/g')"
    printf 'file://%s %s\n' "$path_encoded" "$ONEDRIVE_BOOKMARK_LABEL"
}

# -------------------------------------------------------------------
# add_bookmark - Adiciona OneDrive à sidebar (Nautilus GTK-3/GTK-4)
# -------------------------------------------------------------------
add_bookmark() {
    local line
    line="$(_bookmark_line)"
    local added=0
    local file

    while IFS= read -r file; do
        mkdir -p "$(dirname "$file")" 2>/dev/null || true
        touch "$file"

        # Garante quebra de linha ao final antes de anexar
        if [[ -s "$file" && "$(tail -c1 "$file")" != "" ]]; then
            echo "" >> "$file"
        fi

        # Verifica se já existe uma linha apontando pro SYNC_DIR
        if grep -Fq "file://$ONEDRIVE_SYNC_DIR" "$file" 2>/dev/null; then
            print_info "Favorito já presente em: $file"
            continue
        fi

        if echo "$line" >> "$file"; then
            print_success "Favorito adicionado em: $file"
            added=$((added + 1))
        else
            print_warn "Falha ao gravar em: $file"
        fi
    done < <(_bookmark_files)

    if (( added == 0 )); then
        print_info "Nenhum favorito novo adicionado (já estava presente ou nenhum GTK detectado)."
    fi
    return 0
}

# -------------------------------------------------------------------
# remove_bookmark - Remove entrada do OneDrive da sidebar
# Usa match exato de path pra não apagar OneDrive-Backup etc.
# -------------------------------------------------------------------
remove_bookmark() {
    local sync_dir_encoded
    sync_dir_encoded="$(printf '%s' "$ONEDRIVE_SYNC_DIR" | sed 's/ /%20/g')"
    local removed=0
    local file

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue
        # Remove apenas linhas cuja URI seja EXATAMENTE $sync_dir
        # (seguida de espaço + label, ou fim de linha)
        local pattern="^file://${sync_dir_encoded}\([[:space:]].*\)\?$"
        if grep -q "$pattern" "$file" 2>/dev/null; then
            # backup antes de mexer
            cp -a "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)"
            sed -i "\|$pattern|d" "$file"
            print_success "Favorito removido de: $file"
            removed=$((removed + 1))
        fi
    done < <(_bookmark_files)

    if (( removed == 0 )); then
        print_info "Nenhum favorito do OneDrive encontrado para remover."
    fi
    return 0
}

# -------------------------------------------------------------------
# refresh_nautilus - Força o Nautilus a recarregar (sem matar processo)
# Útil chamar após add/remove pra usuário ver a mudança na hora
# -------------------------------------------------------------------
refresh_nautilus() {
    if command -v nautilus &>/dev/null && pgrep -x nautilus >/dev/null 2>&1; then
        # send-signal ou reload - Nautilus 43+ suporta --quit e reabre
        nautilus -q >/dev/null 2>&1 || true
        print_info "Nautilus reiniciado para aplicar bookmarks."
    fi
}