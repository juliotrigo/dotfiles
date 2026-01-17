#!/bin/bash
# Symlink helper functions for setup scripts.
# Source this file in scripts that create symlinks.
# Requires: DRY_RUN variable to be set (see common.sh)

# Create a symlink with proper handling of existing files
# Behavior:
#   - File exists: Skip with warning
#       e.g. "Skipping: ~/.file already exists (not a symlink)"
#   - Symlink points elsewhere: Skip with warning showing current target
#       e.g. "Skipping: ~/.file points to /other/path (not /correct/path)"
#   - Correct symlink exists: Show message confirming it's correct
#       e.g. "OK: ~/.file -> /correct/path"
#   - Missing: Create symlink and show confirmation
#       e.g. "Created: ~/.file -> /correct/path"
#
# Args: $1 = source (in dotfiles), $2 = target (in home)
create_symlink() {
    local source="$1"
    local target="$2"

    # Check if source exists
    if [ ! -e "$source" ]; then
        echo "Error: Source does not exist: $source"
        return 1
    fi

    # Check if target already exists
    if [ -L "$target" ]; then
        # It's a symlink - check where it points
        local current_target
        current_target="$(readlink "$target")"
        if [ "$current_target" = "$source" ]; then
            echo "OK: $target -> $source"
            return 0
        else
            echo "Skipping: $target points to $current_target (not $source)"
            return 0
        fi
    elif [ -e "$target" ]; then
        # It's a regular file or directory
        echo "Skipping: $target already exists (not a symlink)"
        return 0
    fi

    # Create parent directory if needed
    local parent_dir
    parent_dir="$(dirname "$target")"
    if [ ! -d "$parent_dir" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo "Would create directory: $parent_dir"
        else
            mkdir -p "$parent_dir"
            echo "Created directory: $parent_dir"
        fi
    fi

    # Create the symlink
    if [ "$DRY_RUN" = true ]; then
        echo "Would create: $target -> $source"
    else
        ln -s "$source" "$target"
        echo "Created: $target -> $source"
    fi
}
