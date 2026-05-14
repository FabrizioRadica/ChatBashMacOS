#!/usr/bin/env bash

# ==========================================================
# ChatBash
# Chatbot Bash modulare per LM Studio OpenAI-compatible API
# By Fabrizio Radica
# ==========================================================

set -u
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1) Librerie minime, senza variabili .env obbligatorie.
source "$BASE_DIR/lib/env.sh"
source "$BASE_DIR/lib/colors.sh"

# 2) Caricamento configurazione PRIMA di qualsiasi UI o funzione che usi MODEL/API_URL.
load_env "$BASE_DIR/.env"
apply_defaults
validate_config

# 3) Colori dopo .env, perché ENABLE_COLORS arriva dalla configurazione.
init_colors

# 4) Librerie applicative.
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/formatter.sh"
source "$BASE_DIR/lib/history.sh"
source "$BASE_DIR/lib/llm.sh"
source "$BASE_DIR/lib/ui.sh"

check_dependencies
ensure_project_dirs
init_history
clear_screen
print_header

while true; do
    echo
    read -r -p "$(echo -e "${COLOR_USER:-}Tu:${COLOR_RESET:-} ")" USER_INPUT || {
        echo
        break
    }

    USER_INPUT="$(trim "$USER_INPUT")"

    # Non inviare nulla se il testo è null/vuoto.
    if [[ -z "$USER_INPUT" ]]; then
        continue
    fi

    case "$USER_INPUT" in
        exit|quit|/exit|/quit)
            echo
            echo -e "${COLOR_INFO:-}Chat terminata.${COLOR_RESET:-}"
            break
            ;;
        /reset)
            reset_history
            echo -e "${COLOR_INFO:-}History azzerata.${COLOR_RESET:-}"
            continue
            ;;
        /history)
            print_history
            continue
            ;;
        /models)
            list_models
            continue
            ;;
        /config)
            print_config
            continue
            ;;
        /help)
            print_help
            continue
            ;;
    esac

    add_message_to_history "user" "$USER_INPUT"

    echo
    echo -ne "${COLOR_AI:-}AI:${COLOR_RESET:-} ${COLOR_THINKING:-}${THINKING_MESSAGE:-sto pensando...}${COLOR_RESET:-}"

    ASSISTANT_RESPONSE=""

    if [[ "${STREAM:-true}" == "true" ]]; then
        ASSISTANT_RESPONSE="$(call_lmstudio_stream)" || ASSISTANT_RESPONSE=""
    else
        ASSISTANT_RESPONSE="$(call_lmstudio_no_stream)" || ASSISTANT_RESPONSE=""
    fi

    ASSISTANT_RESPONSE="$(trim "$ASSISTANT_RESPONSE")"

    echo

    if [[ -n "$ASSISTANT_RESPONSE" ]]; then
        add_message_to_history "assistant" "$ASSISTANT_RESPONSE"
    else
        echo -e "${COLOR_ERROR:-}Nessuna risposta valida ricevuta dal modello.${COLOR_RESET:-}"
        if [[ -s "$BASE_DIR/logs/curl_error.log" ]]; then
            echo -e "${COLOR_DIM:-}Dettaglio curl:${COLOR_RESET:-} $(cat "$BASE_DIR/logs/curl_error.log")"
        fi
        confirm_lmstudio_server_hint
        remove_last_user_message
    fi

done
