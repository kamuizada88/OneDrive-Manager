#!/usr/bin/env bash
# install.sh - Instalação do OneDrive compilando a partir do GitHub oficial

install_onedrive() {
    print_info "Instalando OneDrive a partir do código-fonte oficial (GitHub)..."

    # 1. Instala TODAS as dependências necessárias
    print_info "Instalando dependências de compilação e bibliotecas..."
    sudo apt update
    sudo apt install -y \
        git \
        build-essential \
        ldc \
        libcurl4-openssl-dev \
        libsqlite3-dev \
        pkg-config \
        libdbus-1-dev \
        libnotify-dev

    # 2. Verifica compilador
    if ! command -v ldc2 &>/dev/null; then
        print_error "Compilador LDC não instalado. Abortando."
        return 1
    fi
    print_success "Compilador: $(ldc2 --version | head -1)"

    # 3. Clona ou atualiza o repositório
    local SRC_DIR="$HOME/onedrive_src"
    if [[ -d "$SRC_DIR" ]]; then
        cd "$SRC_DIR" && git pull
    else
        git clone https://github.com/abraunegg/onedrive.git "$SRC_DIR"
        cd "$SRC_DIR"
    fi

    # 4. Força uso do LDC
    export DC=ldc2

    # 5. Compila e instala
    print_info "Compilando (isso pode levar alguns minutos)..."
    ./configure
    make clean
    make
    sudo make install

    # 6. Verifica instalação
    if command -v onedrive &>/dev/null; then
        print_success "Instalado: $(onedrive --version 2>/dev/null | head -1)"
    else
        print_error "Falha na instalação."
        return 1
    fi

    # 7. Gera configuração padrão
    mkdir -p "$HOME/.config/onedrive"
    if [[ ! -f "$HOME/.config/onedrive/config" ]]; then
        onedrive --print-default-config > "$HOME/.config/onedrive/config"
        print_info "Configuração padrão criada."
    fi

    print_success "OneDrive instalado com sucesso!"
}