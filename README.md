# Configuration files

My dotfiles.

## Structure

**Dotfiles repo:**
```
dotfiles/
├── .claude/
│   ├── CLAUDE.md
│   ├── README.md
│   ├── commands/
│   │   └── release.md
│   └── rules/
│       ├── python-testing.md
│       ├── security.md
│       ├── testing-patterns.md
│       └── version-control.md
├── .git-hooks/
│   ├── README.md
│   ├── hook-wrapper
│   └── ... (symlinks)
├── .gitattributes
├── .gitconfig.template
├── .gitignore_global
├── .gitmessage
├── .gnupg/
│   ├── dirmngr.conf
│   ├── gpg-agent.conf
│   └── gpg.conf
├── .zshrc.d/
│   ├── custom.zsh
│   └── omz.zsh
└── scripts/
    ├── lib/
    │   ├── common.sh          # Shared: bash checks, dry-run parsing
    │   └── symlinks.sh        # Shared: symlink creation function
    ├── setup-claude.sh
    ├── setup-git-symlinks.sh
    ├── setup-gitconfig.sh
    ├── setup-gnupg-symlinks.sh
    ├── setup-zsh-symlinks.sh
    └── verify-dotfiles.sh     # Check status before setup
```

**Home directory:**
```
~/
├── .claude/
│   ├── CLAUDE.md            -> dotfiles/.claude/CLAUDE.md
│   ├── commands/            -> dotfiles/.claude/commands/
│   └── rules/               -> dotfiles/.claude/rules/
├── .git-hooks/              -> dotfiles/.git-hooks/
├── .gitattributes           -> dotfiles/.gitattributes
├── .gitconfig               # Generated from template
├── .gitignore_global        -> dotfiles/.gitignore_global
├── .gitmessage              -> dotfiles/.gitmessage
├── .gnupg/
│   ├── dirmngr.conf         -> dotfiles/.gnupg/dirmngr.conf
│   ├── gpg-agent.conf       -> dotfiles/.gnupg/gpg-agent.conf
│   └── gpg.conf             -> dotfiles/.gnupg/gpg.conf
└── .zshrc.d/                -> dotfiles/.zshrc.d/
```

## Installation

### Setup

```shell
# Environment variables
export WORKSPACE_DIR=~/workspace
export DOTFILES_DIR=$WORKSPACE_DIR/juliotrigo/dotfiles

# Clone the repository
mkdir -p "$(dirname $DOTFILES_DIR)"
git clone https://github.com/juliotrigo/dotfiles.git $DOTFILES_DIR
```

### Verify Before Setup

Before running any setup scripts, verify what already exists in your home directory:

```shell
# Check all categories
bash $DOTFILES_DIR/scripts/verify-dotfiles.sh

# Check specific categories
bash $DOTFILES_DIR/scripts/verify-dotfiles.sh git
bash $DOTFILES_DIR/scripts/verify-dotfiles.sh git gnupg
```

The script shows the status of each file:
- **SYMLINK -> \<path\>**: Green - Already configured correctly
- **SYMLINK -> \<path\> (wrong target)**: Red - Will be skipped, check if intentional
- **EXISTS (file/directory)**: Red - Will be skipped, backup and remove if you want setup to manage it
- **EXISTS (template)**: Green if matches, yellow if cannot compare (install gettext) or comparison may be inaccurate (set env vars)
- **EXISTS (template differs)**: Red - Generated from template but differs from expected
- **MISSING**: Yellow - Will be created by setup
- **CONFIGURED** (Green) / **PARTIAL** | **NOT CONFIGURED** (Yellow): Configuration check status
- **EXISTS/NOT FOUND** (optional): Green/Yellow - Informational only, not counted in summary

### Claude Code

```shell
bash $DOTFILES_DIR/scripts/setup-claude.sh
```

The script is idempotent and skips existing files/symlinks with warnings.
Use `--dry-run` to preview changes without making them.

For more details, see [.claude/README.md](.claude/README.md).

### Homebrew

Satisfy missing dependencies:

```shell
brew bundle install
```

Other useful commands:

```shell
# List all formulae and casks in the Brewfile
brew bundle list
brew bundle list --cask

# Check whether dependencies are satisfied
brew bundle check --verbose
```

### Git Config

**Prerequisite:** Run `brew bundle install` first. The gitconfig script requires `envsubst` from the `gettext` package.

```shell
bash $DOTFILES_DIR/scripts/setup-git-symlinks.sh

# Replace Your Name and your.email@example.com with your actual git user name and email
GIT_USER_NAME="Your Name" GIT_USER_EMAIL="your.email@example.com" \
    bash $DOTFILES_DIR/scripts/setup-gitconfig.sh

# Enable automatic ticket ID prepending for commits (optional)
git config --global hooks.ticketPrefixes "FR|CVP|CVF|CVR"
```

The symlink script is idempotent and skips existing files/symlinks with warnings.
The gitconfig script creates a backup before overwriting an existing config.
Both scripts support `--dry-run` to preview changes without making them.

For more information about git hooks configuration, see [.git-hooks/README.md](.git-hooks/README.md).

### GnuPG

**Prerequisite:** Run `brew bundle install` first. The gpg-agent config requires `pinentry-mac`.

```shell
# Remove existing config files (they will be replaced with symlinks)
rm ~/.gnupg/gpg.conf ~/.gnupg/gpg-agent.conf ~/.gnupg/dirmngr.conf

bash $DOTFILES_DIR/scripts/setup-gnupg-symlinks.sh

# Reload GPG components to pick up new config
gpgconf --kill gpg-agent
gpgconf --kill dirmngr
gpgconf --launch gpg-agent
gpgconf --launch dirmngr
```

The script is idempotent and skips existing files/symlinks with warnings.
Use `--dry-run` to preview changes without making them.

### Zsh

**Prerequisite:** [Oh My Zsh](https://ohmyz.sh/) must be installed first.

```shell
bash $DOTFILES_DIR/scripts/setup-zsh-symlinks.sh
```

Then add these lines to your `~/.zshrc`:

```shell
# Add BEFORE "source $ZSH/oh-my-zsh.sh":
[[ -f ~/.zshrc.d/omz.zsh ]] && source ~/.zshrc.d/omz.zsh

# Add at the END of the file:
[[ -f ~/.zshrc.d/custom.zsh ]] && source ~/.zshrc.d/custom.zsh
```

Finally, remove the duplicated settings from `~/.zshrc`:
- `ZSH_THEME` and `plugins` (now in `omz.zsh`)
- Any custom configuration that's now in `custom.zsh`

**Local configuration:** For machine-specific or work-specific settings (API keys, internal tools, etc.), create `~/.zshrc.local`. This file is sourced at the end of `custom.zsh` if it exists, and is not tracked in git.

The script is idempotent and skips existing files/symlinks with warnings.
Use `--dry-run` to preview changes without making them.

## Resources

* Unofficial [guide](https://dotfiles.github.io/) to dotfiles on GitHub.
