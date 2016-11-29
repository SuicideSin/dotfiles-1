# .dotfiles/bootstrap/helpers.sh
#
# Helper functions should be sourced by all of the other bootstrapping scripts
# Should be sourced only!
#

# http://serverwizard.heroku.com/script/rvm+git
# added error output to stderr
dkostatus()     { echo -e "\033[0;34m==>\033[0;32m $*\033[0;m"; }
dkostatus_()    { echo -e "\033[0;32m    $*\033[0;m"; }
dkoerr()        { echo -e "\033[0;31m==> \033[0;33mERROR: \033[0;31m$*\033[0;m" >&2; }
dkoerr_()       { echo -e "\033[0;31m    $*\033[0;m" >&2; }

dkousage()        { echo -e "\033[0;34m==> \033[0;34mUSAGE: \033[0;32m$*\033[0;m"; }
dkousage_()       { echo -e "\033[0;29m    $*\033[0;m"; }

dkoinstalling() { dkostatus "Installing \033[0;33m$1\033[0;32m..."; }
dkosymlinking() { dkostatus "Symlinking \033[0;35m$1\033[0;32m -> \033[0;35m$2\033[0;32m "; }
dkodie()        { dkoerr "$*"; exit 256; }

# silently determine existence of executable
has_program() {
  command -v "$1" >/dev/null 2>&1
}

# pipe into this to indent
dkoindent() {
  sed 's/^/    /'
}

##
# require root
dkorequireroot() {
  if [[ "$(whoami)" != "root" ]]; then
    dkodie "Please run as root, these files go into /etc/**/";
  fi
}

##
# require executable
dkorequire() {
  if has_program "$1"; then
    dkostatus "FOUND: $1"
  else
    dkoerr "MISSING: $1"
    dkodie "Please install before proceeding.";
  fi
}

##
# symlinking helper function
dkosymlink() {
  local dotfiles_dir="${HOME}/.dotfiles"
  local dotfile="${dotfiles_dir}/${1}"
  local homefile="$2"
  local homefilepath="${HOME}/${homefile}"

  mkdir -p "$(dirname "$homefilepath")"
  dkosymlinking "$homefile" "$dotfile" && ln -fns "$dotfile" "$homefilepath"
}
