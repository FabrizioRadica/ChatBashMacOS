#!/bin/bash

echo 
echo "ChatBash by Fabrizio Radica :)"
MODEL="local-model"
HISTORY_FILE="history.json"

# crea history se non esiste
if [ ! -f "$HISTORY_FILE" ]; then
    echo "[]" > "$HISTORY_FILE"
fi

while true
do
    echo
    read -p "Tu: " usermsg

    # uscita
    if [[ "$usermsg" == "exit" ]]; then
        echo
        echo "Chat terminata."
        break
    fi

    # evita testo vuoto
    if [[ -z "$usermsg" ]]; then
        continue
    fi

    # carica history
    history=$(cat "$HISTORY_FILE")

    # aggiunge user
    history=$(echo "$history" | jq \
        --arg msg "$usermsg" \
        '. += [{
            "role":"user",
            "content":$msg
        }]')

    # salva history
    echo "$history" > "$HISTORY_FILE"

    # payload
    payload=$(jq -n \
        --arg model "$MODEL" \
        --argjson messages "$history" \
        '{
            model:$model,
            messages:$messages,
            temperature:0.7,
            stream:true
        }')

    echo
    echo -n "AI: sto pensando..."

    assistant=""

    # stream realtime
    while IFS= read -r line
    do
        # prende solo righe data:
        if [[ "$line" == data:* ]]; then

            json="${line#data: }"

            # fine stream
            if [[ "$json" == "[DONE]" ]]; then
                break
            fi

            # recupera token
            token=$(echo "$json" | jq -r '.choices[0].delta.content // empty')

            # stampa solo se esiste
            if [[ -n "$token" ]]; then

                # cancella "sto pensando..." solo la prima volta
                if [[ -z "$assistant" ]]; then
                    echo -ne "\rAI: "
                fi

                echo -n "$token"

                assistant+="$token"
            fi
        fi

    done < <(
        curl -s http://localhost:1234/v1/chat/completions \
            -H "Content-Type: application/json" \
            -N \
            -d "$payload"
    )

    echo
    echo

    # salva solo se non vuoto
    if [[ -n "$assistant" ]]; then

        history=$(cat "$HISTORY_FILE")

        history=$(echo "$history" | jq \
            --arg msg "$assistant" \
            '. += [{
                "role":"assistant",
                "content":$msg
            }]')

        echo "$history" > "$HISTORY_FILE"
    fi

done