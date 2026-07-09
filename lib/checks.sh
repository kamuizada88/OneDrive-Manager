#!/usr/bin/env bash
# checks.sh - Verificações pré-instalação (robusta)
# Requer: colors.sh e detect.sh já carregados via source

# -------------------------------------------------------------------
# check_internet - Testa acesso ao repositório OBS (não ping ICMP)
# -------------------------------------------------------------------
check_internet() {
    local urls=(
        "https://download.opensuse.org/"
        "https://github.com/"
    )
    local ok=0
    for url in "${urls[@]}"; do
        if curl -fsS --max-time 8 --head "$url" >/dev/null 2>&1; then
            ok=1
            break
        fi
    done
    if (( ok == 0 )); then
        print_error "Sem acesso HTTPS aos repositórios (OBS/GitHub)."
        print_error "Verifique proxy corporativo, firewall ou DNS."
        exit 1
    fi
    print_success "Conectividade OK (HTTPS)."
}

# -------------------------------------------------------------------
# check_distro - Detecta E valida se é distro suportada
# -------------------------------------------------------------------
check_distro() {
    if ! detect_distro; then
        exit 1
    fi

    case "$DISTRO_ID" in
        zorin|ubuntu|linuxmint|pop|elementary|raspbian|kali)
            print_success "Distro suportada: $DISTRO_NAME $DISTRO_VERSION_ID"
            return 0
            ;;
        *)
            if [[ "${DISTRO_LIKE:-}" =~ (ubuntu|debian) ]]; then
                print_warn "Distro '$DISTRO_ID' não é oficialmente suportada,"
                print_warn "mas é derivada de Ubuntu/Debian - tentando prosseguir."
                return 0
            fi
            print_error "Distro '$DISTRO_ID' NÃO é suportada."
            print_error "Suportadas: Zorin 17/18, Ubuntu 22.04/24.04 e derivados."
            exit 1
            ;;
    esac
}

# -------------------------------------------------------------------
# check_disk_space - Verifica espaço no $HOME (default 500 MB)
# -------------------------------------------------------------------
check_disk_space() {
    local needed="${1:-500}"   # MB, pode passar como argumento
    local available
    available=$(df -m "$HOME" | awk 'NR==2 {print $4}')

    if [[ -z "$available" ]] || ! [[ "$available" =~ ^[0-9]+$ ]]; then
        print_error "Não foi possível determinar espaço livre em \$HOME."
        exit 1
    fi

    if (( available < needed )); then
        print_error "Espaço em disco insuficiente em \$HOME."
        print_error "Necessário: ${needed} MB | Disponível: ${available} MB"
        exit 1
    fi
    print_success "Espaço em disco OK (${available} MB livres em \$HOME)."
}

# -------------------------------------------------------------------
# check_systemd - Confirma que systemd está presente e ativo
# -------------------------------------------------------------------
check_systemd() {
    if ! command -v systemctl &>/dev/null; then
        print_error "systemd não encontrado (systemctl ausente)."
        exit 1
    fi
    # confirma que o PID 1 é o systemd
    if [[ "$(ps -p 1 -o comm=)" != "systemd" ]]; then
        print_error "Sistema não está usando systemd como init."
        exit 1
    fi
    # verifica se o barramento --user está disponível
    if ! systemctl --user list-units >/dev/null 2>&1; then
        print_warn "Barramento systemd --user não disponível na sessão atual."
        print_warn "O serviço pode não iniciar em ambientes SSH sem loginctl."
    fi
    print_success "systemd disponível."
}

# -------------------------------------------------------------------
# check_root_or_sudo - Garante que temos sudo configurado
# -------------------------------------------------------------------
check_root_or_sudo() {
    if [[ $EUID -eq 0 ]]; then
        print_warn "Executando como root. Recomendado rodar como usuário comum + sudo."
        return 0
    fi
    if ! command -v sudo &>/dev/null; then
        print_error "'sudo' não encontrado e você não é root."
        exit 1
    fi
    # valida credencial (interativo). Timeout curto para não travar.
    if ! sudo -v; then
        print_error "Falha ao validar sudo. Cancele e reexecute quando puder."
        exit 1
    fi
    # mantém o sudo "vivo" enquanto o script roda
    ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
    print_success "sudo validado."
}

# -------------------------------------------------------------------
# check_existing_installation - Detecta instalações anteriores
# -------------------------------------------------------------------
check_existing_installation() {
    if command -v onedrive &>/dev/null; then
        local ver
        ver=$(onedrive --version 2>/dev/null | head -n1)
        print_warn "OneDrive já instalado: $ver"
        print_warn "Use ./update.sh para atualizar ou ./uninstall.sh para remover."
        # não sai - deixa o install.sh decidir se prossegue
        return 1
    fi
    # Detecta versão via snap (comum e problemática, precisa avisar)
    if command -v snap &>/dev/null && snap list 2>/dev/null | grep -q '^onedrive\b'; then
        print_error "Detectado onedrive instalado via Snap (não suportado)."
        print_error "Remova antes: sudo snap remove onedrive"
        exit 1
    fi
    return 0
}

# -------------------------------------------------------------------
# run_all_checks - Roda todas as verificações na ordem correta
# -------------------------------------------------------------------
run_all_checks() {
    print_info "Executando verificações pré-instalação..."
    check_root_or_sudo
    check_distro
    check_internet
    check_systemd
    check_disk_space 500
    check_existing_installation || true
    print_success "Todas as verificações concluídas."
}