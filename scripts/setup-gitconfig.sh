#!/bin/bash
# Generates ~/.gitconfig from template with user-specific values.
# Prompts for confirmation if existing config differs from generated one.
# Creates a backup (~/.gitconfig.backup.<epoch>) before overwriting.
# Requires bash (not POSIX sh) due to use of [[ ]], read -n, and process substitution.
#
# Usage: bash setup-gitconfig.sh [--dry-run]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source shared library
source "$SCRIPT_DIR/lib/common.sh"

check_bash
parse_dry_run "$1"

# Check for required dependency
if ! command -v envsubst &> /dev/null; then
    echo "Error: envsubst is required but not installed."
    echo "Install it with: brew install gettext"
    exit 1
fi

TEMPLATE_FILE="$DOTFILES_DIR/.gitconfig.template"
TARGET_FILE="$HOME/.gitconfig"

# Check template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file not found: $TEMPLATE_FILE"
    exit 1
fi

# Get user name from environment or prompt
if [ -z "$GIT_USER_NAME" ]; then
    read -p "Enter git user name: " GIT_USER_NAME
    if [ -z "$GIT_USER_NAME" ]; then
        echo "Error: Git user name cannot be empty"
        exit 1
    fi
fi

# Get user email from environment or prompt
if [ -z "$GIT_USER_EMAIL" ]; then
    read -p "Enter git user email: " GIT_USER_EMAIL
    if [ -z "$GIT_USER_EMAIL" ]; then
        echo "Error: Git user email cannot be empty"
        exit 1
    fi
fi

# Get ticket prefixes from environment or prompt (optional, empty disables ticket prepending)
if [ -z "${GIT_TICKET_PREFIXES+x}" ]; then
    read -p "Enter ticket prefixes (optional, e.g. ABC|DEF|GHI): " GIT_TICKET_PREFIXES
fi

# Export for envsubst
export GIT_USER_NAME
export GIT_USER_EMAIL
export GIT_TICKET_PREFIXES

# Generate new config
NEW_CONFIG=$(envsubst '${GIT_USER_NAME} ${GIT_USER_EMAIL} ${GIT_TICKET_PREFIXES}' < "$TEMPLATE_FILE")

# Check if target file exists
if [ -f "$TARGET_FILE" ]; then
    CURRENT_CONFIG=$(cat "$TARGET_FILE")

    # Compare configs
    if [ "$NEW_CONFIG" = "$CURRENT_CONFIG" ]; then
        echo "No changes needed. $TARGET_FILE is up to date."
        exit 0
    fi

    # Show diff
    echo "Differences found between generated config and existing $TARGET_FILE:"
    echo ""
    diff --color=auto <(echo "$CURRENT_CONFIG") <(echo "$NEW_CONFIG") || true
    echo ""

    BACKUP_FILE="$TARGET_FILE.backup.$(date +%s)"

    if [ "$DRY_RUN" = true ]; then
        echo "Would back up $TARGET_FILE to $BACKUP_FILE"
        echo "Would overwrite $TARGET_FILE"
        exit 0
    fi

    # Ask for confirmation
    read -p "Do you want to override $TARGET_FILE? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted. No changes made."
        exit 0
    fi

    # Create backup before overwriting
    cp "$TARGET_FILE" "$BACKUP_FILE"
    echo "Backed up existing config to $BACKUP_FILE"
else
    if [ "$DRY_RUN" = true ]; then
        echo "Would create $TARGET_FILE"
        exit 0
    fi
fi

# Write new config
echo "$NEW_CONFIG" > "$TARGET_FILE"
echo "Successfully wrote $TARGET_FILE"
