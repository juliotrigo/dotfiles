#!/bin/bash
# Creates symlinks for GnuPG configuration files.
# Idempotent: skips existing files/symlinks with appropriate messages.
# See lib/symlinks.sh for behavior details.
#
# Usage: bash setup-gnupg-symlinks.sh [--dry-run]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source shared libraries
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/symlinks.sh"

check_bash
parse_dry_run "$1"

echo "Setting up GnuPG symlinks..."
echo ""

create_symlink "$DOTFILES_DIR/.gnupg/gpg.conf" "$HOME/.gnupg/gpg.conf"
create_symlink "$DOTFILES_DIR/.gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"
create_symlink "$DOTFILES_DIR/.gnupg/dirmngr.conf" "$HOME/.gnupg/dirmngr.conf"

echo ""
echo "Done."
