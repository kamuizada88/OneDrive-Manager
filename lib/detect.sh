#!/usr/bin/env bash
# detect.sh - Detecção e validação de distribuição
# Requer: colors.sh

# Variáveis exportadas após detecção bem-sucedida:
#   DISTRO_ID, DISTRO_LIKE, DISTRO_NAME, DISTRO_VERSION_ID
#   DISTRO_CODENAME, DISTRO_FAMILY, DISTRO_UBUNTU_CODENAME

# Distros oficialmente suportadas (whitelist)
readonly SUPPORTED_DISTROS=(zorin ubuntu linuxmint pop elementary raspbian)

# -------------------------------------------------------------------
# detect_distro - Lê /etc/os-release e popula variáveis globais
# -------------------------------------------------------------------
detect_distro() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Arquivo /etc/os-release não encontrado. Distro não suportada."
        return 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    export DISTRO_ID="${ID:-unknown}"
    export DISTRO_LIKE="${ID_LIKE:-}"
    export DISTRO_NAME="${NAME:-Unknown}"
   