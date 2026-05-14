#!/usr/bin/env bash

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

clear_screen() {
    printf '\033c'
}

check_dependencies() {
    local missing=0

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${COLOR_ERROR:-}Errore: curl non trovato.${COLOR_RESET:-}"
        missing=1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${COLOR_ERROR:-}Errore: jq non trovato.${COLOR_RESET:-}"
        echo -e "${COLOR_INFO:-}Su macOS puoi installarlo con: brew install jq${COLOR_RESET:-}"
        missing=1
    fi

    if ! command -v perl >/dev/null 2>&1; then
        echo -e "${COLOR_ERROR:-}Errore: perl non trovato.${COLOR_RESET:-}"
        missing=1
    fi

    if [[ "$missing" -eq 1 ]]; then
        exit 1
    fi
}

ensure_project_dirs() {
    mkdir -p "$BASE_DIR/data"
    mkdir -p "$BASE_DIR/logs"
}

confirm_lmstudio_server_hint() {
    echo -e "${COLOR_DIM:-}Suggerimento: in LM Studio avvia Developer > Start Server.${COLOR_RESET:-}"
}
