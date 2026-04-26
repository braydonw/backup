#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/common.sh
source "$SCRIPT_ROOT/lib/common.sh"

# shellcheck source=lib/prompts.sh
source "$SCRIPT_ROOT/lib/prompts.sh"

load_config "$SCRIPT_ROOT"

cd "$SCRIPT_ROOT/.."

mkdir -p "$LOG_DIR"
LOG_DIR_ABSOLUTE="$(cd "$LOG_DIR" && pwd)"
LOG_FILE="$LOG_DIR_ABSOLUTE/setup-$(date +%Y%m%d-%H%M%S).log"
SETUP_TITLE="Raspberry Pi Offsite Backup Node Setup"

export FORCE_COLOR=1

exec > >(tee >(perl -pe 's/\e\[[0-9;?]*[ -\/]*[@-~]//g' >> "$LOG_FILE")) 2>&1

print_main_title "$SETUP_TITLE"
key_value "Log file" "$LOG_FILE"

info "Checking sudo access..."
require_sudo
success "Sudo access confirmed."

STEPS=(
    "00-preflight.sh|Preflight checks"
    "10-system-update.sh|System update"
    "20-install-packages.sh|Install packages"
    "30-configure-storage.sh|Configure storage"
    "40-configure-tailscale.sh|Configure Tailscale"
    "50-configure-samba.sh|Configure Samba"
    "60-configure-nut.sh|Configure UPS monitoring"
    "70-configure-bashrc.sh|Configure shell aliases"
    "80-configure-spindown.sh|Configure HDD spin-down"
    "90-final-checks.sh|Final checks"
)

TOTAL_STEPS="${#STEPS[@]}"
LAST_STATUS="$(format_success "Sudo access confirmed.")"

# wait_for_next_step "Preflight checks"

for step_index in "${!STEPS[@]}"; do
    step_number=$((step_index + 1))

    IFS="|" read -r step_script step_title <<< "${STEPS[$step_index]}"
    step_path="$SCRIPT_ROOT/steps/$step_script"

    print_setup_status "$SETUP_TITLE" "$LOG_FILE" "$step_number" "$TOTAL_STEPS" "$step_title" "$LAST_STATUS"

    if [[ ! -x "$step_path" ]]; then
        error "Step script is missing or not executable: $step_path"
        exit 1
    fi

    print_step_header "$step_title"

    set +e
    "$step_path" check
    check_result="$?"
    set -e

    case "$check_result" in
        0)
            LAST_STATUS="$(format_success "Completed: $step_title")"
            ;;
        1)
            warn "This step is not complete."

            if confirm "Run this step?" "y"; then
                set +e
                "$step_path" run
                run_result="$?"
                set -e

                if [[ "$run_result" -eq 0 ]]; then
                    LAST_STATUS="$(format_success "Completed: $step_title")"
                else
                    LAST_STATUS="$(format_error "Failed: $step_title")"
                    print_setup_status "$SETUP_TITLE" "$LOG_FILE" "$step_number" "$TOTAL_STEPS" "$step_title" "$LAST_STATUS"
                    error "Step failed. See log file for details: $LOG_FILE"
                    exit "$run_result"
                fi
            else
                LAST_STATUS="$(format_muted "Skipped: $step_title")"
            fi
            ;;
        *)
            LAST_STATUS="$(format_error "Failed check: $step_title")"
            print_setup_status "$SETUP_TITLE" "$LOG_FILE" "$step_number" "$TOTAL_STEPS" "$step_title" "$LAST_STATUS"
            error "Check failed with exit code $check_result. See log file for details: $LOG_FILE"
            exit "$check_result"
            ;;
    esac

    next_step_index=$((step_index + 1))

    if [[ "$next_step_index" -lt "$TOTAL_STEPS" ]]; then
        IFS="|" read -r _ next_step_title <<< "${STEPS[$next_step_index]}"
        wait_for_next_step "$next_step_title"
    else
        wait_for_finish
    fi
done

print_setup_status "$SETUP_TITLE" "$LOG_FILE" "$TOTAL_STEPS" "$TOTAL_STEPS" "Complete" "$LAST_STATUS"
success "Setup complete."