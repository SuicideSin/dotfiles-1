# .dotfiles/shell/dotfiles.bash
#
# Update dotfiles and provide instructions for updating the system
# THIS FILE IS SOURCED to give access to current shell
#

# ==============================================================================
# Command functions
# ==============================================================================

# ------------------------------------------------------------------------------
# Meta
# ------------------------------------------------------------------------------

dko::dotfiles::__usage() {
  dko::usage  "u <command>"
  echo "
  Utility Commands
    dotfiles    -- update dotfiles (git pull); then reload; then zplug
    reload      -- reload this script if it was modified
    secret      -- update ~/.secret (git pull)
    zplug       -- update zplug
    daily       -- update everything except dotfiles and apt/brew/pac

  Shell Tools
    fzf         -- update fzf with flags to not update rc scripts
    node        -- install latest node via nvm
    nvm         -- update nvm installation

  Packages
    gem         -- update rubygems and global gems for current ruby
    pip         -- update all versions of pip (OS dependent)

  Arch Linux
    arch        -- update arch packages

  Debian/Ubuntu
    deb         -- update apt packages

  macOS/OS X
    brew        -- homebrew packages
    mac         -- repair permissions and check software updates
    macvim      -- install latest brew macvim
    neovim      -- install latest brew neovim/neovim on HEAD
"
}

dko::dotfiles::__reload() {
  . "${DOTFILES}/shell/dotfiles.bash" \
    && dko::status "Reloaded shell/dotfiles.bash"
}

dko::dotfiles::__update() {
  dko::status "Updating dotfiles"
  ( cd "$DOTFILES" || { dko::err "No \$DOTFILES directory" && exit 1; }
    git pull --rebase || exit 1
    git log --no-merges --abbrev-commit --oneline ORIG_HEAD..
    dko::status "Updating dotfiles submodules"
    git submodule update --init || exit 1
  ) || {
    dko::err "Error updating dotfiles"
    return 1
  }

  dko::dotfiles::__reload
  dko::status "Re-symlink if any dotfiles changed!"

  dko::dotfiles::__update_zplug
}

dko::dotfiles::__update_zplug() {
  dko::status "Updating zplug"
  ( cd "${ZPLUG_HOME}" || { dko::err "No \$ZPLUG_HOME" && exit 1; }
    git pull || exit 1
    git log --no-merges --abbrev-commit --oneline ORIG_HEAD..
    dko::status "Restart the shell to ensure a clean zplug init"
  ) || return 1

  [ -n "$ZSH_VERSION" ] && dko::has "zplug" && {
    dko::status "Updating plugins managed by zplug"

    if ! zplug check; then
      dko::status "Installing zplug plugins"
      zplug install
    fi

    zplug update
  }
}

dko::dotfiles::__update_secret() {
  dko::status "Updating secret"
  ( cd "${HOME}/.secret" || dko::err "No ~/.secret directory"
    git pull --rebase --recurse-submodules \
    && git log --no-merges --abbrev-commit --oneline ORIG_HEAD.. \
    && git submodule update --init
  )
}

dko::dotfiles::__update_daily() {
  dko::dotfiles::__update_secret
  dko::dotfiles::__update_fzf
  dko::dotfiles::__update_gems
  dko::dotfiles::__update_nvm
  dko::dotfiles::__update_pip "pip"
}

# ------------------------------------------------------------------------------
# Private utilities
# ------------------------------------------------------------------------------

dko::dotfiles::__pyenv_system() {
  # switch to brew's python (fallback to system if no brew python)
  dko::has "pyenv" \
    && echo \
    && dko::status "Switching to system python to upgrade brew packages" \
    && pyenv shell system
}

# probably don't need this as long as running updates in subshells
dko::dotfiles::__pyenv_global() {
  dko::has "pyenv" \
    && echo \
    && dko::status_ "Switching back to global python" \
    && pyenv shell --unset
}

# ------------------------------------------------------------------------------
# Externals
# ------------------------------------------------------------------------------

dko::dotfiles::__update_fzf() {
  dko::status "Updating fzf"

  [ -x "/usr/local/bin/fzf" ] \
    && dko::status "fzf was installed via brew (BAD, vim expects in ~/.fzf)" \
    && return 1

  ( cd "${HOME}/.fzf" || { dko::err "Could not cd to ~/.fzf" && exit 1; }
    git pull || { dko::err "Could not update ~/.fzf" && exit 1; }
    git log --no-merges --abbrev-commit --oneline ORIG_HEAD..
    ./install --key-bindings --completion --no-update-rc
  ) || return 1
}

dko::dotfiles::__update_gems() {
  dko::status "Updating gems"
  (
    [ -z "$RUBY_VERSION" ] && {
      dko::err "System ruby detected! Use chruby."
      exit 1
    }

    dko::has "gem" || {
      dko::err "rubygems is not installed"
      exit 1
    }

    dko::status "Updating RubyGems itself for ruby: ${RUBY_VERSION}"
    gem update --system  || {
      dko::err "Could not update RubyGems"
      exit 1
    }

    gem update || { dko::err "Could not update gems" && exit 1; }
  ) || return 1
}

dko::dotfiles::__update_node() {
  local desired_node="v4"
  local desired_node_minor
  local previous_node

  . "${NVM_DIR}/nvm.sh"
  dko::status "Checking node versions..."
  desired_node_minor="$(nvm version-remote "$desired_node")"
  previous_node="$(nvm current)"

  dko::status_ "Previous node version was $previous_node"
  if [ "$desired_node_minor" != "$previous_node" ]; then
    echo -n "Install and use new node ${desired_node_minor} as default? [y/N] "
    read -r
    echo
    if [ "$REPLY" = "y" ]; then
      nvm install             "$desired_node"
      nvm alias default       "$desired_node"

      dko::status_ "Installing npm@latest for $desired_node_minor..."
      npm install --global npm@latest
      rehash

      dko::status "Node and npm updated."
      dko::status_ "Run \$DOTFILES/node/install.sh to install global packages."
    fi
  else
    dko::status_ "Node version is already up-to-date."
  fi
}

dko::dotfiles::__update_nvm() {
  (
    if [ ! -d "$NVM_DIR" ]; then
      dko::status "Installing nvm"
      git clone https://github.com/creationix/nvm.git "$NVM_DIR" \
        || dko::err "Could not install nvm" && exit 1
    fi

    dko::status "Updating nvm"
    cd "$NVM_DIR" \
      || dko::err "Could not cd to \$NVM_DIR at $NVM_DIR" && exit 1
    readonly previous_nvm="$(git describe --abbrev=0 --tags)"

    dko::status "Fetching latest nvm"
    {
      git checkout master
      git pull --ff-only
      git log --no-merges --abbrev-commit --oneline ORIG_HEAD..
    } \
      || dko::err "Could not fetch" && exit 1
    readonly latest_nvm="$(git describe --abbrev=0 --tags)"

    # Already up to date
    [ "$previous_nvm" = "$latest_nvm" ] && exit

    dko::status "Fast-forwarding to latest nvm"
    git checkout --quiet --progress "$latest_nvm" \
      || dko::err "Could not fast-forward" && exit 1

    # Updated
    exit 3
  )

  case "$?" in
    3)    dko::status "Reloading nvm"
          . "$NVM_DIR/nvm.sh"
          return $?
          ;;
    256)  dko::err "Could not update nvm"
          return 1
          ;;
  esac

  dko::status "Already at latest nvm"
  return 0
}

# $1 pip command (e.g. `pip2`)
dko::dotfiles::__update_pip() {
  local pip_command=${1:-pip}
  dko::status "Updating $pip_command"
  if dko::has "$pip_command"; then
    $pip_command install --upgrade setuptools || return 1
    $pip_command install --upgrade pip        || return 1
    $pip_command install --upgrade \
      --requirement "${DOTFILES}/python/requirements.txt"
  fi
}

# ------------------------------------------------------------------------------
# OS-specific commands
# ------------------------------------------------------------------------------

dko::dotfiles::linux::__update() {
  case "$1" in
    arch) dko::dotfiles::linux::arch::__update ;;
    deb)  dko::dotfiles::linux::deb::__update ;;
  esac

  return $?
}

dko::dotfiles::darwin::__update() {
  case "$1" in
    brew)   dko::dotfiles::darwin::__update_brew        ;;
    macvim) dko::dotfiles::darwin::__update_brew_macvim ;;
    neovim) dko::dotfiles::darwin::__update_brew_neovim ;;
    mac)    dko::dotfiles::darwin::__update_mac         ;;
    all)    dko::dotfiles::darwin::__update_all         ;;
  esac

  return $?
}

# ------------------------------------------------------------------------------
# OS: GNU/Linux: Arch Linux
# ------------------------------------------------------------------------------

dko::dotfiles::linux::arch::__update() {
  dko::status "Arch Linux system update"
  if dko::has "pacaur"; then
    # update system
    pacaur -Syu
  elif dko::has "yaourt"; then
    # -Sy         -- get new file list
    yaourt --sync --refresh
    yaourt -Syua
  elif dko::has "aura"; then
    aura -Syua
  else
    pacman -Syu
  fi
}

# ------------------------------------------------------------------------------
# OS: GNU/Linux: Debian or Ubuntu
# ------------------------------------------------------------------------------

dko::dotfiles::linux::deb::__update() {
  dko::status "Apt system update"

  if ! dko::has "apt"; then
    dko::err "Plain 'apt' not found, manually use 'apt-get' for crappy systems."
    return 1
  fi

  sudo apt update

  # This is for home systems only! Removes unused stuff, same as
  # `apt-get dist-upgrade`
  sudo apt full-upgrade
}

# ------------------------------------------------------------------------------
# OS: macOS/OS X
# ------------------------------------------------------------------------------

dko::dotfiles::darwin::__update_mac() {
  dko::status "macOS system update"
  sudo softwareupdate --install --all || {
    dko::err "Error updating software permissions"
    return 1
  }

  dko::has "mas" && mas upgrade
}

dko::dotfiles::darwin::__update_brew_done() {
  dko::status "Cleanup old versions and prune dead symlinks"
  brew cleanup
  brew cask cleanup
  brew prune
  rehash
}

dko::dotfiles::darwin::__update_brew() {
  dko::status "Updating homebrew"
  (
    dko::has "brew" || { dko::err "Homebrew is not installed." && exit 1; }

    # enter dotfiles dir to do this in case user has any gem flags or local
    # vendor bundle that will cause use of local gems
    cd "$DOTFILES" \
      || {
        dko::err "Can't enter \$DOTFILES to run brew in clean environment"
        exit 1
      }

    brew update

    # check if needed
    readonly outdated="$(brew outdated --quiet)"
    [ -z "$outdated" ] && exit

    # CLEANROOM
    dko::dotfiles::__pyenv_system
    # Brew some makefiles like macvim use tput for output so need to reset
    # from xterm-256color-italic I use in iterm
    TERM="xterm-256color"

    # Detect if brew's python3 (not pyenv) was outdated
    # Reinstall macvim (in another sub-shell) with new python3 if needed
    grep -q "python3" <<<"$outdated" \
      && dko::status "Python3 was outdated, upgrading python3" \
      && brew upgrade python3  \
      && brew linkapps python3 \
      && dko::status "Rebuilding macvim with new python3" \
      && dko::dotfiles::darwin::__update_brew_macvim

    # Update neovim separately
    grep -q "neovim" <<<"$outdated"      \
      && dko::status "Neovim was outdated"  \
      && dko::dotfiles::darwin::__update_brew_neovim

    # Upgrade remaining
    dko::status "Upgrading packages"
    brew upgrade
  ) && dko::dotfiles::darwin::__update_brew_done
}

dko::dotfiles::darwin::__require_homebrew() {
  dko::has "brew" || {
    dko::err "Homebrew is not installed."
    exit 1
  }
}

dko::dotfiles::darwin::__update_brew_macvim() {
  dko::status "Re-installing macvim via homebrew (brew update first to upgrade)"
  (
    dko::dotfiles::darwin::__require_homebrew

    # enter dotfiles dir to do this in case user has any gem flags or local
    # vendor bundle that will cause use of local gems
    cd "$DOTFILES" \
      || dko::err "Can't enter \$DOTFILES to run brew in clean environment" \
      && exit 1

    # CLEANROOM
    dko::dotfiles::__pyenv_system
    TERM=xterm-256color

    brew reinstall macvim --with-lua --with-override-system-vim --with-python3 \
      && dko::status "Linking new macvim.app" \
      && brew linkapps macvim
  )
}

dko::dotfiles::darwin::__update_brew_neovim() {
  dko::status "Re-installing neovim via homebrew (brew update first to upgrade)"
  (
    dko::dotfiles::darwin::__require_homebrew

    # enter dotfiles dir to do this in case user has any gem flags or local
    # vendor bundle that will cause use of local gems
    cd "$DOTFILES" || {
      dko::err "Can't enter \$DOTFILES to run brew in clean environment"
      exit 1
    }

    # CLEANROOM
    dko::dotfiles::__pyenv_system
    TERM=xterm-256color

    brew reinstall --HEAD --with-release neovim
  )
}

# ==============================================================================
# Main
# ==============================================================================

# $1 command
dko::dotfiles() {
  if [ $# -eq 0 ]; then
    dko::dotfiles::__usage
    return 1
  fi

  case $1 in
    reload)   dko::dotfiles::__reload           ;;
    dotfiles) dko::dotfiles::__update           ;;
    secret)   dko::dotfiles::__update_secret    ;;
    zplug)    dko::dotfiles::__update_zplug     ;;
    daily)    dko::dotfiles::__update_daily     ;;
    composer) dko::dotfiles::__update_composer  ;;
    fzf)      dko::dotfiles::__update_fzf       ;;
    gem)      dko::dotfiles::__update_gems      ;;
    go)       dko::dotfiles::__update_go        ;;
    node)     dko::dotfiles::__update_node      ;;
    nvm)      dko::dotfiles::__update_nvm       ;;
    pip)      dko::dotfiles::__update_pip "pip" ;;
    vimlint)  dko::dotfiles::__update_vimlint   ;;
    wpcs)     dko::dotfiles::__update_wpcs      ;;

    *)
      case "$OSTYPE" in
        linux*)   dko::dotfiles::linux::__update "$1" ;;
        darwin*)  dko::dotfiles::darwin::__update "$1" ;;
      esac
  esac

  return $?
}

# vim: ft=sh :
