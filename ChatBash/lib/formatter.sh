#!/usr/bin/env bash

format_text() {
    local text="$1"

    if [[ "${FORMAT_NEWLINES:-true}" != "true" ]]; then
        printf '%s' "$text"
        return 0
    fi

    # Va a capo dopo punto, punto interrogativo e punto esclamativo
    # quando sono seguiti da spazio e da una lettera/numero.
    printf '%s' "$text" | perl -CSDA -pe 's/([.!?])\s+([[:alnum:]À-ÿ])/$1\n$2/g'
}

format_token_for_stream() {
    local token="$1"

    if [[ "${FORMAT_NEWLINES:-true}" != "true" ]]; then
        printf '%s' "$token"
        return 0
    fi

    printf '%s' "$token" | perl -CSDA -pe 's/([.!?])\s+([[:alnum:]À-ÿ])/$1\n$2/g'
}

# Stato usato solo durante lo streaming.
STREAM_WAITING_AFTER_PUNCT="false"

reset_stream_formatter() {
    STREAM_WAITING_AFTER_PUNCT="false"
}

print_stream_token_sentence_aware() {
    local token="$1"

    if [[ "${FORMAT_NEWLINES:-true}" != "true" ]]; then
        printf '%s' "$token"
        return 0
    fi

    local i
    local char
    local len=${#token}

    for (( i=0; i<len; i++ )); do
        char="${token:i:1}"

        if [[ "$STREAM_WAITING_AFTER_PUNCT" == "true" ]]; then
            if [[ "$char" =~ [[:space:]] ]]; then
                continue
            fi

            printf '\n'
            printf '%s' "$char"
            STREAM_WAITING_AFTER_PUNCT="false"
        else
            printf '%s' "$char"
        fi

        if [[ "$char" == "." || "$char" == "!" || "$char" == "?" ]]; then
            STREAM_WAITING_AFTER_PUNCT="true"
        fi
    done
}
