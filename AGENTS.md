# Project Instructions

Dotfiles management system. Uses symlinks and templates to configure git,
zsh, gnupg, and other tools from a single versioned repository.

## Documentation

- `README.md` - Installation instructions, verification, and setup for all categories
- `.claude/README.md` - Claude Code configuration, plugins, and state file usage
- `.git-hooks/README.md` - Hook wrapper system, ticket ID prepending, and troubleshooting

## Commands

| Command | Description |
|---------|-------------|
| `bash scripts/verify-dotfiles.sh` | Check status of all dotfiles before setup |
| `bash scripts/verify-dotfiles.sh git gnupg` | Verify specific categories |
| `brew bundle install` | Install Homebrew dependencies |
| `bash scripts/setup-git-symlinks.sh` | Create git-related symlinks |
| `bash scripts/setup-gitconfig.sh` | Generate ~/.gitconfig from template |
| `bash scripts/setup-gnupg-symlinks.sh` | Create gnupg symlinks |
| `bash scripts/setup-zsh-symlinks.sh` | Create zsh directory symlink |
| `bash scripts/setup-claude.sh` | Create Claude Code symlinks |

All setup scripts support `--dry-run` to preview changes.

## Architecture

```
dotfiles/
  .claude/          # Claude Code config (symlinked to ~/.claude/)
  .git-hooks/       # Global git hooks with hook-wrapper system
  .gnupg/           # GnuPG configuration files
  .zshrc.d/         # Zsh configuration modules (omz.zsh, custom.zsh)
  scripts/
    lib/            # Shared functions (common.sh, symlinks.sh)
    setup-*.sh      # Per-category setup scripts
    tests/          # Test case documentation
    verify-dotfiles.sh  # Pre-setup verification
```

## Key Patterns

- **Symlink-based:** Config files are symlinked from `~` to this repo (not copied)
- **Exception: gitconfig** is generated from `.gitconfig.template` via `envsubst`, not symlinked
- **Idempotent scripts:** All setup scripts are safe to re-run; they skip existing files/symlinks
- **Shared libraries:** `scripts/lib/common.sh` (bash checks, dry-run) and `scripts/lib/symlinks.sh` (symlink creation) are sourced by setup scripts
- **Hook wrapper:** `.git-hooks/hook-wrapper` is the single entry point — it's symlinked from per-hook files (e.g., `~/.git-hooks/prepare-commit-msg`)
- **Script conventions:** All scripts use `set -e` and source shared libs from `scripts/lib/`

## Testing

- `scripts/tests/verify-dotfiles-tests.md` - Manual test scenarios for `verify-dotfiles.sh`

## Gotchas

- `setup-gitconfig.sh` requires `envsubst` from the `gettext` Homebrew package — run `brew bundle install` first
- `setup-gitconfig.sh` needs `GIT_USER_NAME`, `GIT_USER_EMAIL`, and optionally `GIT_TICKET_PREFIXES` (as env vars or via interactive prompt)
- GnuPG setup requires manually removing existing config files before symlinking (they're regular files by default)
- Zsh setup requires manual edits to `~/.zshrc` to source the module files
- The git hook `prepare-commit-msg` auto-prepends ticket IDs from branch names — controlled by `git config hooks.ticketPrefixes`

## Workflow

- After merging a PR to master, always ask if a release should be created.
- After any repo change, review and update this `AGENTS.md` file if the change affects documented commands, architecture, patterns, or gotchas.
