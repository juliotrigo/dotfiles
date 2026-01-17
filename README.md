# Configuration files

My dotfiles.

## Structure

**Dotfiles repo:**
```
dotfiles/
├── .claude/
│   ├── CLAUDE.md
│   ├── commands/
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

### Git Config

```shell
bash $DOTFILES_DIR/scripts/setup-git-symlinks.sh

GIT_USER_NAME="Your Name" GIT_USER_EMAIL="your.email@example.com" \
    bash $DOTFILES_DIR/scripts/setup-gitconfig.sh
```

The symlink script is idempotent and skips existing files/symlinks with warnings.
The gitconfig script creates a backup before overwriting an existing config.
Both scripts support `--dry-run` to preview changes without making them.

Replace `Your Name` and `your.email@example.com` with your actual git user name and email.

For more information about git hooks configuration, see [.git-hooks/README.md](.git-hooks/README.md).

### Homebrew

Get a list of all the formulae and casks in the Brewfile:

```shell
brew bundle list
brew bundle list --cask
```

Check whether the Brewfile's dependencies are satisfied:

```shell
brew bundle check --verbose
```

Satisfy missing dependencies:

```shell
brew bundle install
```

## Resources

* Unofficial [guide](https://dotfiles.github.io/) to dotfiles on GitHub.
