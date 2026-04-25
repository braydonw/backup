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
LOG_FILE="$LOG_DIR/setup-$(date +%Y%m%d-%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

print_step_header "Raspberry Pi Offsite Backup Node Setup"

echo "Log file: $LOG_FILE"
echo

STEPS=(
    "00-preflight.sh|Preflight checks"
    # "10-system-update.sh|System update"
    # "20-install-packages.sh|Install packages"
    # "30-configure-storage.sh|Configure storage"
    # "40-configure-tailscale.sh|Configure Tailscale"
    # "50-configure-samba.sh|Configure Samba"
    # "60-configure-nut.sh|Configure UPS monitoring"
    # "70-configure-bashrc.sh|Configure shell aliases"
    # "80-configure-spindown.sh|Configure HDD spin-down"
    # "90-final-checks.sh|Final checks"
)

for step_entry in "${STEPS[@]}"; do
    IFS="|" read -r step_script step_title <<< "$step_entry"
    step_path="$SCRIPT_ROOT/steps/$step_script"

    print_step_header "$step_title"

    if [[ ! -x "$step_path" ]]; then
        echo "Step script is missing or not executable: $step_path"
        exit 1
    fi

    set +e
    "$step_path" check
    check_result=$?
    set -e

    case "$check_result" in
        0)
            echo "Already complete. Skipping."
            ;;
        1)
            if confirm "Run this step?" "y"; then
                "$step_path" run
            else
                echo "Skipped by user."
            fi
            ;;
        *)
            echo "Check failed with exit code $check_result."
            exit "$check_result"
            ;;
    esac
done

print_step_header "Setup complete"
echo

echo "Review the log if needed:"
echo "$LOG_FILE"
echo
