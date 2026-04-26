#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

load_config "$SCRIPT_ROOT"

check() {
    if [[ "$ENABLE_TAILSCALE" != "true" ]]; then
        muted "Tailscale disabled in setup.conf."
        return 0
    fi

    if ! command -v tailscale >/dev/null 2>&1; then
        warn "Tailscale is not installed."
        return 1
    fi

    if ! service_is_active tailscaled; then
        warn "tailscaled is not active."
        return 1
    fi

    if ! tailscale status >/dev/null 2>&1; then
        warn "Tailscale is installed but not authenticated."
        return 1
    fi

    success "Tailscale is installed, running, and authenticated."
    return 0
}

run() {
    require_sudo

    if [[ "$ENABLE_TAILSCALE" != "true" ]]; then
        muted "Tailscale disabled in setup.conf."
        return 0
    fi

    if ! command -v tailscale >/dev/null 2>&1; then
        info "Installing Tailscale..."
        curl -fsSL https://tailscale.com/install.sh | sh
    else
        muted "Tailscale already installed."
    fi

    info "Enabling tailscaled..."
    sudo systemctl enable --now tailscaled

    if ! tailscale status >/dev/null 2>&1; then
        warn "Tailscale needs authentication."
        echo "Run:"
        echo "sudo tailscale up --hostname=$TAILSCALE_HOSTNAME"
        echo "Then rerun this setup step."

        return 1
    fi

    # success "Tailscale configuration complete."
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) error "Usage: $0 {check|run}"; exit 2 ;;
esac