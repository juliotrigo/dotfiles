# Claude Code Configuration

This directory contains Claude Code configuration files that are symlinked to `~/.claude/`.

## Structure

| Path | Description |
|------|-------------|
| `CLAUDE.md` | Main instructions and rules |
| `commands/` | Custom slash commands |
| `rules/` | Path-filtered rules (auto-loaded) |
| `settings.json` | Plugin configuration (enabled/disabled plugins) |

## Setup

In [`CLAUDE.md`](CLAUDE.md), update the name references to your own.

## Plugins & Marketplaces

Add the superpowers marketplace:

```shell
claude plugins add-marketplace https://github.com/obra/superpowers-marketplace.git
```

Enabled plugins are configured in [`settings.json`](settings.json). Some plugins require OAuth authentication on first use (Sentry, Atlassian).

## State File

Each project uses a state file (`.claude/current-state.local.md`) for tracking context between sessions. See the Session state section in `CLAUDE.md` for details.

## Attribution

Inspiration has been taken from the following places:

- https://github.com/obra/dotfiles
- https://github.com/harperreed/dotfiles
- https://github.com/affaan-m/everything-claude-code
- People at https://github.com/sohonetlabs
