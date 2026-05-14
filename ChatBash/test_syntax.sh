#!/usr/bin/env bash
set -u

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash -n "$BASE_DIR/chatbash.sh"
for file in "$BASE_DIR"/lib/*.sh; do
    bash -n "$file"
done

echo "Sintassi Bash OK."
