#!/bin/bash
# Generates ~/.gitconfig from template with user-specific values.
# Prompts for confirmation if existing config differs from generated one.
# Requires bash (not POSIX sh) due to use of [[ ]], read -n, and process substitution.

set -e

# Ensure script is running under bash (not POSIX mode)
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script requires bash. Please run with: bash $0"
    exit 1
fi
if [[ "$SHELLOPTS" == *"posix"* ]]; then
    echo "Error: This script cannot run in POSIX mode. Please run with: bash $0"
    exit 1
fi

# Check for required dependency
if ! command -v envsubst &> /dev/null; then
    echo "Error: envsubst is required but not installed."
    echo "Install it with: brew install gettext"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
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

# Export for envsubst
export GIT_USER_NAME
export GIT_USER_EMAIL

# Generate new config
NEW_CONFIG=$(envsubst '${GIT_USER_NAME} ${GIT_USER_EMAIL}' < "$TEMPLATE_FILE")

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
    
    # Ask for confirmation
    read -p "Do you want to override $TARGET_FILE? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted. No changes made."
        exit 0
    fi
fi

# Write new config
echo "$NEW_CONFIG" > "$TARGET_FILE"
echo "Successfully wrote $TARGET_FILE"
