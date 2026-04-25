#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

load_config "$SCRIPT_ROOT"

check() {
    # Package freshness is time-dependent, so this step should remain prompt-driven.
    return 1
}

run() {
    require_sudo

    sudo apt update
    sudo apt full-upgrade -y

    echo "System update complete."
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) echo "Usage: $0 {check|run}"; exit 2 ;;
esac
