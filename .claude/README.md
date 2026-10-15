# Claude Code Configuration

This directory contains Claude Code configuration files that are symlinked to `~/.claude/`.

## Structure

| Path | Description |
|------|-------------|
| `CLAUDE.md` | Main instructions and rules |
| `agents/` | Custom subagents (dispatched by name via the Agent tool) |
| `commands/` | Custom slash commands |
| `rules/` | Path-filtered rules (auto-loaded) |
| `settings.json` | Plugin configuration (enabled/disabled plugins) |
| `skills/` | Custom skills (invoked by name via the Skill tool) |
| `templates/` | Reference templates (e.g. pandoc reference doc for Markdown→Google Docs conversions, used by the rule in `rules/markdown-to-google-docs.md`) |

## Setup

In [`CLAUDE.md`](CLAUDE.md), update the name references to your own.

## Skills

Unlike the other directories, `skills/` is **not** symlinked as a whole. `~/.claude/skills/` also holds skills installed by other tools (the cubic plugin, peon-ping), so [`setup-claude.sh`](../scripts/setup-claude.sh) links each skill directory in this repo individually and leaves the rest untouched.

To add a skill:

1. Create `skills/<skill-name>/SKILL.md` in this repo (a directory per skill, with front matter declaring `name` and `description`).
2. Run `bash $DOTFILES_DIR/scripts/setup-claude.sh` to link it into `~/.claude/skills/`.

Removing a skill from this repo does not remove the symlink in `~/.claude/skills/`; delete the stale symlink by hand.

### Third-party skills

Some skills come from other repos. Clone them straight into `~/.claude/skills/` and pin them to a reviewed commit. A skill changes how the agent behaves, so read the diff before you move the pin, and never `git pull` blindly.

- [asd-ste100](https://github.com/danyuchn/asd-ste100-skill): rewrites text in ASD-STE100 Simplified Technical English. [`rules/writing.md`](rules/writing.md) says when to use it.

  Install:

  ```shell
  git clone https://github.com/danyuchn/asd-ste100-skill.git ~/.claude/skills/asd-ste100
  git -C ~/.claude/skills/asd-ste100 checkout --detach 3944283c183eea13fe5bd902b572da3b4de8bf44
  ```

  Update:

  ```shell
  git -C ~/.claude/skills/asd-ste100 fetch
  git -C ~/.claude/skills/asd-ste100 diff HEAD origin/master
  git -C ~/.claude/skills/asd-ste100 checkout --detach <new-sha>
  ```

  After an update, change the commit in the install command above.

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
