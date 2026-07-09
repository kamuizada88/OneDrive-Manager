#!/usr/bin/env bash
# menu.sh - Menu interativo com whiptail
# Requer: colors.sh, todas as libs

show_menu() {
    while true; do
        local choice
        choice=$(whiptail --title "OneDrive Manager" --menu \
            "Escolha uma opção:" 22 70 12 \
            "1"  "Instalar / Configurar" \
            "2"  "Atualizar cliente OneDrive" \
            "3"  "Sincronizar agora (verbose)" \
            "4"  "Ver status do serviço" \
            "5"  "Ver logs (journalctl)" \
            "6"  "Abrir pasta OneDrive" \
            "7"  "Reconfigurar (backup automático)" \
            "8"  "Desinstalar" \
            "9"  "Gerar diagnóstico (suporte)" \
            "10" "Sair" \
            3>&1 1>&2 2>&3) || break

        case "$choice" in
            1)  bash "$SCRIPT_DIR/install.sh" ;;
            2)  bash "$SCRIPT_DIR/update.sh" ;;
            3)  onedrive --synchronize --verbose ;;
            4)  status_systemd ;;
            5)  journalctl --user -u onedrive -n 100 --no-pager ;;
            6)  xdg-open "${ONEDRIVE_SYNC_DIR:-$HOME/OneDrive}" & ;;
            7)  backup_file "$HOME/.config/onedrive/config" >/dev/null
                configure_onedrive
                ;;
            8)  bash "$SCRIPT_DIR/uninstall.sh" ;;
            9)  generate_diagnostics ;;
            10) break ;;
            *)  print_warn "Opção inválida." ;;
        esac

        # Pausa para ler saída antes de voltar ao menu
        if [[ "$choice" != "10" ]]; then
            read -r -p "Pressione ENTER para voltar ao menu..."
        fi
    done
    print_info "Saindo do OneDrive Manager."
}