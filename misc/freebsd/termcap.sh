#!/bin/bash

#
# this script's path
#

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#
# files to symlink
#

INSTALL_SYMLINKS=(\
  "${ROOT}/.termcap:${HOME}/.termcap" \
)

#
# force flag
#

if [[ "${1}" = '-f' || "${1}" = '--force' ]]; then
  FORCE='true'
else
  FORCE='false'
fi

#
# colors
#

COLOR_RED="\033[01;31m"
COLOR_GREEN="\033[01;32m"
COLOR_YELLOW="\033[01;33m"
COLOR_BLUE="\033[01;34m"
COLOR_WHITE="\033[00;00m"

#
# question? [y/N]
#

QUESTION() {
  echo -ne "${COLOR_YELLOW}${*} ${COLOR_BLUE}[y/N]${COLOR_WHITE} "
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
      if ${FORCE} || QUESTION "File ${COLOR_WHITE}${dst}${COLOR_YELLOW} already exists. Overwrite?"; then
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
