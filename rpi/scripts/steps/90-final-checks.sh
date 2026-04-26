#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

load_config "$SCRIPT_ROOT"

check() {
    # info "Final checks are intentionally prompt-driven."
    # return 1
    return 0
}

run() {
    print_subheader "System"
    key_value "Hostname" "$(hostname)"
    key_value "Uptime" "$(uptime -p)"

    print_subheader "Block devices"
    lsblk -f

    print_subheader "Mounted filesystems"
    df -h

    print_subheader "NAS mount"
    if findmnt "$NAS_MOUNT_POINT"; then
        success "$NAS_MOUNT_POINT is mounted."
    else
        warn "$NAS_MOUNT_POINT is not mounted."
    fi

    if command -v tailscale >/dev/null 2>&1; then
        print_subheader "Tailscale status"
        tailscale status || true
    fi

    print_subheader "Thermals / throttling"
    echo "CPU temperature:"
    vcgencmd measure_temp || true
    echo "Throttling status:"
    vcgencmd get_throttled || true

    echo
    success "Final checks complete."
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) error "Usage: $0 {check|run}"; exit 2 ;;
esac