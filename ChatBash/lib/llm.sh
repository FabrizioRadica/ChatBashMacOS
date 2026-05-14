#!/usr/bin/env bash

build_payload() {
    local stream_value="$1"
    local messages
    messages="$(messages_with_system_prompt)"

    jq -n \
        --arg model "${MODEL:-local-model}" \
        --argjson messages "$messages" \
        --argjson temperature "${TEMPERATURE:-0.7}" \
        --argjson top_p "${TOP_P:-0.9}" \
        --argjson max_tokens "${MAX_TOKENS:-512}" \
        --argjson presence_penalty "${PRESENCE_PENALTY:-0}" \
        --argjson frequency_penalty "${FREQUENCY_PENALTY:-0}" \
        --argjson stream "$stream_value" \
        '{
            model:$model,
            messages:$messages,
            temperature:$temperature,
            top_p:$top_p,
            max_tokens:$max_tokens,
            presence_penalty:$presence_penalty,
            frequency_penalty:$frequency_penalty,
            stream:$stream
        }'
}

save_debug_request() {
    local payload="$1"
    if [[ "${DEBUG:-false}" == "true" ]]; then
        printf '%s\n' "$payload" > "$BASE_DIR/data/debug_request.json"
    fi
}

save_debug_response() {
    local response="$1"
    if [[ "${DEBUG:-false}" == "true" ]]; then
        printf '%s\n' "$response" > "$BASE_DIR/data/debug_response.json"
    fi
}

extract_error_message() {
    local response="$1"
    echo "$response" | jq -r '.error.message // .error // empty' 2>/dev/null
}

call_lmstudio_no_stream() {
    local payload
    payload="$(build_payload false)"
    save_debug_request "$payload"

    local response
    response="$(curl -sS --max-time "${REQUEST_TIMEOUT:-120}" "${API_URL:-http://localhost:1234/v1/chat/completions}" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>"$BASE_DIR/logs/curl_error.log")" || {
            echo ""
            return 1
        }

    save_debug_response "$response"

    local error_message
    error_message="$(extract_error_message "$response")"
    if [[ -n "$error_message" ]]; then
        echo -e "\n${COLOR_ERROR:-}Errore LM Studio: $error_message${COLOR_RESET:-}" >&2
        echo ""
        return 1
    fi

    local content
    content="$(echo "$response" | jq -r '.choices[0].message.content // empty' 2>/dev/null)"

    if [[ -n "$content" ]]; then
        echo -ne "\r${COLOR_AI:-}AI:${COLOR_RESET:-} " >&2
        format_text "$content" >&2
        echo >&2
        echo "$content"
    else
        echo ""
    fi
}

call_lmstudio_stream() {
    local payload
    payload="$(build_payload true)"
    save_debug_request "$payload"

    local collected=""
    local started="false"
    local raw_file="$BASE_DIR/data/debug_response_stream.jsonl"
    reset_stream_formatter

    if [[ "${DEBUG:-false}" == "true" ]]; then
        : > "$raw_file"
    fi

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        if [[ "${DEBUG:-false}" == "true" ]]; then
            printf '%s\n' "$line" >> "$raw_file"
        fi

        if [[ "$line" != data:* ]]; then
            continue
        fi

        local json
        json="${line#data: }"

        if [[ "$json" == "[DONE]" ]]; then
            break
        fi

        local error_message
        error_message="$(extract_error_message "$json")"
        if [[ -n "$error_message" ]]; then
            echo -e "\n${COLOR_ERROR:-}Errore LM Studio: $error_message${COLOR_RESET:-}" >&2
            continue
        fi

        local token
        token="$(echo "$json" | jq -r '.choices[0].delta.content // empty' 2>/dev/null)"

        if [[ -n "$token" ]]; then
            if [[ "$started" == "false" ]]; then
                echo -ne "\r${COLOR_AI:-}AI:${COLOR_RESET:-} " >&2
                started="true"
            fi

            collected+="$token"
            print_stream_token_sentence_aware "$token" >&2
        fi
    done < <(
        curl -sS -N --max-time "${REQUEST_TIMEOUT:-120}" "${API_URL:-http://localhost:1234/v1/chat/completions}" \
            -H "Content-Type: application/json" \
            -d "$payload" 2>"$BASE_DIR/logs/curl_error.log"
    )

    echo "$collected"
}

list_models() {
    echo
    echo -e "${COLOR_INFO:-}Modelli disponibili da LM Studio:${COLOR_RESET:-}"

    local response
    response="$(curl -sS --max-time 10 "${MODELS_URL:-http://localhost:1234/v1/models}" 2>"$BASE_DIR/logs/curl_error.log")" || {
        echo -e "${COLOR_ERROR:-}Impossibile contattare LM Studio.${COLOR_RESET:-}"
        confirm_lmstudio_server_hint
        return 1
    }

    if [[ -z "$response" ]]; then
        echo -e "${COLOR_ERROR:-}Risposta vuota da LM Studio.${COLOR_RESET:-}"
        return 1
    fi

    echo "$response" | jq .
}
