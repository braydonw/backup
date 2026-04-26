#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

load_config "$SCRIPT_ROOT"

BASHRC_FILE="$HOME/.bashrc"
BLOCK_NAME="rpi-setup aliases"

get_alias_block() {
    cat <<'ALIASES'
# Raspberry Pi helpers
alias temp="vcgencmd measure_temp"
alias voltage="vcgencmd measure_volts core"
alias throttled="vcgencmd get_throttled"
ALIASES
}

check() {
    if [[ "$ENABLE_BASH_ALIASES" != "true" ]]; then
        muted "Bash aliases disabled in setup.conf."
        return 0
    fi

    if managed_block_exists "$BASHRC_FILE" "$BLOCK_NAME"; then
        success "Raspberry Pi aliases are already configured."
        return 0
    fi

    warn "Raspberry Pi aliases are not configured in $BASHRC_FILE."
    return 1
}

run() {
    if [[ "$ENABLE_BASH_ALIASES" != "true" ]]; then
        muted "Bash aliases disabled in setup.conf."
        return 0
    fi

    info "Updating $BASHRC_FILE..."
    replace_managed_block "$BASHRC_FILE" "$BLOCK_NAME" "$(get_alias_block)"

    success "Bash aliases configured."
    echo "Reload with:"
    echo "source ~/.bashrc"
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) error "Usage: $0 {check|run}"; exit 2 ;;
esac