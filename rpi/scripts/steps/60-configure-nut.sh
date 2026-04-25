#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

load_config "$SCRIPT_ROOT"

check() {
    if [[ "$ENABLE_NUT" != "true" ]]; then
        muted "NUT disabled in setup.conf."
        return 0
    fi

    if ! package_is_installed nut; then
        warn "NUT is not installed."
        return 1
    fi

    warn "NUT is installed, but UPS model-specific configuration is still manual."
    return 1
}

run() {
    require_sudo

    if [[ "$ENABLE_NUT" != "true" ]]; then
        muted "NUT disabled in setup.conf."
        return 0
    fi

    info "Installing NUT..."
    sudo apt-get install -y nut

    success "NUT installed."
    warn "UPS configuration depends on the exact UPS model."
    info "Next manual steps:"
    echo "1. Identify the UPS:"
    echo "   lsusb"
    echo "2. Configure:"
    echo "   /etc/nut/ups.conf"
    echo "   /etc/nut/nut.conf"
    echo "   /etc/nut/upsmon.conf"
    echo "3. Enable and start the relevant NUT services."
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) error "Usage: $0 {check|run}"; exit 2 ;;
esac