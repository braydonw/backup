#!/usr/bin/env bash

set -euo pipefail

if [[ "${NO_COLOR:-}" == "" ]] && { [[ -t 1 ]] || [[ "${FORCE_COLOR:-}" == "1" ]]; }; then
    COLOR_RESET=$'\033[0m'
    COLOR_BOLD=$'\033[1m'
    COLOR_DIM=$'\033[2m'
    COLOR_RED=$'\033[31m'
    COLOR_GREEN=$'\033[32m'
    COLOR_YELLOW=$'\033[33m'
    COLOR_BLUE=$'\033[34m'
    COLOR_MAGENTA=$'\033[35m'
    COLOR_CYAN=$'\033[36m'
    COLOR_GRAY=$'\033[90m'
else
    COLOR_RESET=""
    COLOR_BOLD=""
    COLOR_DIM=""
    COLOR_RED=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_BLUE=""
    COLOR_MAGENTA=""
    COLOR_CYAN=""
    COLOR_GRAY=""
fi

print_main_title() {
    local message="$1"

    printf '\n%s%s%s\n' "$COLOR_BOLD$COLOR_MAGENTA" "$message" "$COLOR_RESET"
}

print_step_header() {
    local message="$1"

    printf '\n%s%s%s\n' "$COLOR_BOLD$COLOR_CYAN" "$message" "$COLOR_RESET"
}

print_subheader() {
    local message="$1"

    printf '\n%s%s%s\n' "$COLOR_BOLD$COLOR_BLUE" "$message" "$COLOR_RESET"
}

info() {
    local message="$1"

    printf '%s%s%s\n' "$COLOR_BLUE" "$message" "$COLOR_RESET"
}

success() {
    local message="$1"

    printf '%s%s%s\n' "$COLOR_GREEN" "$message" "$COLOR_RESET"
}

warn() {
    local message="$1"

    printf '%sWarning:%s %s\n' "$COLOR_YELLOW" "$COLOR_RESET" "$message"
}

error() {
    local message="$1"

    printf '%sError:%s %s\n' "$COLOR_RED" "$COLOR_RESET" "$message" >&2
}

muted() {
    local message="$1"

    printf '%s%s%s\n' "$COLOR_GRAY" "$message" "$COLOR_RESET"
}

key_value() {
    local key="$1"
    local value="$2"

    printf '%s%s:%s %s\n' "$COLOR_BOLD" "$key" "$COLOR_RESET" "$value"
}

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        error "Missing required command: $command_name"
        return 1
    fi
}

require_sudo() {
    if ! sudo -v; then
        error "This step requires sudo."
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

        info "Backing up $file"
        muted "Backup path: $backup_path"

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

    if line_exists "$file" "$line"; then
        muted "Line already exists in $file"
        return 0
    fi

    echo "$line" | sudo tee -a "$file" >/dev/null
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
        info "Creating local config from setup.conf.example"
        cp "$example_config_file" "$config_file"
    fi

    # shellcheck source=/dev/null
    source "$config_file"
}