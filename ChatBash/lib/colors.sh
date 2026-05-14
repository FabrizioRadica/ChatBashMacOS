#!/usr/bin/env bash

init_colors() {
    if [[ "${ENABLE_COLORS:-true}" == "false" ]]; then
        COLOR_RESET=''
        COLOR_TITLE=''
        COLOR_USER=''
        COLOR_AI=''
        COLOR_INFO=''
        COLOR_ERROR=''
        COLOR_THINKING=''
        COLOR_DIM=''
        COLOR_COMMAND=''
        return 0
    fi

    COLOR_RESET='\033[0m'
    COLOR_TITLE='\033[1;36m'
    COLOR_USER='\033[1;32m'
    COLOR_AI='\033[1;35m'
    COLOR_INFO='\033[0;36m'
    COLOR_ERROR='\033[1;31m'
    COLOR_THINKING='\033[0;33m'
    COLOR_DIM='\033[2m'
    COLOR_COMMAND='\033[1;34m'
}
