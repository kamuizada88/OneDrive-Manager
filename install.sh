#!/usr/bin/env bash
# install.sh - Instalador principal do OneDrive Manager

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/colors.sh
source "$SCRIPT_DIR/lib/colors.sh"
# shellcheck source=lib/functions.sh
source "$SCRIPT_DIR/lib/functions.sh"
# shellcheck source=lib/detect.sh
source "$SCRIPT_DIR/lib/detect.sh"
# shellcheck source=lib/checks.sh
source "$SCRIPT_DIR/lib/checks.sh"
# shellcheck source=lib/install.sh
source "$SCRIPT_DIR/lib/install.sh"
# shellcheck source=lib/configure.sh
source "$SCRIPT_DIR/lib/configure.sh"
# shellcheck source=lib/systemd.sh
source "$SCRIPT_DIR/lib/systemd.sh"
# shellcheck source=lib/bookmarks.sh
source "$SCRIPT_DIR/lib/bookmarks.sh"
# shellcheck source=lib/aliases.sh
source "$SCRIPT_DIR/lib/aliases.sh"
# shellcheck source=lib/auth.sh
source "$SCRIPT_DIR/lib/auth.sh"
# shellcheck source=lib/menu.sh
source "$SCRIPT_DIR/lib/menu.sh"

main() {
    clear
    cat "$SCRIPT_DIR/assets/logo.txt"
    echo
    print_info "OneDrive Manager - Instalação e Configuração"
    echo

    # Verificações iniciais
    check_internet
    check_distro
    check_disk_space
    check_systemd

    # Menu principal (whiptail)
    show_menu
}

main "$@"