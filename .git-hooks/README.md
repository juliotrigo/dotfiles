# Global Git Hooks

This directory contains global git hooks that apply to all repositories.

## Structure

```
~/.git-hooks/
├── README.md              # Documentation
├── hook-wrapper           # Main script (must be executable)
├── commit-msg             -> hook-wrapper
├── post-checkout          -> hook-wrapper
├── post-merge             -> hook-wrapper
├── pre-commit             -> hook-wrapper
├── pre-push               -> hook-wrapper
└── prepare-commit-msg     -> hook-wrapper
```

## How It Works

Git is configured to use this directory for hooks:

```bash
git config --global core.hooksPath ~/.git-hooks
```

A single `hook-wrapper` script handles all hooks. Individual hook names are symlinks to this script. The wrapper:

1. Detects which hook is being called (via `$0`)
2. Runs any custom logic defined for that hook
3. Calls the local `.git/hooks/<hook>` if it exists (pass-through)

This allows global hooks to coexist with project-specific local hooks.

## Current Hook Behavior

### prepare-commit-msg: Ticket ID Prepending

Automatically prepends ticket IDs to commit messages based on branch name. This feature is opt-in.

**Enable:**

```bash
git config --global hooks.ticketPrefixes "ABC|DEF|GHI"
```

**Disable:**

```bash
git config --global hooks.ticketPrefixes ""
```

See `hook-wrapper` comments for examples and details.

## Permissions

- `hook-wrapper` must be executable: `chmod +x hook-wrapper`
- Symlinks do not need explicit permissions (they inherit from their target)
- Local hooks (`.git/hooks/<hook>`) must also be executable to run

## Adding a New Hook Symlink

To enable pass-through for another hook type:

```bash
cd ~/.git-hooks
ln -s hook-wrapper <hook-name>
```

For example, to add `pre-rebase`:

```bash
ln -s hook-wrapper pre-rebase
```

## Adding Custom Logic for a Hook

Edit `hook-wrapper` and add a case block:

```bash
case "$HOOK_NAME" in
    prepare-commit-msg)
        prepend_ticket_id "$1" "$2"
        ;;
    pre-push)
        # Add your custom pre-push logic here
        my_pre_push_function "$@"
        ;;
esac
```

## All Available Git Hooks

For reference, these are all available git hooks. Only the commonly used ones currently have symlinks:

```
applypatch-msg       post-applypatch      post-checkout
post-commit          post-index-change    post-merge
post-receive         post-rewrite         post-update
pre-applypatch       pre-auto-gc          pre-commit
pre-merge-commit     pre-push             pre-rebase
pre-receive          prepare-commit-msg   commit-msg
push-to-checkout     reference-transaction
update               proc-receive
sendemail-validate   fsmonitor-watchman
p4-changelist        p4-prepare-changelist
p4-post-changelist   p4-pre-submit
```

## Troubleshooting

**Local hooks not running:**
Ensure the local hook is executable: `chmod +x .git/hooks/<hook-name>`

**Check current hooks path:**
```bash
git config --global core.hooksPath
```

**Temporarily disable global hooks for a repo:**
```bash
git config core.hooksPath .git/hooks
```

**Re-enable global hooks for a repo:**
```bash
git config --unset core.hooksPath
```
