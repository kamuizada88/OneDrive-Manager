#!/usr/bin/env bash
# functions.sh - Funções utilitárias genéricas
# Requer: colors.sh (para print_info/warn/error)

# -------------------------------------------------------------------
# backup_file - Cria backup timestamped de um arquivo
# Uso:   backup_file /caminho/do/arquivo
# Saída: /caminho/do/arquivo.bak.YYYYMMDDHHMMSS
# -------------------------------------------------------------------
backup_file() {
    local file="$1"
    if [[ -z "$file" ]]; then
        print_error "backup_file: nenhum arquivo informado."
        return 1
    fi
    if [[ ! -e "$file" ]]; then
        print_warn "backup_file: '$file' não existe, backup ignorado."
        return 0
    fi
    local ts backup
    ts="$(date +%Y%m%d%H%M%S)"
    backup="${file}.bak.${ts}"
    if cp -a -- "$file" "$backup"; then
        print_info "Backup criado: $backup"
        echo "$backup"   # ecoa o path do backup - útil pra chamadas
        return 0
    else
        print_error "Falha ao criar backup de '$file'."
        return 1
    fi
}

# -------------------------------------------------------------------
# append_unique - Adiciona linha ao arquivo se ainda não existir
# Uso:   append_unique /caminho/do/arquivo "linha a inserir"
# Nota:  usa -F (fixed string) sem -x para casar mesmo com whitespace
# -------------------------------------------------------------------
append_unique() {
    local file="$1"
    local line="$2"
    if [[ -z "$file" || -z "$line" ]]; then
        print_error "append_unique: uso incorreto (arquivo e linha obrigatórios)."
        return 1
    fi
    # Garante que o arquivo existe
    mkdir -p "$(dirname "$file")" 2>/dev/null || true
    touch "$file"
    # Garante quebra de linha ao final antes de anexar (evita concatenar linhas)
    [[ -s "$file" && "$(tail -c1 "$file")" != "" ]] && echo "" >> "$file"
    if ! grep -Fq -- "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        return 0
    fi
    return 0
}

# -------------------------------------------------------------------
# remove_line - Remove linhas que casem com padrão (exato, fixed)
# Uso:   remove_line /caminho/do/arquivo "padrão"
# -------------------------------------------------------------------
remove_line() {
    local file="$1"
    local pattern="$2"
    if [[ ! -f "$file" ]]; then
        return 0
    fi
    # cria backup antes de mexer
    backup_file "$file" >/dev/null
    # sed -i com delimitador | pra não conflitar com / em paths
    local escaped
    escaped="$(printf '%s' "$pattern" | sed -e 's/[]\/$*.^|[]/\\&/g')"
    sed -i "\|${escaped}|d" "$file"
}

# -------------------------------------------------------------------
# is_installed - Verifica se um comando existe no PATH
# Uso:   is_installed onedrive && echo "ok"
# -------------------------------------------------------------------
is_installed() {
    command -v "$1" &>/dev/null
}

# -------------------------------------------------------------------
# is_package_installed - Verifica se pacote APT está instalado
# Uso:   is_package_installed onedrive
# -------------------------------------------------------------------
is_package_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

# -------------------------------------------------------------------
# prompt_yes_no - Pergunta S/N respeitando default
# Uso:   prompt_yes_no "Continuar?" y   -> ENTER = sim
#        prompt_yes_no "Apagar tudo?" n -> ENTER = não (padrão)
# Retorno: 0 = sim, 1 = não
# -------------------------------------------------------------------
prompt_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local hint yn
    case "$default" in
        [Ss]|[Yy]) hint="[S/n]" ;;
        *)         hint="[s/N]" ;;
    esac
    # Se não for terminal interativo, usa o default sem perguntar
    if [[ ! -t 0 ]]; then
        case "$default" in [Ss]|[Yy]) return 0 ;; *) return 1 ;; esac
    fi
    read -r -p "$prompt $hint " yn
    yn="${yn:-$default}"
    case "$yn" in
        [Ss]|[Yy]|[Ss][Ii][Mm]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# -------------------------------------------------------------------
# require_cmd - Aborta se comando não estiver instalado
# Uso:   require_cmd curl git sudo
# -------------------------------------------------------------------
require_cmd() {
    local missing=()
    local cmd
    for cmd in "$@"; do
        if ! is_installed "$cmd"; then
            missing+=("$cmd")
        fi
    done
    if (( ${#missing[@]} > 0 )); then
        print_error "Comando(s) obrigatório(s) ausente(s): ${missing[*]}"
        return 1
    fi
    return 0
}

# -------------------------------------------------------------------
# retry - Executa comando com N tentativas e delay exponencial
# Uso:   retry 3 5 curl -fsSL "$URL" -o "$FILE"
#        (3 tentativas, delay inicial 5s, dobra a cada falha)
# -------------------------------------------------------------------
retry() {
    local max="$1"; shift
    local delay="$1"; shift
    local attempt=1
    until "$@"; do
        if (( attempt >= max )); then
            print_error "Comando falhou após $max tentativas: $*"
            return 1
        fi
        print_warn "Tentativa $attempt falhou. Aguardando ${delay}s..."
        sleep "$delay"
        delay=$(( delay * 2 ))
        attempt=$(( attempt + 1 ))
    done
    return 0
}

# -------------------------------------------------------------------
# ensure_dir - Cria diretório se não existir (com permissões do user)
# -------------------------------------------------------------------
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || { print_error "Falha ao criar '$dir'."; return 1; }
    fi
}

# -------------------------------------------------------------------
# get_ubuntu_codename - Devolve o codinome Ubuntu correspondente ao Zorin
# Usado no install.sh para escolher URL correta do OBS
# -------------------------------------------------------------------
get_ubuntu_codename() {
    # Zorin 17 = jammy (22.04) | Zorin 18 = noble (24.04)
    case "$DISTRO_ID:$DISTRO_VERSION_ID" in
        zorin:17*)          echo "jammy" ;;
        zorin:18*)          echo "noble" ;;
        ubuntu:22.04*)      echo "jammy" ;;
        ubuntu:24.04*)      echo "noble" ;;
        ubuntu:24.10*)      echo "oracular" ;;
        ubuntu:26.04*)      echo "resolute" ;;   # placeholder
        linuxmint:21*)      echo "jammy" ;;
        linuxmint:22*)      echo "noble" ;;
        pop:22.04*)         echo "jammy" ;;
        pop:24.04*)         echo "noble" ;;
        *)
            # fallback: tenta ler o UBUNTU_CODENAME do /etc/os-release
            if [[ -n "${UBUNTU_CODENAME:-}" ]]; then
                echo "$UBUNTU_CODENAME"
            else
                echo "jammy"   # default conservador
            fi
            ;;
    esac
}