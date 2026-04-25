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

    if ! is_debian_like; then
        echo "This script expects Raspberry Pi OS / Debian-like Linux."
        return 2
    fi

    return 1
}

run() {
    echo "OS:"
    cat /etc/os-release
    echo

    echo "Kernel:"
    uname -a
    echo

    echo "Detected block devices:"
    lsblk -f
    echo

    if is_raspberry_pi; then
        echo "Raspberry Pi model:"
        tr -d '\0' < /proc/device-tree/model
        echo
    else
        echo "Warning: this does not appear to be a Raspberry Pi."
    fi

    require_sudo

    echo "Preflight checks complete."
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) echo "Usage: $0 {check|run}"; exit 2 ;;
esac
