# Custom Zsh Configuration
# Sourced at the END of ~/.zshrc (after oh-my-zsh.sh loads)

# Virtualenv prompt customization (prepend colored venv name to prompt)
ZSH_THEME_VIRTUALENV_PREFIX="%B%F{#FFB86C}("
ZSH_THEME_VIRTUALENV_SUFFIX=")%f%b "
PROMPT='$(virtualenv_prompt_info)'"$PROMPT"

# Language
export LANG=en_US.UTF-8

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"

# fzf
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# uv
. "$HOME/.local/bin/env"
export UV_PROJECT_ENVIRONMENT=".venv"
eval "$(uv generate-shell-completion zsh)"

# Ruby
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.4.7

# Claude Code
# Run Claude Code with the Node version it was installed on, regardless of the currently active one.
# This allows using Claude Code while working in projects that require other Node versions.
claude() {
  nvm exec 22.20.0 -- claude "$@"
}

# PostgreSQL
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Local configuration (not tracked in git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
