#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

load_config "$SCRIPT_ROOT"

check() {
    require_command bash
    require_command sudo
    require_command systemctl
    require_command lsblk
    require_command findmnt
    require_command dpkg

    if ! is_debian_like; then
        error "This script expects Raspberry Pi OS / Debian-like Linux."
        return 2
    fi

    return 1
}

run() {
    print_subheader "System information"

    key_value "OS" "$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
    key_value "Kernel" "$(uname -r)"
    key_value "Hostname" "$(hostname)"
    echo

    print_subheader "Block devices"
    lsblk -f
    echo

    if is_raspberry_pi; then
        print_subheader "Raspberry Pi model"
        tr -d '\0' < /proc/device-tree/model
        echo
    else
        warn "This does not appear to be a Raspberry Pi."
    fi

    require_sudo

    success "Preflight checks complete."
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) error "Usage: $0 {check|run}"; exit 2 ;;
esac
