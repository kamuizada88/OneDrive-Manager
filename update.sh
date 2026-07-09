#!/usr/bin/env bash
# update.sh - Atualiza OneDrive e o gerenciador

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/functions.sh"
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/checks.sh"
source "$SCRIPT_DIR/lib/install.sh"
source "$SCRIPT_DIR/lib/configure.sh"

print_info "Atualizando OneDrive Manager e o cliente..."

# Atualiza lista de pacotes
sudo apt update

# Atualiza o pacote onedrive (se instalado)
if command -v onedrive &>/dev/null; then
    sudo apt install --only-upgrade -y onedrive
else
    print_warn "OneDrive não está instalado. Execute ./install.sh primeiro."
fi

# Atualiza as configurações (sem sobrescrever sync_dir)
configure_onedrive

# Reinicia o serviço
systemctl --user daemon-reload
systemctl --user restart onedrive

print_success "Atualização concluída."