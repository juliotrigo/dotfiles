# Claude Code Configuration

This directory contains Claude Code configuration files that are symlinked to `~/.claude/`.

## Structure

| Path | Description |
|------|-------------|
| `CLAUDE.md` | Main instructions and rules |
| `commands/` | Custom slash commands |
| `includes/` | Additional configuration loaded per-project |

## Setup

In [`CLAUDE.md`](CLAUDE.md), update the name references to your own.

## Project Configuration

Each project can have a `CLAUDE.local.md` file to specify project-specific settings:

```markdown
# Local Project Configuration

State file: `.claude/current-state.local.md`

Includes: python
```

### State file

The state file is for tracking whatever context is useful between sessions (status, pending tasks, recent changes, notes, etc.). Claude reads it at session start and updates it after completing work.

### Includes

Additional configuration files loaded per-project. These can contain patterns for languages, frameworks, libraries, or other project-specific rules.

**Available includes:**

| File | Description |
|------|-------------|
| `python.md` | uv, ruff, pytest fixtures, mock patterns, assertion patterns |

**Adding new includes:**

1. Create a new file in `includes/` (e.g., `javascript.md`, `django.md`, `react.md`)
2. Add rules and patterns
3. Update this README
4. Reference it in project `CLAUDE.local.md` files

## Attribution

Inspiration has been taken from the following places:

- https://github.com/obra/dotfiles
- https://github.com/harperreed/dotfiles
- People at https://github.com/sohonetlabs
