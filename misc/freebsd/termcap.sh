#!/bin/bash

#
# this script's path
#

ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

#
# files/directories to install
#

INSTALL=(
  "${HOME}/.termcap:s:${ROOT}/.termcap"
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
# helper to install a directory
#

install_dir() {
  local dir="${1}"

  if [[ -d "${dir}" ]]; then
    echo -e "${COLOR_RED}skip${COLOR_WHITE} ${dir}"
  else
    echo -e "${COLOR_GREEN}mkdir${COLOR_WHITE} ${dir}"
    mkdir -p "${dir}"
  fi
}

#
# helper to install a file
#

install_file() {
  local dst="${1}" src="${2}"

  if [[ -e "${dst}" ]]; then
    if ask "File ${COLOR_WHITE}${dst}${COLOR_YELLOW} already exists. Overwrite?"; then
      rm -rf -- "${dst}"
    else
      echo -e "${COLOR_RED}skip${COLOR_WHITE} ${dst}"
      return
    fi
  fi

  echo -e "${COLOR_GREEN}install${COLOR_WHITE} ${dst}"
  cp -f "${src}" "${dst}"
}

#
# helper to install a symlink
#

install_symlink() {
  local dst="${1}" src="${2}"

  if [[ -e "${dst}" ]]; then
    if ask "File ${COLOR_WHITE}${dst}${COLOR_YELLOW} already exists. Overwrite?"; then
      rm -rf -- "${dst}"
    else
      echo -e "${COLOR_RED}skip${COLOR_WHITE} ${dst}"
      return
    fi
  fi

  echo -e "${COLOR_GREEN}install${COLOR_WHITE} ${dst}"
  ln -s "${src}" "${dst}"
}

#
# install files/directories
#

install_files() {
  local spec arr
  for spec in "${INSTALL[@]}"; do
    IFS=':' read -ra arr <<< "${spec}"

    case "${arr[1]}" in
      d) install_dir "${arr[0]}";;
      f) install_file "${arr[0]}" "${arr[2]}";;
      s) install_symlink "${arr[0]}" "${arr[2]}";;
      *) echo "${0}: bad install spec: ${spec}" >&2; exit 1;;
    esac
  done
}

#
# do the actual job
#

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
  install_files
fi
