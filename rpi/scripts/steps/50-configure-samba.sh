#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

load_config "$SCRIPT_ROOT"

check() {
    muted "Samba setup is intentionally not implemented yet."
    muted "You may use Taildrive or another file-sharing solution instead."

    return 0
}

run() {
    muted "Samba setup is intentionally not implemented yet."
    muted "Nothing was changed."
    info "Future options:"
    echo "- Tailscale Taildrive"
    echo "- Samba over Tailscale"
    echo "- SFTP / SSHFS"
    echo "- Syncthing"
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) error "Usage: $0 {check|run}"; exit 2 ;;
esac