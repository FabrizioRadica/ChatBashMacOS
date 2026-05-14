# ChatBash

Chatbot modulare in Bash per LM Studio con API OpenAI-compatible.
By Fabrizio Radica 2026
www.radicadesign.com


<img width="607" height="400" alt="Screenshot 2026-05-15 alle 00 36 48" src="https://github.com/user-attachments/assets/97d49799-8cc6-4ff9-ac15-6381b515657b" />
<img width="613" height="405" alt="Screenshot 2026-05-15 alle 00 36 32" src="https://github.com/user-attachments/assets/90b415fe-abe8-47af-8706-81a7cec8a27f" />
<img width="616" height="409" alt="Screenshot 2026-05-15 alle 00 34 20" src="https://github.com/user-attachments/assets/872cc6cd-09e2-4771-a350-b86475a83c1b" />

## Requisiti

- macOS / Linux
- LM Studio con server avviato
- `curl`
- `jq`
- `perl`

Su macOS:

```bash
brew install jq
```

## Avvio LM Studio

In LM Studio:

1. Apri Developer tab.
2. Carica un modello.
3. Premi Start Server.
4. Verifica che sia attivo su:

```text
http://localhost:1234
```

## Avvio ChatBash

```bash
chmod +x chatbash.sh
./chatbash.sh
```

## Configurazione

Modifica il file:

```bash
.env
```

Esempio:

```bash
MODEL="local-model"
SYSTEM_PROMPT="sei un bravo assistente. rispondi in modo breve."
TEMPERATURE="0.7"
TOP_P="0.9"
MAX_TOKENS="512"
STREAM="true"
FORMAT_NEWLINES="true"
```

## Comandi interni

```text
/help     Mostra aiuto
/reset    Cancella la history
/history  Mostra la history JSON
/models   Mostra i modelli disponibili da LM Studio
/config   Mostra configurazione attiva
exit      Esce dalla chat
```

## History

La conversazione viene salvata in:

```bash
data/history.json
```

La history viene reinviata al modello a ogni chiamata.

Puoi limitare quanti messaggi inviare modificando:

```bash
MAX_HISTORY_MESSAGES="30"
```

`0` significa: invia tutta la history.

## Accapo automatici dopo il punto

Nel `.env`:

```bash
FORMAT_NEWLINES="true"
```

ChatBash prova a mandare a capo dopo:

- punto
- punto interrogativo
- punto esclamativo

## Streaming

Nel `.env`:

```bash
STREAM="true"
```

Con LM Studio lo streaming funziona usando l'endpoint:

```text
/v1/chat/completions
```

## Debug

Nel `.env`:

```bash
DEBUG="true"
```

Verranno generati:

```bash
data/debug_request.json
data/debug_response.json
data/debug_response_stream.jsonl
logs/curl_error.log
```

## Note importanti

Questo progetto usa endpoint OpenAI-compatible di LM Studio.

Non usa Ollama.

