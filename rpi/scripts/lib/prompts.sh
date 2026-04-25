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

    echo
    echo "$message"
    read -r -p "Press Enter to continue..."
}
