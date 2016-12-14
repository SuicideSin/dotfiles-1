# .bashrc

# ==============================================================================
# Before
# ==============================================================================

export DKO_SOURCE="${DKO_SOURCE} -> .bashrc {"
source "${HOME}/.dotfiles/shell/vars.sh"
source "${DOTFILES}/shell/before.sh"

# Override HISTFILE for bash
export HISTFILE="${BASH_DOTFILES}/.bash_history"

# ==============================================================================
# Main
# ==============================================================================

# ----------------------------------------------------------------------------
# Options
# ----------------------------------------------------------------------------

set -o notify
shopt -s checkwinsize               # update $LINES and $COLUMNS
shopt -s cmdhist                    # save multi-line commands in one
shopt -s histappend
shopt -s dotglob                    # expand filenames starting with dots too
shopt -s nocaseglob
shopt -s extglob
shopt -s cdspell                    # autocorrect dir names
shopt -s cdable_vars
shopt -s no_empty_cmd_completion    # don't try to complete empty lines

# ----------------------------------------------------------------------------
# Completions
# ----------------------------------------------------------------------------

set completion-ignore-case on

dko::source /etc/bash_completion
dko::source /usr/share/bash-completion/bash_completion

# homebrew's bash-completion package sources the rest of bash_completion.d
dko::source "${BREW_PREFIX}/etc/bash_completion"

dko::source "${NVM_DIR}/bash_completion"

# following are from
# https://github.com/mathiasbynens/dotfiles/blob/master/.bash_profile

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &>/dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
  complete -o default -o nospace -F _git g;
fi

# ==============================================================================
# Plugins
# ==============================================================================

dko::source "${HOME}/.fzf.bash"

# ============================================================================
# Prompt -- needs to be after plugins since it might use them
# ============================================================================

source "${BASH_DOTFILES}/prompt.bash"

# ==============================================================================
# After
# ==============================================================================

source "${DOTFILES}/shell/after.sh"
dko::source "${DOTFILES}/local/bashrc"

export DKO_SOURCE="${DKO_SOURCE} }"
# vim: syn=sh :
