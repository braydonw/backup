#!/usr/bin/env bash

confirm() {
    local prompt="$1"
    local default="${2:-n}"
    local response

    if [[ "$default" == "y" ]]; then
        read -r -p "$prompt [Y/n]: " response
        [[ -z "$response" || "$response" =~ ^[Yy]$ ]]
    else
        read -r -p "$prompt [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]]
    fi
}

pause_until_ready() {
    local message="$1"

    printf '\n%s\n' "$message"
    read -r -p "Press Enter to continue..."
}

wait_for_next_step() {
    local next_step_title="${1:-next step}"

    printf '\n'
    read -r -p "Press Enter to continue to: $next_step_title"
}