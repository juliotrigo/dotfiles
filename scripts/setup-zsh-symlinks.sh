#!/bin/bash
# Creates symlinks for Zsh configuration files.
# Idempotent: skips existing files/symlinks with appropriate messages.
# See lib/symlinks.sh for behavior details.
#
# Usage: bash setup-zsh-symlinks.sh [--dry-run]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source shared libraries
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/symlinks.sh"

check_bash
parse_dry_run "$1"

echo "Setting up Zsh symlinks..."
echo ""

create_symlink "$DOTFILES_DIR/.zshrc.d" "$HOME/.zshrc.d"

echo ""
echo "Done."
echo ""
echo "Next steps:"
echo "  Add these lines to your ~/.zshrc:"
echo ""
echo "  # Before \"source \$ZSH/oh-my-zsh.sh\":"
echo "  [[ -f ~/.zshrc.d/omz.zsh ]] && source ~/.zshrc.d/omz.zsh"
echo ""
echo "  # At the end of the file:"
echo "  [[ -f ~/.zshrc.d/custom.zsh ]] && source ~/.zshrc.d/custom.zsh"
echo ""
echo "  Then remove the duplicated settings from ~/.zshrc."
