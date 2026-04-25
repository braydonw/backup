#!/usr/bin/env bash

set -euo pipefail

get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

get_repo_root() {
    local current_dir
    current_dir="$(pwd)"

    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/.git" ]]; then
            echo "$current_dir"
            return 0
        fi

        current_dir="$(dirname "$current_dir")"
    done

    pwd
}

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Missing required command: $command_name"
        return 1
    fi
}

require_sudo() {
    if ! sudo -v; then
        echo "This step requires sudo."
        return 1
    fi
}

is_raspberry_pi() {
    [[ -f /proc/device-tree/model ]] && grep -qi "raspberry pi" /proc/device-tree/model
}

is_debian_like() {
    [[ -f /etc/os-release ]] && grep -Eq 'ID=debian|ID=raspbian|ID=ubuntu|ID_LIKE=.*debian' /etc/os-release
}

package_is_installed() {
    local package_name="$1"

    dpkg -s "$package_name" >/dev/null 2>&1
}

service_is_active() {
    local service_name="$1"

    systemctl is-active --quiet "$service_name"
}

service_is_enabled() {
    local service_name="$1"

    systemctl is-enabled --quiet "$service_name"
}

backup_file() {
    local file="$1"

    if [[ -f "$file" ]]; then
        local backup_path
        backup_path="$file.bak.$(date +%Y%m%d-%H%M%S)"

        echo "Backing up $file to $backup_path"
        sudo cp "$file" "$backup_path"
    fi
}

line_exists() {
    local file="$1"
    local line="$2"

    grep -qxF "$line" "$file" 2>/dev/null
}

append_line_if_missing() {
    local file="$1"
    local line="$2"

    if ! line_exists "$file" "$line"; then
        echo "$line" | sudo tee -a "$file" >/dev/null
    fi
}

managed_block_exists() {
    local file="$1"
    local block_name="$2"

    grep -qF "# BEGIN $block_name" "$file" 2>/dev/null &&
        grep -qF "# END $block_name" "$file" 2>/dev/null
}

replace_managed_block() {
    local file="$1"
    local block_name="$2"
    local content="$3"

    local start_marker="# BEGIN $block_name"
    local end_marker="# END $block_name"
    local temp_file

    temp_file="$(mktemp)"

    if [[ -f "$file" ]] && managed_block_exists "$file" "$block_name"; then
        awk -v start="$start_marker" -v end="$end_marker" '
            $0 == start { skip = 1; next }
            $0 == end { skip = 0; next }
            skip != 1 { print }
        ' "$file" > "$temp_file"
    elif [[ -f "$file" ]]; then
        cat "$file" > "$temp_file"
    fi

    {
        cat "$temp_file"
        echo
        echo "$start_marker"
        echo "$content"
        echo "$end_marker"
    } | sudo tee "$file" >/dev/null

    rm -f "$temp_file"
}

load_config() {
    local script_root="$1"
    local config_file="$script_root/setup.conf"
    local example_config_file="$script_root/setup.conf.example"

    if [[ ! -f "$config_file" ]]; then
        echo "Creating local config from setup.conf.example"
        cp "$example_config_file" "$config_file"
    fi

    # shellcheck source=/dev/null
    source "$config_file"
}
