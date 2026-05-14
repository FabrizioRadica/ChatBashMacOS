#!/usr/bin/env bash

history_path() {
    printf '%s/%s' "$BASE_DIR" "${HISTORY_FILE:-data/history.json}"
}

init_history() {
    local file
    file="$(history_path)"

    mkdir -p "$(dirname "$file")"

    if [[ ! -f "$file" ]]; then
        echo "[]" > "$file"
    fi

    if ! jq empty "$file" >/dev/null 2>&1; then
        echo "[]" > "$file"
    fi
}

read_history() {
    local file
    file="$(history_path)"

    if [[ ! -f "$file" ]]; then
        echo "[]"
        return 0
    fi

    cat "$file"
}

write_history() {
    local content="$1"
    local file
    file="$(history_path)"

    mkdir -p "$(dirname "$file")"
    printf '%s\n' "$content" > "$file"
}

reset_history() {
    write_history "[]"
}

add_message_to_history() {
    local role="$1"
    local content="$2"

    if [[ -z "$content" ]]; then
        return 0
    fi

    local current
    current="$(read_history)"

    local updated
    updated="$(echo "$current" | jq \
        --arg role "$role" \
        --arg content "$content" \
        '. += [{"role":$role,"content":$content}]')"

    write_history "$updated"
}

remove_last_user_message() {
    local current
    current="$(read_history)"

    local updated
    updated="$(echo "$current" | jq '
        if length > 0 and .[-1].role == "user" then .[:-1] else . end
    ')"

    write_history "$updated"
}

messages_for_api() {
    local current
    current="$(read_history)"

    if [[ "${MAX_HISTORY_MESSAGES:-30}" == "0" ]]; then
        echo "$current"
    else
        echo "$current" | jq --argjson max "${MAX_HISTORY_MESSAGES:-30}" '.[-($max):]'
    fi
}

messages_with_system_prompt() {
    local messages
    messages="$(messages_for_api)"

    jq -n \
        --arg system "${SYSTEM_PROMPT:-sei un bravo assistente. rispondi in modo breve.}" \
        --argjson messages "$messages" \
        '[{"role":"system","content":$system}] + $messages'
}

print_history() {
    echo
    echo -e "${COLOR_INFO:-}History corrente:${COLOR_RESET:-}"
    jq . "$(history_path)"
}
