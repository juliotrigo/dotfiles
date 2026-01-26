#!/bin/bash
# Verifies the state of dotfiles in ~ before running setup scripts.
# Shows what exists, what differs, and what would be affected by setup.
#
# Usage:
#   bash verify-dotfiles.sh              # Check all categories
#   bash verify-dotfiles.sh git          # Check only git category
#   bash verify-dotfiles.sh git gnupg    # Check multiple categories
#
# Status types (color-coded):
#   SYMLINK -> <path>                - Green  - Points to repo file, already configured
#   SYMLINK -> <path> (wrong target) - Red    - Points elsewhere, will be skipped
#   EXISTS (file)                    - Red    - File (not symlink), will be skipped
#   EXISTS (directory)               - Red    - Directory (not symlink), will be skipped
#   EXISTS (template)                - Green  - Generated from template, matches expected
#   EXISTS (template differs)        - Red    - Generated from template, differs from expected
#   EXISTS (template)                - Yellow - Cannot compare (envsubst missing)
#   EXISTS (template)                - Yellow - Comparison may be inaccurate (env vars not set)
#   MISSING                          - Yellow - Target doesn't exist, will be created by setup
#   CONFIGURED                       - Green  - Already configured correctly
#   PARTIAL                          - Yellow - Partially configured
#   NOT CONFIGURED                   - Yellow - Not yet configured
#
# Informational checks (not counted in summary):
#   EXISTS                           - Green  - Optional file exists
#   NOT FOUND                        - Yellow - Optional file not present
#
# Special handling:
#   - .gitconfig: Compared against template with env var substitution.
#     Set GIT_USER_NAME/GIT_USER_EMAIL (optionally GIT_TICKET_PREFIXES) for accurate diff (see README.md).
#   - Directories: When a regular dir exists, lists its contents to help
#     decide whether to back up and remove

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source shared libraries
source "$SCRIPT_DIR/lib/common.sh"

check_bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Determine which diff command to use (GNU diff supports --color, BSD diff does not)
if command -v gdiff >/dev/null 2>&1; then
    DIFF_CMD="gdiff --color=auto"
elif diff --color=auto /dev/null /dev/null 2>/dev/null; then
    DIFF_CMD="diff --color=auto"
else
    DIFF_CMD="diff"
fi

# Counters for summary
OK_COUNT=0
ATTENTION_COUNT=0

# Max lines to show in diff output
MAX_DIFF_LINES=30

# Max files to show when listing directory contents
MAX_FILES_SHOWN=5

# Available categories
ALL_CATEGORIES="claude git gnupg zsh"

# Print colored status
print_status() {
    local color="$1"
    local label="$2"
    echo -e "  Status: ${color}${label}${NC}"
}

print_action() {
    local message="$1"
    echo "  Action: $message"
}

print_note() {
    local message="$1"
    echo "  Note:   $message"
}

# Print truncation message if diff exceeds max lines
print_truncation_message() {
    local total_lines="$1"
    if [ "$total_lines" -gt "$MAX_DIFF_LINES" ]; then
        echo "  ... ($((total_lines - MAX_DIFF_LINES)) more lines)"
    fi
}

# Check a single file/directory and print its status
# Args: $1 = source (in dotfiles), $2 = target (in home), $3 = special type (optional)
check_file() {
    local source="$1"
    local target="$2"
    local special="$3"

    echo ""
    echo -e "${BOLD}$target${NC}"

    # Check if source exists in repo
    if [ ! -e "$source" ]; then
        print_status "$RED" "ERROR: Source missing in repo"
        print_note "Expected source: $source"
        ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
        return
    fi

    # Handle different target states
    if [ -L "$target" ]; then
        # It's a symlink
        local current_target
        current_target="$(readlink "$target")"
        if [ "$current_target" = "$source" ]; then
            print_status "$GREEN" "SYMLINK -> $source"
            print_action "Already configured correctly"
            OK_COUNT=$((OK_COUNT + 1))
        else
            print_status "$RED" "SYMLINK -> $current_target (wrong target)"
            print_action "Will be SKIPPED by setup (symlink points elsewhere)"
            print_note "Expected: $source"
            ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
        fi
    elif [ -d "$target" ]; then
        # It's a directory (not a symlink)
        print_status "$RED" "EXISTS (directory)"
        print_action "Will be SKIPPED by setup (exists, not a symlink)"
        local file_count
        file_count=$(find "$target" -type f 2>/dev/null | wc -l | tr -d ' ')
        print_note "Contains $file_count file(s) - review before replacing"
        # Show first few files
        if [ "$file_count" -gt 0 ]; then
            echo "  Files:"
            find "$target" -type f 2>/dev/null | head -"$MAX_FILES_SHOWN" | while read -r f; do
                echo "    - ${f#$target/}"
            done
            if [ "$file_count" -gt "$MAX_FILES_SHOWN" ]; then
                echo "    ... and $((file_count - MAX_FILES_SHOWN)) more"
            fi
        fi
        ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
    elif [ -f "$target" ]; then
        # It's a regular file
        if [ "$special" = "gitconfig" ]; then
            # gitconfig is expected to be a regular file (generated from template)
            # Determine mode once based on env vars
            local mode
            if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
                mode="substituted"
            else
                mode="raw"
            fi

            local expected
            if ! expected=$(get_expected_gitconfig "$source" "$mode"); then
                print_status "$YELLOW" "EXISTS (template)"
                print_action "Cannot compare - install gettext via Homebrew, then re-run"
                ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
            elif [ "$mode" = "raw" ]; then
                # Without env vars, we can't do an accurate comparison
                print_status "$YELLOW" "EXISTS (template)"
                print_action "Set GIT_USER_NAME/GIT_USER_EMAIL (optionally GIT_TICKET_PREFIXES) to compare accurately, then re-run"
                local raw_identical=false
                if echo "$expected" | diff -q - "$target" >/dev/null 2>&1; then
                    raw_identical=true
                fi
                show_gitconfig_diff "$expected" "$mode" "$target" "$raw_identical"
                ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
            elif echo "$expected" | diff -q - "$target" >/dev/null 2>&1; then
                print_status "$GREEN" "EXISTS (template)"
                print_action "Already configured correctly"
                show_gitconfig_diff "$expected" "$mode" "$target" true
                OK_COUNT=$((OK_COUNT + 1))
            else
                print_status "$RED" "EXISTS (template differs)"
                print_action "Run setup-gitconfig.sh to update"
                show_gitconfig_diff "$expected" "$mode" "$target" false
                ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
            fi
        else
            print_status "$RED" "EXISTS (file)"
            print_action "Will be SKIPPED by setup (exists, not a symlink)"
            show_diff "$source" "$target"
            ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
        fi
    else
        # Target doesn't exist
        print_status "$YELLOW" "MISSING"
        print_action "Will be CREATED by setup"
        ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
    fi
}

# Show diff between two files
show_diff() {
    local source="$1"
    local target="$2"

    if diff -q "$source" "$target" >/dev/null 2>&1; then
        echo "  Diff:   Files are identical"
    else
        local diff_lines
        diff_lines=$(diff "$target" "$source" 2>/dev/null | wc -l | tr -d ' ')
        echo "  Diff:   $diff_lines lines differ"
        echo ""
        # Show the actual diff
        $DIFF_CMD -u "$target" "$source" 2>/dev/null | head -"$MAX_DIFF_LINES" || true
        local total_lines
        total_lines=$(diff -u "$target" "$source" 2>/dev/null | wc -l | tr -d ' ')
        print_truncation_message "$total_lines"
    fi
}

# Generate expected gitconfig content from template
# Args: $1 = template file, $2 = mode ("substituted"|"raw")
# Outputs the expected content to stdout
# Returns 1 if envsubst not available (only in substituted mode), 0 otherwise
get_expected_gitconfig() {
    local template="$1"
    local mode="$2"

    if [ "$mode" = "substituted" ]; then
        if ! command -v envsubst >/dev/null 2>&1; then
            return 1
        fi
        envsubst '${GIT_USER_NAME} ${GIT_USER_EMAIL} ${GIT_TICKET_PREFIXES}' < "$template"
    else
        cat "$template"
    fi
}

# Show diff for gitconfig
# Args: $1 = expected content, $2 = mode ("substituted"|"raw"), $3 = target file,
#       $4 = is_identical (true|false)
show_gitconfig_diff() {
    local expected="$1"
    local mode="$2"
    local target="$3"
    local is_identical="$4"

    # Print note about comparison mode
    if [ "$mode" = "substituted" ]; then
        print_note "Comparing with substituted template (using current env vars)"
        if [ -z "${GIT_TICKET_PREFIXES+x}" ]; then
            print_note "GIT_TICKET_PREFIXES not set, ticketPrefixes comparison may be inaccurate"
        fi
    else
        print_note "Comparing with raw template (GIT_USER_NAME/GIT_USER_EMAIL not set)"
    fi

    # Show diff result
    if [ "$is_identical" = true ]; then
        echo "  Diff:   Files are identical"
    else
        local diff_lines
        diff_lines=$(echo "$expected" | diff "$target" - 2>/dev/null | wc -l | tr -d ' ')
        echo "  Diff:   $diff_lines lines differ"
        echo ""
        echo "$expected" | $DIFF_CMD -u "$target" - 2>/dev/null | head -"$MAX_DIFF_LINES" || true
        local total_lines
        total_lines=$(echo "$expected" | diff -u "$target" - 2>/dev/null | wc -l | tr -d ' ')
        print_truncation_message "$total_lines"
    fi
}

# Get files for a category
# Args: $1 = category name
# Output: prints lines in format "source:target[:special]"
get_category_files() {
    local category="$1"

    case "$category" in
        claude)
            echo ".claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
            echo ".claude/commands:$HOME/.claude/commands"
            echo ".claude/rules:$HOME/.claude/rules"
            ;;
        git)
            echo ".git-hooks:$HOME/.git-hooks"
            echo ".gitattributes:$HOME/.gitattributes"
            echo ".gitignore_global:$HOME/.gitignore_global"
            echo ".gitmessage:$HOME/.gitmessage"
            echo ".gitconfig.template:$HOME/.gitconfig:gitconfig"
            ;;
        gnupg)
            echo ".gnupg/gpg.conf:$HOME/.gnupg/gpg.conf"
            echo ".gnupg/gpg-agent.conf:$HOME/.gnupg/gpg-agent.conf"
            echo ".gnupg/dirmngr.conf:$HOME/.gnupg/dirmngr.conf"
            ;;
        zsh)
            echo ".zshrc.d:$HOME/.zshrc.d"
            ;;
        *)
            return 1
            ;;
    esac
}

# Check all files in a category
check_category() {
    local category="$1"

    if ! get_category_files "$category" >/dev/null 2>&1; then
        echo -e "${RED}Unknown category: $category${NC}"
        echo "Available categories: $ALL_CATEGORIES"
        exit 1
    fi

    echo ""
    echo -e "${BOLD}=== Category: $category ===${NC}"

    while IFS= read -r mapping; do
        [ -z "$mapping" ] && continue

        local source target special
        IFS=':' read -r source target special <<< "$mapping"
        check_file "$DOTFILES_DIR/$source" "$target" "$special"
    done < <(get_category_files "$category")

    # Category-specific informational checks
    case "$category" in
        zsh)
            check_zshrc_sources
            check_optional_file "$HOME/.zshrc.local" "For machine-specific settings"
            ;;
    esac
}

# Check an optional file (informational only, not counted in summary)
check_optional_file() {
    local target="$1"
    local description="$2"

    echo ""
    echo -e "${BOLD}$target${NC} (optional)"

    if [ -f "$target" ]; then
        print_status "$GREEN" "EXISTS"
        print_note "$description"
    else
        print_status "$YELLOW" "NOT FOUND"
        print_note "$description"
    fi
}

# Check if ~/.zshrc sources the zshrc.d files
check_zshrc_sources() {
    local zshrc="$HOME/.zshrc"

    echo ""
    echo -e "${BOLD}$zshrc${NC} (configuration check)"

    if [ ! -f "$zshrc" ]; then
        print_status "$YELLOW" "NOT FOUND"
        print_note "Cannot check source lines"
        return
    fi

    # Check for source lines (excluding comments)
    local omz_sourced=false
    local custom_sourced=false

    if grep -v '^\s*#' "$zshrc" | grep -qE '(source|\.) .*\.zshrc\.d/omz\.zsh'; then
        omz_sourced=true
    fi

    if grep -v '^\s*#' "$zshrc" | grep -qE '(source|\.) .*\.zshrc\.d/custom\.zsh'; then
        custom_sourced=true
    fi

    if $omz_sourced && $custom_sourced; then
        print_status "$GREEN" "CONFIGURED"
        print_note "Both omz.zsh and custom.zsh are sourced"
        OK_COUNT=$((OK_COUNT + 1))
    elif $omz_sourced; then
        print_status "$YELLOW" "PARTIAL"
        print_note "omz.zsh sourced, custom.zsh missing"
        ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
    elif $custom_sourced; then
        print_status "$YELLOW" "PARTIAL"
        print_note "custom.zsh sourced, omz.zsh missing"
        ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
    else
        print_status "$YELLOW" "NOT CONFIGURED"
        print_note "Add source lines for omz.zsh and custom.zsh"
        ATTENTION_COUNT=$((ATTENTION_COUNT + 1))
    fi
}

# Print summary
print_summary() {
    echo ""
    echo "========================================"
    echo -e "${BOLD}Summary${NC}"
    echo "========================================"
    echo -e "  ${GREEN}OK:${NC} $OK_COUNT files correctly configured"
    echo -e "  ${YELLOW}Attention:${NC} $ATTENTION_COUNT files need attention"
    echo ""

    if [ "$ATTENTION_COUNT" -gt 0 ]; then
        echo "Files needing attention may be:"
        echo "  - Missing (will be created by setup)"
        echo "  - Existing files/directories (will be skipped - backup and remove if needed)"
        echo "  - Symlinks pointing elsewhere (will be skipped - check if intentional)"
    fi
}

# Main
main() {
    echo "Dotfiles Verification"
    echo "Comparing repo files with home directory..."

    local categories=("$@")

    # If no categories specified, check all
    if [ ${#categories[@]} -eq 0 ]; then
        for cat in $ALL_CATEGORIES; do
            categories+=("$cat")
        done
    fi

    for category in "${categories[@]}"; do
        check_category "$category"
    done

    print_summary
}

main "$@"
