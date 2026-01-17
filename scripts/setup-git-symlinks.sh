#!/bin/bash
# Creates symlinks for Git configuration files (excluding .gitconfig).
# Idempotent: skips existing files/symlinks with appropriate messages.
# See lib/symlinks.sh for behavior details.
#
# Usage: bash setup-git-symlinks.sh [--dry-run]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source shared libraries
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/symlinks.sh"

check_bash
parse_dry_run "$1"

echo "Setting up Git symlinks..."
echo ""

create_symlink "$DOTFILES_DIR/.git-hooks" "$HOME/.git-hooks"
create_symlink "$DOTFILES_DIR/.gitattributes" "$HOME/.gitattributes"
create_symlink "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
create_symlink "$DOTFILES_DIR/.stCommitMsg" "$HOME/.stCommitMsg"

echo ""
echo "Done."
