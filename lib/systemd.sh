#!/usr/bin/env bash
# systemd.sh - Configuração do serviço systemd user

configure_systemd() {
    local override_dir="$HOME/.config/systemd/user/onedrive.service.d"
    local override_file="$override_dir/override.conf"

    mkdir -p "$override_dir"

    # Cria override com --monitor
    cat > "$override_file" <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/onedrive --monitor
EOF

    systemctl --user daemon-reload
    systemctl --user enable onedrive
    systemctl --user restart onedrive

    print_success "Serviço systemd configurado com --monitor"
}