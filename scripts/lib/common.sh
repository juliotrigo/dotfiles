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

# List the names of the Claude Code skills held in the repo.
# Skills are linked into ~/.claude/skills one directory at a time rather than
# linking ~/.claude/skills itself, because that directory also holds skills
# installed by other tools (cubic, peon-ping).
# A skill is a directory containing SKILL.md; any other directory (e.g. one
# left behind holding only a .DS_Store after its skill was removed) is skipped.
# Args: $1 = dotfiles directory
# Output: one skill name per line
claude_skill_names() {
    local dotfiles_dir="$1"
    local skill
    for skill in "$dotfiles_dir"/.claude/skills/*/; do
        [ -f "$skill/SKILL.md" ] || continue
        basename "$skill"
    done
}
