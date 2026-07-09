#!/usr/bin/env bash
# systemd.sh - Configuração do serviço systemd user do OneDrive
# Requer: colors.sh (print_*)

# -------------------------------------------------------------------
# configure_systemd - Cria drop-in override e habilita o serviço user
# -------------------------------------------------------------------
configure_systemd() {
    local override_dir="$HOME/.config/systemd/user/onedrive.service.d"
    local override_file="$override_dir/override.conf"

    print_info "Configurando serviço systemd (user) do OneDrive..."

    # 1) Cria o drop-in override (não sobrescreve o unit oficial)
    mkdir -p "$override_dir"
    cat > "$override_file" <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/onedrive --monitor
Restart=on-failure
RestartSec=10
EOF
    print_success "Override criado: $override_file"

    # 2) Recarrega o daemon do usuário para ler o override
    if ! systemctl --user daemon-reload; then
        print_warn "Falha em 'systemctl --user daemon-reload' (sessão sem D-Bus?)."
        print_warn "Rode manualmente após login gráfico."
    fi

    # 3) Habilita linger - essencial para o serviço rodar sem sessão ativa
    #    Sem isso, ao dar logout o onedrive PARA. Notebook suspenso = sem sync.
    if ! loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
        print_info "Habilitando linger para $USER (permite serviço rodar sem login)..."
        if sudo loginctl enable-linger "$USER"; then
            print_success "Linger habilitado."
        else
            print_warn "Falha ao habilitar linger. O serviço só rodará com sessão ativa."
        fi
    else
        print_info "Linger já habilitado para $USER."
    fi

    # 4) Habilita e inicia o serviço
    if systemctl --user enable --now onedrive.service; then
        print_success "Serviço onedrive habilitado e iniciado."
    else
        print_warn "Falha ao habilitar/iniciar. Verifique com: systemctl --user status onedrive"
    fi
}

# -------------------------------------------------------------------
# remove_systemd - Desabilita serviço e remove override
# -------------------------------------------------------------------
remove_systemd() {
    local override_dir="$HOME/.config/systemd/user/onedrive.service.d"

    print_info "Removendo configuração systemd do OneDrive..."

    systemctl --user disable --now onedrive.service 2>/dev/null || true

    if [[ -d "$override_dir" ]]; then
        rm -rf "$override_dir"
        print_success "Override removido: $override_dir"
    fi

    systemctl --user daemon-reload 2>/dev/null || true

    # Linger fica - não desabilita porque pode estar em uso por outro serviço
    print_info "Linger mantido (pode ser desabilitado manualmente com: sudo loginctl disable-linger $USER)"
}

# -------------------------------------------------------------------
# status_systemd - Mostra status resumido do serviço (para o menu)
# -------------------------------------------------------------------
status_systemd() {
    systemctl --user status onedrive.service --no-pager -l
}
``