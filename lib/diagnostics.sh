#!/usr/bin/env bash
# diagnostics.sh - Gera relatório de diagnóstico para suporte
# Requer: colors.sh, detect.sh

# -------------------------------------------------------------------
# generate_diagnostics - Coleta info do ambiente + config + logs
# Saída: /tmp/onedrive-manager-diag-YYYYMMDD-HHMMSS.txt
# -------------------------------------------------------------------
generate_diagnostics() {
    local out
    out="/tmp/onedrive-manager-diag-$(date +%Y%m%d-%H%M%S).txt"

    print_info "Gerando diagnóstico em $out ..."

    {
        echo "======================================================"
        echo " OneDrive Manager - Relatório de Diagnóstico"
        echo " Gerado em: $(date '+%Y-%m-%d %H:%M:%S %Z')"
        echo " Host: $(hostname)"
        echo " Usuário: $USER"
        echo "======================================================"
        echo ""

        echo "----- SISTEMA -----"
        if command -v detect_distro &>/dev/null; then
            detect_distro >/dev/null 2>&1
            echo "Distro: $DISTRO_NAME $DISTRO_VERSION_ID (id=$DISTRO_ID, like=$DISTRO_LIKE)"
        else
            cat /etc/os-release 2>/dev/null
        fi
        echo "Kernel: $(uname -r)"
        echo "Arquitetura: $(uname -m)"
        echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
        echo ""

        echo "----- ONEDRIVE - VERSÃO -----"
        if command -v onedrive &>/dev/null; then
            onedrive --version 2>&1
        else
            echo "onedrive NÃO instalado."
        fi
        echo ""

        echo "----- ONEDRIVE - CONFIG -----"
        if [[ -f "$HOME/.config/onedrive/config" ]]; then
            echo "Arquivo: $HOME/.config/onedrive/config"
            # Oculta refresh_token e access_token (sensíveis)
            sed -E 's/(refresh_token|access_token)\s*=.*/\1 = <REDACTED>/' \
                "$HOME/.config/onedrive/config"
        else
            echo "Config não encontrada."
        fi
        echo ""

        echo "----- SYNC-LIST -----"
        if [[ -f "$HOME/.config/onedrive/sync_list" ]]; then
            grep -v '^\s*#' "$HOME/.config/onedrive/sync_list" | grep -v '^\s*$' || echo "(vazio - sincroniza tudo)"
        else
            echo "sync_list não encontrada."
        fi
        echo ""

        echo "----- SERVIÇO SYSTEMD -----"
        systemctl --user status onedrive.service --no-pager 2>&1 | head -20
        echo ""
        echo "Linger habilitado? $(loginctl show-user "$USER" 2>/dev/null | grep Linger || echo 'N/A')"
        echo ""

        echo "----- ÚLTIMAS 30 LINHAS DO LOG (journal) -----"
        journalctl --user -u onedrive --no-pager -n 30 2>&1
        echo ""

        echo "----- ESPAÇO EM DISCO -----"
        df -h "$HOME" "$HOME/OneDrive" 2>/dev/null | head -5
        echo ""

        echo "----- PASTA DE SYNC -----"
        local sync_dir="${ONEDRIVE_SYNC_DIR:-$HOME/OneDrive}"
        if [[ -d "$sync_dir" ]]; then
            echo "Path: $sync_dir"
            echo "Itens: $(find "$sync_dir" -maxdepth 1 -mindepth 1 | wc -l)"
            echo "Tamanho: $(du -sh "$sync_dir" 2>/dev/null | cut -f1)"
        else
            echo "Pasta $sync_dir não existe."
        fi
        echo ""

        echo "----- CONECTIVIDADE -----"
        for host in download.opensuse.org graph.microsoft.com login.microsoftonline.com; do
            if curl -fsS --max-time 5 --head "https://$host" >/dev/null 2>&1; then
                echo "✅ $host"
            else
                echo "❌ $host (falha HTTPS)"
            fi
        done
        echo ""

        echo "----- REPOSITÓRIO APT -----"
        grep -r "onedrive" /etc/apt/sources.list.d/ 2>/dev/null || echo "(nenhum repo onedrive configurado)"
        echo ""

        echo "----- ALIASES CONFIGURADOS -----"
        grep -A1 "BEGIN OneDrive Manager Aliases" "$HOME/.bashrc" 2>/dev/null | head -15 || echo "(não configurados)"
        echo ""

        echo "======================================================"
        echo " FIM DO RELATÓRIO"
        echo "======================================================"
    } > "$out" 2>&1

    print_success "Diagnóstico salvo em: $out"
    print_info "Envie este arquivo ao suporte para análise."

    # Se whiptail estiver disponível, mostra o path pro usuário
    if command -v whiptail &>/dev/null; then
        whiptail --title "Diagnóstico gerado" \
            --msgbox "Relatório salvo em:\n\n$out\n\nEnvie este arquivo para o suporte." \
            12 70
    fi

    echo "$out"
}