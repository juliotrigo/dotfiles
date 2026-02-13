#!/bin/bash
# Creates symlinks for Claude Code configuration files.
# Idempotent: skips existing files/symlinks with appropriate messages.
# See lib/symlinks.sh for behavior details.
#
# Usage: bash setup-claude.sh [--dry-run]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source shared libraries
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/symlinks.sh"

check_bash
parse_dry_run "$1"

echo "Setting up Claude Code symlinks..."
echo ""

create_symlink "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
create_symlink "$DOTFILES_DIR/.claude/commands" "$HOME/.claude/commands"
create_symlink "$DOTFILES_DIR/.claude/rules" "$HOME/.claude/rules"
create_symlink "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"

echo ""
echo "Done."
