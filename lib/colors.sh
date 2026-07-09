#!/usr/bin/env bash
# colors.sh - Definição de cores para mensagens

export NC='\033[0m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'

print_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success(){ echo -e "${GREEN}[ OK ]${NC} $1"; }
print_warn()  { echo -e "${YELLOW}[WARN]${NC} $1" >&2; }
print_error() { echo -e "${RED}[ERRO]${NC} $1" >&2; }