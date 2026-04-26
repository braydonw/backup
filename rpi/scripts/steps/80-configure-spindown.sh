#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

load_config "$SCRIPT_ROOT"

check() {
    if [[ "$ENABLE_SPINDOWN" != "true" ]]; then
        muted "HDD spin-down disabled in setup.conf."
        return 0
    fi

    if ! package_is_installed hd-idle; then
        warn "hd-idle is not installed."
        return 1
    fi

    if ! service_is_enabled hd-idle; then
        warn "hd-idle is not enabled."
        return 1
    fi

    warn "Spin-down support is experimental and may depend on the USB-SATA bridge."
    return 1
}

run() {
    require_sudo

    if [[ "$ENABLE_SPINDOWN" != "true" ]]; then
        muted "HDD spin-down disabled in setup.conf."
        return 0
    fi

    info "Installing spin-down and disk monitoring tools..."
    sudo apt-get install -y hd-idle sdparm hdparm smartmontools sysstat

    success "Spin-down tooling installed."
    warn "This step is intentionally not fully automated yet."
    echo "Your previous notes suggest this enclosure may report SMART using SCSI mode."
    info "Useful commands:"
    echo "sudo smartctl -a /dev/sdb --device=scsi"
    echo "sudo smartctl -d scsi -n standby /dev/sdb"
    echo "sudo iostat -x 1 5 /dev/sdb"
    echo "sudo hdparm -C /dev/sdb"
    echo "sudo hdparm -y /dev/sdb"
    muted "Once confirmed, update this script with the exact known-good configuration."
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) error "Usage: $0 {check|run}"; exit 2 ;;
esac