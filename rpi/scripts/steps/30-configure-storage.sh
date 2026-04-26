#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=../lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

# shellcheck source=../lib/prompts.sh
source "$SCRIPT_ROOT/lib/prompts.sh"

load_config "$SCRIPT_ROOT"

get_mount_line() {
    echo "UUID=$NAS_DEVICE_UUID $NAS_MOUNT_POINT $NAS_FILESYSTEM_TYPE $NAS_MOUNT_OPTIONS 0 2"
}

check() {
    if [[ -z "$NAS_DEVICE_UUID" ]]; then
        warn "NAS_DEVICE_UUID is not set in setup.conf."
        return 1
    fi

    if ! findmnt "$NAS_MOUNT_POINT" >/dev/null 2>&1; then
        warn "$NAS_MOUNT_POINT is not currently mounted."
        return 1
    fi

    if ! grep -q "UUID=$NAS_DEVICE_UUID[[:space:]]\+$NAS_MOUNT_POINT" /etc/fstab; then
        warn "/etc/fstab does not contain the expected mount entry."
        return 1
    fi

    if [[ ! -d "$BACKUP_DIR" ]]; then
        warn "$BACKUP_DIR does not exist."
        return 1
    fi

    if [[ ! -L "$HOME_NAS_SYMLINK" ]]; then
        warn "$HOME_NAS_SYMLINK symlink does not exist."
        return 1
    fi

    success "Storage is configured."
    return 0
}

run() {
    require_sudo

    if [[ -z "$NAS_DEVICE_UUID" ]]; then
        print_subheader "Detected filesystems"
        lsblk -f

        warn "NAS_DEVICE_UUID is not set."
        echo "Edit this file and set NAS_DEVICE_UUID before rerunning this step:"
        echo "$SCRIPT_ROOT/setup.conf"
        echo "Recommended target: RAID volume partition, usually labeled nas."

        return 1
    fi

    info "Creating mount point if needed..."
    sudo mkdir -p "$NAS_MOUNT_POINT"

    local mount_line
    mount_line="$(get_mount_line)"

    print_subheader "Proposed /etc/fstab entry"
    echo "$mount_line"

    if confirm "Add this mount entry if missing?" "y"; then
        backup_file /etc/fstab
        append_line_if_missing /etc/fstab "$mount_line"
    else
        muted "fstab update skipped."
    fi

    info "Reloading systemd..."
    sudo systemctl daemon-reload

    info "Testing mounts..."
    sudo mount -a

    if ! findmnt "$NAS_MOUNT_POINT" >/dev/null 2>&1; then
        error "Mount failed. Check /etc/fstab and dmesg."
        return 1
    fi

    info "Setting ownership..."
    sudo chown -R "$USER:$USER" "$NAS_MOUNT_POINT"

    info "Creating backup directory..."
    mkdir -p "$BACKUP_DIR"

    if [[ ! -e "$HOME_NAS_SYMLINK" ]]; then
        info "Creating home directory symlink..."
        ln -s "$NAS_MOUNT_POINT" "$HOME_NAS_SYMLINK"
    elif [[ -L "$HOME_NAS_SYMLINK" ]]; then
        muted "Symlink already exists: $HOME_NAS_SYMLINK"
    else
        warn "Path already exists and is not a symlink: $HOME_NAS_SYMLINK"
    fi

    # success "Storage configuration complete."
}

case "${1:-}" in
    check) check ;;
    run) run ;;
    *) error "Usage: $0 {check|run}"; exit 2 ;;
esac