# Configuration files

My dotfiles.

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

## Resources

* Unofficial [guide](https://dotfiles.github.io/) to dotfiles on GitHub.
