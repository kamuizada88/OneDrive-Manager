#!/usr/bin/env bash
# uninstall.sh - Remove completamente o OneDrive e suas configurações

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/functions.sh"
source "$SCRIPT_DIR/lib/aliases.sh"
source "$SCRIPT_DIR/lib/bookmarks.sh"

print_warn "Isso removerá o OneDrive, configurações e aliases."
read -p "Deseja manter a pasta ~/OneDrive? (s/N) " keep_folder

# Remove o pacote
if command -v onedrive &>/dev/null; then
    sudo apt remove -y onedrive
fi

# Remove repositório e chave
sudo rm -f /etc/apt/sources.list.d/onedrive.list
sudo rm -f /etc/apt/keyrings/onedrive.gpg
sudo apt update

# Remove override do systemd
rm -rf "$HOME/.config/systemd/user/onedrive.service.d"
systemctl --user daemon-reload

# Remove aliases
remove_aliases

# Remove bookmark
remove_bookmark

# Remove configuração
rm -rf "$HOME/.config/onedrive"

# Remove pasta de dados (opcional)
if [[ "$keep_folder" != "s" && "$keep_folder" != "S" ]]; then
    rm -rf "$HOME/OneDrive"
    print_info "Pasta ~/OneDrive removida."
else
    print_info "Pasta ~/OneDrive mantida."
fi

print_success "Desinstalação concluída."