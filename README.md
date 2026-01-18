# Configuration files

My dotfiles.

## Structure

**Dotfiles repo:**
```
dotfiles/
├── .claude/
│   ├── CLAUDE.md
│   ├── commands/
│   │   └── release.md
│   └── docs/
├── .git-hooks/
│   ├── README.md
│   ├── hook-wrapper
│   └── ... (symlinks)
├── .gitattributes
├── .gitconfig.template
├── .gitignore_global
├── .gitmessage
└── scripts/
    ├── lib/
    │   ├── common.sh          # Shared: bash checks, dry-run parsing
    │   └── symlinks.sh        # Shared: symlink creation function
    ├── setup-claude.sh
    ├── setup-git-symlinks.sh
    └── setup-gitconfig.sh
```

**Home directory:**
```
~/
├── .claude/
│   ├── CLAUDE.md            -> dotfiles/.claude/CLAUDE.md
│   ├── commands/            -> dotfiles/.claude/commands/
│   └── docs/                -> dotfiles/.claude/docs/
├── .git-hooks/              -> dotfiles/.git-hooks/
├── .gitattributes           -> dotfiles/.gitattributes
├── .gitconfig               # Generated from template
├── .gitignore_global        -> dotfiles/.gitignore_global
└── .gitmessage              -> dotfiles/.gitmessage
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

## Resources

* Unofficial [guide](https://dotfiles.github.io/) to dotfiles on GitHub.
