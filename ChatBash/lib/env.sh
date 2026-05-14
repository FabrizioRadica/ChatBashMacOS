#!/usr/bin/env bash

load_env() {
    local env_file="$1"

    if [[ ! -f "$env_file" ]]; then
        echo "Errore: file .env non trovato: $env_file" >&2
        exit 1
    fi

    # Esporta automaticamente le variabili definite nel file .env.
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
}

apply_defaults() {
    : "${API_URL:=http://localhost:1234/v1/chat/completions}"
    : "${MODELS_URL:=http://localhost:1234/v1/models}"
    : "${MODEL:=local-model}"
    : "${SYSTEM_PROMPT:=sei un bravo assistente. rispondi in modo breve.}"
    : "${TEMPERATURE:=0.7}"
    : "${TOP_P:=0.9}"
    : "${MAX_TOKENS:=512}"
    : "${PRESENCE_PENALTY:=0}"
    : "${FREQUENCY_PENALTY:=0}"
    : "${STREAM:=true}"
    : "${HISTORY_FILE:=data/history.json}"
    : "${MAX_HISTORY_MESSAGES:=30}"
    : "${FORMAT_NEWLINES:=true}"
    : "${ENABLE_COLORS:=true}"
    : "${THINKING_MESSAGE:=sto pensando...}"
    : "${SHOW_HEADER:=true}"
    : "${DEBUG:=false}"
    : "${REQUEST_TIMEOUT:=120}"
}

validate_config() {
    local error=0

    if [[ -z "${MODEL:-}" ]]; then
        echo "Errore configurazione: MODEL è vuoto." >&2
        error=1
    fi

    if [[ -z "${API_URL:-}" ]]; then
        echo "Errore configurazione: API_URL è vuoto." >&2
        error=1
    fi

    if ! [[ "${TEMPERATURE:-}" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "Errore configurazione: TEMPERATURE deve essere numerico." >&2
        error=1
    fi

    if ! [[ "${TOP_P:-}" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "Errore configurazione: TOP_P deve essere numerico." >&2
        error=1
    fi

    if ! [[ "${MAX_TOKENS:-}" =~ ^[0-9]+$ ]]; then
        echo "Errore configurazione: MAX_TOKENS deve essere intero." >&2
        error=1
    fi

    if ! [[ "${MAX_HISTORY_MESSAGES:-}" =~ ^[0-9]+$ ]]; then
        echo "Errore configurazione: MAX_HISTORY_MESSAGES deve essere intero." >&2
        error=1
    fi

    if [[ "$error" -eq 1 ]]; then
        exit 1
    fi
}
