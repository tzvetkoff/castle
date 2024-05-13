#!/bin/bash

#
# this script's path
#

ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

#
# files to symlink
#

INSTALL_SYMLINKS=(\
  "${ROOT}/.termcap:${HOME}/.termcap" \
)

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
# install symlinks
#

install_symlinks() {
  local src_dst
  for src_dst in "${INSTALL_SYMLINKS[@]}"; do
    local src="${src_dst%:*}" dst="${src_dst#*:}"
    if [[ -e "${dst}" ]]; then
      if ask "File ${COLOR_WHITE}${dst}${COLOR_YELLOW} already exists. Overwrite?"; then
        rm -rf -- "${dst}"
      else
        echo -e "${COLOR_RED}skip${COLOR_WHITE} ${dst}"
        continue
      fi
    fi

    echo -e "${COLOR_GREEN}install${COLOR_WHITE} ${dst}"
    ln -s "${src}" "${dst}"
  done
}

#
# do the actual job
#

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
  install_symlinks
fi
