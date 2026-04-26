#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

load_config "$SCRIPT_ROOT"

required_packages() {
    local packages=(
        curl
        git
        rsync
        smartmontools
        sysstat
    )

    if [[ "$ENABLE_NUT" == "true" ]]; then
        packages+=(nut)
    fi

    if [[ "$ENABLE_SPINDOWN" == "true" ]]; then
        packages+=(hd-idle sdparm hdparm)
    fi

    printf '%s\n' "${packages[@]}"
}

check() {
    local missing_packages=()

    while IFS= read -r package_name; do
        if ! package_is_installed "$package_name"; then
            missing_packages+=("$package_name")
        fi
    done < <(required_packages)

    if [[ "${#missing_packages[@]}" -eq 0 ]]; then
        success "All required packages are already installed."
        return 0
    fi

    warn "Missing packages:"
    printf '  - %s\n' "${missing_packages[@]}"

    return 1
}

run() {
    require_sudo

    mapfile -t packages < <(required_packages)

    info "Updating package lists..."
    sudo apt-get update

    info "Installing packages..."
    printf '  - %s\n' "${packages[@]}"
    sudo apt-get install -y "${packages[@]}"

    # success "Package installation complete."
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) error "Usage: $0 {check|run}"; exit 2 ;;
esac