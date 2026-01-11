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
├── .stCommitMsg
└── scripts/
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
└── .stCommitMsg             -> dotfiles/.stCommitMsg
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
ln -s $DOTFILES_DIR/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -s $DOTFILES_DIR/.claude/commands ~/.claude/commands
ln -s $DOTFILES_DIR/.claude/docs ~/.claude/docs
```

**Note**: ensure that the `~/.claude` folder does not contain any of the listed files before
creating the symbolic links.

### Git Config

```shell
ln -s $DOTFILES_DIR/.git-hooks ~/.git-hooks
ln -s $DOTFILES_DIR/.gitattributes ~/.gitattributes
ln -s $DOTFILES_DIR/.gitignore_global ~/.gitignore_global
ln -s $DOTFILES_DIR/.stCommitMsg ~/.stCommitMsg

GIT_USER_NAME="Your Name" GIT_USER_EMAIL="your.email@example.com" $DOTFILES_DIR/scripts/setup-gitconfig.sh
```

**Note**: Replace `Your Name` and `your.email@example.com` with your actual git user name and email.

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
