#!/usr/bin/env bash
# colors.sh - Definição de cores para mensagens (robusta)

# Usa $'...' (ANSI-C quoting) -> as sequências já vêm INTERPRETADAS.
# Funciona com echo, printf e mesmo se algo for chamado via sh/dash.
export NC=$'\033[0m'
export RED=$'\033[0;31m'
export GREEN=$'\033[0;32m'
export YELLOW=$'\033[0;33m'
export BLUE=$'\033[0;34m'
export CYAN=$'\033[0;36m'

# Desabilita cores automaticamente quando NÃO estiver em TTY
# (ex.: quando a saída for redirecionada para arquivo de log via tee).
if [[ ! -t 1 ]] || [[ "${NO_COLOR:-}" == "1" ]]; then
    NC='' ; RED='' ; GREEN='' ; YELLOW='' ; BLUE='' ; CYAN=''
fi

# Log opcional - se LOG_FILE estiver setado, grava sem os códigos ANSI.
_log_ts() { date '+%Y-%m-%d %H:%M:%S'; }

_write_log() {
    # $1 = nível já formatado sem cor, $2 = mensagem
    if [[ -n "${LOG_FILE:-}" ]]; then
        mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
        printf '%s %s %s\n' "$(_log_ts)" "$1" "$2" >> "$LOG_FILE"
    fi
}

print_info()    { printf '%b[INFO]%b %s %s\n'  "$BLUE"   "$NC" "$(_log_ts)" "$1";        _write_log "[INFO]"  "$1"; }
print_success() { printf '%b[ OK ]%b %s %s\n'  "$GREEN"  "$NC" "$(_log_ts)" "$1";        _write_log "[ OK ]"  "$1"; }
print_warn()    { printf '%b[WARN]%b %s %s\n'  "$YELLOW" "$NC" "$(_log_ts)" "$1" >&2;    _write_log "[WARN]"  "$1"; }
print_error()   { printf '%b[ERRO]%b %s %s\n'  "$RED"    "$NC" "$(_log_ts)" "$1" >&2;    _write_log "[ERRO]"  "$1"; }