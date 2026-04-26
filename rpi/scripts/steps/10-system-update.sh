#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

load_config "$SCRIPT_ROOT"

check() {
    info "System updates are intentionally prompt-driven."
    return 2
}

run() {
    require_sudo

    echo
    info "Updating package lists..."
    sudo apt-get update

    echo
    info "Installing available upgrades..."
    sudo apt-get full-upgrade -y

    echo
    success "System update complete."
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) error "Usage: $0 {check|run}"; exit 2 ;;
esac