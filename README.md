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
│   └── includes/
│       └── python.md
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
└── scripts/
    ├── lib/
    │   ├── common.sh          # Shared: bash checks, dry-run parsing
    │   └── symlinks.sh        # Shared: symlink creation function
    ├── setup-claude.sh
    ├── setup-git-symlinks.sh
    ├── setup-gitconfig.sh
    ├── setup-gnupg-symlinks.sh
    └── verify-dotfiles.sh     # Check status before setup
```

**Home directory:**
```
~/
├── .claude/
│   ├── CLAUDE.md            -> dotfiles/.claude/CLAUDE.md
│   ├── commands/            -> dotfiles/.claude/commands/
│   └── includes/            -> dotfiles/.claude/includes/
├── .git-hooks/              -> dotfiles/.git-hooks/
├── .gitattributes           -> dotfiles/.gitattributes
├── .gitconfig               # Generated from template
├── .gitignore_global        -> dotfiles/.gitignore_global
├── .gitmessage              -> dotfiles/.gitmessage
└── .gnupg/
    ├── dirmngr.conf         -> dotfiles/.gnupg/dirmngr.conf
    ├── gpg-agent.conf       -> dotfiles/.gnupg/gpg-agent.conf
    └── gpg.conf             -> dotfiles/.gnupg/gpg.conf
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

### Claude Code

```shell
bash $DOTFILES_DIR/scripts/setup-claude.sh
```

The script is idempotent and skips existing files/symlinks with warnings.
Use `--dry-run` to preview changes without making them.

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

## Resources

* Unofficial [guide](https://dotfiles.github.io/) to dotfiles on GitHub.
