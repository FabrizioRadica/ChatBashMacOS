#!/usr/bin/env bash

print_header() {
    if [[ "${SHOW_HEADER:-true}" != "true" ]]; then
        return 0
    fi

    echo -e "${COLOR_TITLE:-}============================================${COLOR_RESET:-}"
    echo -e "${COLOR_TITLE:-} ChatBash - LM Studio Local Chatbot${COLOR_RESET:-}"
    echo -e "${COLOR_TITLE:-} By Fabrizio Radica 2026${COLOR_RESET:-}"
    echo -e "${COLOR_TITLE:-}============================================${COLOR_RESET:-}"
    echo
    echo -e "${COLOR_DIM:-}Comandi:${COLOR_RESET:-} /help, /reset, /history, /models, /config, exit"
    echo -e "${COLOR_DIM:-}Modello:${COLOR_RESET:-} ${MODEL:-local-model}"
    echo -e "${COLOR_DIM:-}API:${COLOR_RESET:-} ${API_URL:-http://localhost:1234/v1/chat/completions}"
}

print_help() {
    echo
    echo -e "${COLOR_INFO:-}Comandi disponibili:${COLOR_RESET:-}"
    echo "  /help     Mostra questo aiuto"
    echo "  /reset    Cancella la history"
    echo "  /history  Mostra la history JSON"
    echo "  /models   Mostra i modelli esposti da LM Studio"
    echo "  /config   Mostra configurazione attiva"
    echo "  exit      Esce dalla chat"
}

print_config() {
    echo
    echo -e "${COLOR_INFO:-}Configurazione attiva:${COLOR_RESET:-}"
    echo "  MODEL=$MODEL"
    echo "  API_URL=$API_URL"
    echo "  MODELS_URL=$MODELS_URL"
    echo "  TEMPERATURE=$TEMPERATURE"
    echo "  TOP_P=$TOP_P"
    echo "  MAX_TOKENS=$MAX_TOKENS"
    echo "  STREAM=$STREAM"
    echo "  HISTORY_FILE=$HISTORY_FILE"
    echo "  MAX_HISTORY_MESSAGES=$MAX_HISTORY_MESSAGES"
    echo "  FORMAT_NEWLINES=$FORMAT_NEWLINES"
    echo "  DEBUG=$DEBUG"
}
