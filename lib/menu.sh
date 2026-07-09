#!/usr/bin/env bash
# menu.sh - Menu interativo com whiptail

show_menu() {
    while true; do
        CHOICE=$(whiptail --title "OneDrive Manager" --menu \
            "Escolha uma opção:" 20 70 10 \
            "1" "Instalar / Configurar" \
            "2" "Atualizar" \
            "3" "Sincronizar agora" \
            "4" "Ver status do serviço" \
            "5" "Ver logs" \
            "6" "Abrir pasta OneDrive" \
            "7" "Reconfigurar (backup automático)" \
            "8" "Desinstalar" \
            "9" "Sair" \
            3>&1 1>&2 2>&3)

        case "$CHOICE" in
            1)
                install_onedrive
                configure_onedrive
                configure_systemd
                add_bookmark
                add_aliases
                check_auth || print_info "Execute 'onedrive' para autenticar."
                print_success "Instalação concluída."
                ;;
            2)
                "$SCRIPT_DIR/update.sh"
                ;;
            3)
                onedrive -s
                ;;
            4)
                systemctl --user status onedrive
                ;;
            5)
                journalctl --user -u onedrive -f
                ;;
            6)
                nautilus ~/OneDrive
                ;;
            7)
                configure_onedrive
                configure_systemd
                print_success "Reconfiguração concluída."
                ;;
            8)
                "$SCRIPT_DIR/uninstall.sh"
                ;;
            9)
                exit 0
                ;;
            *)
                exit 0
                ;;
        esac
        read -p "Pressione Enter para continuar..."
    done
}
