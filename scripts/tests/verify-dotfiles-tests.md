# verify-dotfiles.sh Test Cases

Manual test scenarios for the dotfiles verification script.

**Note:** These tests require a test harness that creates temporary directories to simulate different file states. Tests should NEVER modify `~` or other sensitive directories directly.

## Test Harness Requirements

To run these tests, create a test script that:
1. Creates a temporary directory structure simulating `$HOME`
2. Creates a temporary "repo" directory with source files
3. Sets up the specific file state for each test
4. Runs verify-dotfiles.sh with appropriate environment
5. Captures and validates output
6. Cleans up temporary directories

## Category Handling

### TC-CAT-01: No categories specified
**Setup:** Run without arguments
**Expected:** All categories (claude, git, gnupg) are checked
**Verify:** Output contains "=== Category: claude ===", "=== Category: git ===", "=== Category: gnupg ==="

### TC-CAT-02: Single category
**Setup:** Run with `git` argument
**Expected:** Only git category is checked
**Verify:** Output contains "=== Category: git ===" only, no claude or gnupg sections

### TC-CAT-03: Multiple categories
**Setup:** Run with `git gnupg` arguments
**Expected:** Both git and gnupg categories are checked
**Verify:** Output contains both "=== Category: git ===" and "=== Category: gnupg ===", no claude section

### TC-CAT-04: Invalid category
**Setup:** Run with `invalid` argument
**Expected:** Error message and exit
**Verify:** Output contains "Unknown category: invalid" and "Available categories: claude git gnupg"

### TC-CAT-05: Mix of valid and invalid categories
**Setup:** Run with `git invalid` arguments
**Expected:** Processes git, then errors on invalid
**Verify:** Output contains "=== Category: git ===" followed by error for invalid

## Symlink States

### TC-SYM-01: Correct symlink
**Setup:** Create symlink pointing to repo file (e.g., `~/.gitignore_global -> $REPO/.gitignore_global`)
**Expected:** Green status, counted as OK
**Verify:**
- Status line: "SYMLINK -> <path>" (where path is the repo file path)
- Action line: "Already configured correctly"
- Summary: OK count incremented

### TC-SYM-02: Wrong target symlink
**Setup:** Create symlink pointing elsewhere (e.g., `~/.gitignore_global -> /some/other/path`)
**Expected:** Red status, counted as Attention
**Verify:**
- Status line: "SYMLINK -> <path> (wrong target)" (where path is the actual target)
- Action line: "Will be SKIPPED by setup (symlink points elsewhere)"
- Note line: "Expected: $REPO/.gitignore_global"
- Summary: Attention count incremented

### TC-SYM-03: Broken symlink
**Setup:** Create symlink pointing to non-existent file
**Expected:** Treated as symlink with wrong target (same as TC-SYM-02)
**Verify:** Same as TC-SYM-02

## Regular File States

### TC-FILE-01: Regular file exists (not gitconfig)
**Setup:** Create regular file at target location (e.g., `~/.gitignore_global` as file, not symlink)
**Expected:** Red status, counted as Attention
**Verify:**
- Status line: "EXISTS (file)"
- Action line: "Will be SKIPPED by setup (exists, not a symlink)"
- Diff output showing differences (if any)
- Summary: Attention count incremented

### TC-FILE-02: Regular file identical to source
**Setup:** Create regular file with same content as repo source
**Expected:** Red status (still a file, not symlink), shows "Files are identical"
**Verify:**
- Status line: "EXISTS (file)"
- Diff line: "Files are identical"

### TC-FILE-03: Regular file differs from source
**Setup:** Create regular file with different content than repo source
**Expected:** Red status, shows diff
**Verify:**
- Status line: "EXISTS (file)"
- Diff line: "X lines differ"
- Actual diff output displayed

## Directory States

### TC-DIR-01: Directory exists (not symlink)
**Setup:** Create directory at target location (e.g., `~/.git-hooks/` as dir, not symlink)
**Expected:** Red status, shows file count
**Verify:**
- Status line: "EXISTS (directory)"
- Action line: "Will be SKIPPED by setup (exists, not a symlink)"
- Note line: "Contains X file(s) - review before replacing"
- Summary: Attention count incremented

### TC-DIR-02: Directory with files (<=5)
**Setup:** Create directory with 3 files
**Expected:** Lists all files
**Verify:**
- "Files:" section shows all 3 files
- No "... and X more" message

### TC-DIR-03: Directory with many files (>5)
**Setup:** Create directory with 8 files
**Expected:** Lists first 5, shows count of remaining
**Verify:**
- "Files:" section shows 5 files
- Shows "... and 3 more"

### TC-DIR-04: Empty directory
**Setup:** Create empty directory at target location
**Expected:** Shows 0 files
**Verify:**
- Note line: "Contains 0 file(s) - review before replacing"
- No "Files:" section

## Missing State

### TC-MISS-01: Target missing
**Setup:** Ensure target file doesn't exist
**Expected:** Yellow status, counted as Attention
**Verify:**
- Status line: "MISSING"
- Action line: "Will be CREATED by setup"
- Summary: Attention count incremented

## Gitconfig Special Cases

### TC-GIT-01: Gitconfig matches (with env vars)
**Setup:**
- Set GIT_USER_NAME and GIT_USER_EMAIL environment variables
- Create ~/.gitconfig with content matching substituted template
**Expected:** Green status, counted as OK
**Verify:**
- Status line: "EXISTS (template)"
- Action line: "Already configured correctly"
- Note line: "Comparing with substituted template (using current env vars)"
- Diff line: "Files are identical"
- Summary: OK count incremented

### TC-GIT-02: Gitconfig differs (with env vars)
**Setup:**
- Set GIT_USER_NAME and GIT_USER_EMAIL environment variables
- Create ~/.gitconfig with content that differs from substituted template
**Expected:** Red status, counted as Attention
**Verify:**
- Status line: "EXISTS (template differs)"
- Action line: "Run setup-gitconfig.sh to update"
- Note line: "Comparing with substituted template (using current env vars)"
- Diff line: "X lines differ"
- Diff output displayed
- Summary: Attention count incremented

### TC-GIT-03: Gitconfig without env vars
**Setup:**
- Unset GIT_USER_NAME and GIT_USER_EMAIL environment variables
- Create ~/.gitconfig (any content - the test verifies yellow status appears when env vars are missing)
**Expected:** Yellow status (inaccurate comparison), counted as Attention
**Verify:**
- Status line: "EXISTS (template)"
- Action line: "Set GIT_USER_NAME/GIT_USER_EMAIL to compare accurately, then re-run"
- Note line: "Comparing with raw template (GIT_USER_NAME/GIT_USER_EMAIL not set)"
- Summary: Attention count incremented

### TC-GIT-04: Gitconfig without envsubst (but env vars set)
**Setup:**
- Set GIT_USER_NAME and GIT_USER_EMAIL environment variables
- Ensure envsubst command is not available (e.g., temporarily rename it or modify PATH)
- Create ~/.gitconfig
**Expected:** Yellow status, counted as Attention
**Verify:**
- Status line: "EXISTS (template)"
- Action line: "Cannot compare - install gettext via Homebrew, then re-run"
- Summary: Attention count incremented
**Note:** This path only triggers when env vars are set (substituted mode) but envsubst is missing. Without env vars, raw mode is used which doesn't require envsubst.

### TC-GIT-05: Gitconfig missing
**Setup:** Ensure ~/.gitconfig doesn't exist
**Expected:** Yellow status (MISSING), counted as Attention
**Verify:**
- Status line: "MISSING"
- Action line: "Will be CREATED by setup"

## Source Missing in Repo

### TC-SRC-01: Source file missing
**Setup:** Remove source file from repo but keep it in category mapping
**Expected:** Red error status
**Verify:**
- Status line: "ERROR: Source missing in repo"
- Note line: "Expected source: $REPO/..."
- Summary: Attention count incremented

## Diff Command Detection

### TC-DIFF-01: gdiff available
**Setup:** Ensure gdiff is in PATH
**Expected:** Uses gdiff with --color=auto
**Verify:** Colored diff output (if terminal supports it)

### TC-DIFF-02: GNU diff with color support
**Setup:** Ensure gdiff not available, but diff --color=auto works
**Expected:** Uses diff --color=auto
**Verify:** Colored diff output

### TC-DIFF-03: BSD diff fallback
**Setup:** Ensure neither gdiff nor diff --color=auto works
**Expected:** Uses plain diff
**Verify:** Uncolored diff output

## Diff Output

### TC-DIFFOUT-01: Short diff (<30 lines)
**Setup:** Create files with small differences
**Expected:** Full diff displayed
**Verify:** All diff lines shown, no truncation message

### TC-DIFFOUT-02: Long diff (>30 lines)
**Setup:** Create files with many differences (>30 lines of diff output)
**Expected:** Truncated diff with message
**Verify:**
- First 30 lines of diff shown
- Shows "... (X more lines)"

## Summary Output

### TC-SUM-01: All OK
**Setup:** Create all files as correct symlinks
**Expected:** Summary shows all OK
**Verify:**
- "OK: X files correctly configured"
- "Attention: 0 files need attention"
- No "Files needing attention" advice

### TC-SUM-02: Mixed results
**Setup:** Create mix of correct symlinks, missing files, and wrong states
**Expected:** Summary shows counts for both
**Verify:**
- Correct OK count
- Correct Attention count
- "Files needing attention may be:" advice shown

### TC-SUM-03: All need attention
**Setup:** No correct symlinks
**Expected:** Summary shows 0 OK
**Verify:**
- "OK: 0 files correctly configured"
- Attention count matches total files checked

## Edge Cases

### TC-EDGE-01: Files with spaces in names
**Setup:** If any dotfiles have spaces (unlikely but possible)
**Expected:** Handles correctly without errors
**Verify:** No quoting or escaping errors

### TC-EDGE-02: Very long file paths
**Setup:** Deeply nested directory structure
**Expected:** Paths displayed correctly
**Verify:** No truncation of path display

### TC-EDGE-03: Special characters in file content
**Setup:** Files containing special bash characters ($, `, \, etc.)
**Expected:** Diffs display correctly
**Verify:** No interpretation or escaping issues in diff output

### TC-EDGE-04: Binary files
**Setup:** Binary file as source (if applicable)
**Expected:** Diff shows "Binary files differ" or similar
**Verify:** No crash or garbled output

### TC-EDGE-05: Permission denied
**Setup:** File/directory with no read permissions
**Expected:** Graceful error handling
**Verify:** Error reported, script continues to next file

## Full Integration Tests

### TC-INT-01: Fresh install (all missing)
**Setup:** Empty home directory, full repo
**Expected:** All files show MISSING status
**Verify:** All attention count, 0 OK count

### TC-INT-02: Fully configured (all correct)
**Setup:** All symlinks pointing to repo correctly
**Expected:** All files show correct SYMLINK status
**Verify:** All OK count, 0 attention count

### TC-INT-03: Partial migration
**Setup:** Mix of correct symlinks, missing files, and existing regular files
**Expected:** Mixed status output
**Verify:** Counts match actual state
