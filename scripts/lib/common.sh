#!/bin/bash
# Common functions and checks for all setup scripts.
# Source this file at the start of each setup script.

# Ensure script is running under bash (not POSIX mode)
check_bash() {
    if [ -z "$BASH_VERSION" ]; then
        echo "Error: This script requires bash. Please run with: bash $0"
        exit 1
    fi
    if [[ "$SHELLOPTS" == *"posix"* ]]; then
        echo "Error: This script cannot run in POSIX mode. Please run with: bash $0"
        exit 1
    fi
}

# Parse --dry-run flag and set DRY_RUN variable
# Args: $1 = first argument passed to script
parse_dry_run() {
    DRY_RUN=false
    if [[ "$1" == "--dry-run" ]]; then
        DRY_RUN=true
        echo "Dry run mode - no changes will be made"
        echo ""
    fi
}
