#!/bin/bash

#
# force flags
#

FORCE_YES='false'
FORCE_NO='false'

for ARG; do
  if [[ "${ARG}" = '-f' || "${ARG}" = '--force' || "${ARG}" = '--force-yes' ]]; then
    FORCE_YES='true'
  elif [[ "${ARG}" = '-n' || "${ARG}" = '--no' || "${ARG}" = '--force-no' ]]; then
    FORCE_NO='true'
  fi
done

#
# colors
#

COLOR_RED="\033[01;31m"
COLOR_GREEN="\033[01;32m"
COLOR_YELLOW="\033[01;33m"
COLOR_BLUE="\033[01;34m"
COLOR_WHITE="\033[00;00m"

#
# ask? [y/N]
#

ask() {
  echo -ne "${COLOR_YELLOW}${*} ${COLOR_BLUE}[y/N]${COLOR_WHITE} "

  if ${FORCE_YES}; then
    echo 'y'
    return 0
  fi
  if ${FORCE_NO}; then
    echo 'n'
    return 1
  fi

  read -n 1 -r
  echo

  if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

#
# recompile xterm-256color terminfo entry
#

install_xterm_256color() {
  if [[ -e "${HOME}/.terminfo/x/xterm-256color" ]]; then
    if ask "File ${COLOR_WHITE}${HOME}/.terminfo/x/xterm-256color${COLOR_YELLOW} already exists. Overwrite?"; then
      rm -rf -- "${HOME}/.terminfo/x/xterm-256color"
    else
      echo -e "${COLOR_RED}skip${COLOR_WHITE} ${HOME}/.terminfo/x/xterm-256color"
      return
    fi
  fi

  echo -e "${COLOR_GREEN}create${COLOR_WHITE} ${HOME}/.terminfo/x/xterm-256color"
  infocmp -1 xterm-256color | sed 's/clear=[^,]*,/clear=\\E[H\\E[2J\\E[3J,/' | tic -
}

#
# do the actual job
#

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
  install_xterm_256color
fi
