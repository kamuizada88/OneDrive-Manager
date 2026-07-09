#!/usr/bin/env bash
# detect.sh - Detecção de sistema operacional e versão

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO_ID="$ID"
        DISTRO_VERSION_ID="$VERSION_ID"
        DISTRO_NAME="$NAME"
    else
        print_error "Não foi possível detectar a distribuição."
        return 1
    fi

    # Normaliza
    DISTRO_ID=$(echo "$DISTRO_ID" | tr '[:upper:]' '[:lower:]')

    # Mapeia distribuições baseadas em Ubuntu para codinome
    case "$DISTRO_ID" in
        ubuntu)
            case "$DISTRO_VERSION_ID" in
                22.04) UBUNTU_CODENAME="jammy" ;;
                24.04) UBUNTU_CODENAME="noble" ;;
                *)
                    print_error "Versão do Ubuntu não suportada: $DISTRO_VERSION_ID"
                    return 1
                    ;;
            esac
            ;;
        zorin)
            case "$DISTRO_VERSION_ID" in
                17) UBUNTU_CODENAME="jammy" ;;   # Zorin 17 = Ubuntu 22.04
                18) UBUNTU_CODENAME="noble" ;;   # Zorin 18 = Ubuntu 24.04
                *)
                    print_error "Versão do Zorin não suportada: $DISTRO_VERSION_ID"
                    return 1
                    ;;
            esac
            ;;
        linuxmint)
            # Mint 21.x = jammy, Mint 22.x = noble (ajuste conforme necessário)
            case "$DISTRO_VERSION_ID" in
                21*) UBUNTU_CODENAME="jammy" ;;
                22*) UBUNTU_CODENAME="noble" ;;
                *)
                    print_error "Versão do Linux Mint não suportada: $DISTRO_VERSION_ID"
                    return 1
                    ;;
            esac
            ;;
        pop)
            # Pop!_OS 22.04 = jammy
            case "$DISTRO_VERSION_ID" in
                22.04) UBUNTU_CODENAME="jammy" ;;
                *)
                    print_error "Versão do Pop!_OS não suportada: $DISTRO_VERSION_ID"
                    return 1
                    ;;
            esac
            ;;
        *)
            print_error "Distribuição não suportada: $DISTRO_NAME"
            return 1
            ;;
    esac

    print_info "Distro detectada: $DISTRO_NAME $DISTRO_VERSION_ID (base: $UBUNTU_CODENAME)"
    export DISTRO_ID DISTRO_VERSION_ID UBUNTU_CODENAME
}