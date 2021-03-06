# zplug.zsh
#
# Loaded by zplug when path assigned to ZPLUG_LOADFILE
#
# Use repo format for oh-my-zsh plugins so no random crap is sourced
#
# Make sure fpaths are defined before or within zplug -- it calls compinit
# again in between loading plugins and defer plugins.
#

# ----------------------------------------------------------------------------
# Mine
# ----------------------------------------------------------------------------

zplug "${ZDOTDIR}", \
  from:local, \
  use:"keybindings.zsh"

# ----------------------------------------------------------------------------
# Vendor
# ----------------------------------------------------------------------------

# zsh hash based directory bookmarking
zplug "davidosomething/cdbk"

zplug "plugins/colored-man-pages", from:oh-my-zsh

# In-line best history match suggestion
zplug "zsh-users/zsh-autosuggestions"

# Various program completions
# This adds to fpath (so before compinit)
zplug "zsh-users/zsh-completions"

# Pure prompt
zplug "mafredri/zsh-async"
zplug "sindresorhus/pure", use:pure.zsh, as:theme

# ----------------------------------------------------------------------------
# LAST, these call "compdef" so must be run after compinit, enforced by defer
# ----------------------------------------------------------------------------

# fork of rupa/z with better completion (so needs defer)
zplug "knu/z",  \
  use:"z.sh",   \
  defer:2

# Moved if block outside since `zplug check` doesn't consider it
if [[ $OSTYPE == "darwin"* ]]; then
  zplug "vasyharan/zsh-brew-services",  \
    defer:2
fi

# highlight as you type
# absolute last
zplug "zsh-users/zsh-syntax-highlighting", defer:3
