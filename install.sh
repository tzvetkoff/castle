#!/bin/bash

#
# this script's path
#

ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

#
# files/directories to install
#

INSTALL=(
  "${HOME}/.bashrc.d:d"

  "${HOME}/.aprc:s:${ROOT}/.aprc"
  "${HOME}/.bash_completion:s:${ROOT}/.bash_completion"
  "${HOME}/.bash_profile:s:${ROOT}/.bash_profile"
  "${HOME}/.bashrc.d/aws:s:${ROOT}/.bashrc.d/aws"
  "${HOME}/.bashrc.d/go:s:${ROOT}/.bashrc.d/go"
  "${HOME}/.bashrc.d/k8s:s:${ROOT}/.bashrc.d/k8s"
  "${HOME}/.bashrc.d/os:s:${ROOT}/.bashrc.d/os"
  "${HOME}/.bashrc.d/ssh-agent:s:${ROOT}/.bashrc.d/ssh-agent"
  "${HOME}/.bashrc:s:${ROOT}/.bashrc"
  "${HOME}/.bin:s:${ROOT}/.bin"
  "${HOME}/.gemrc:s:${ROOT}/.gemrc"
  "${HOME}/.irbrc:s:${ROOT}/.irbrc"
  "${HOME}/.motd:s:${ROOT}/.bin/motd"
  "${HOME}/.pythonrc:s:${ROOT}/.pythonrc"
  "${HOME}/.sqliterc:s:${ROOT}/.sqliterc"
  "${HOME}/.tmux.conf:s:${ROOT}/.tmux.conf"
  "${HOME}/.vimrc:s:${ROOT}/.vimrc"
  "${HOME}/.vim:s:${ROOT}/.vim"
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
# create ~/.gitconfig
#

install_gitconfig() {
  if [[ -e "${HOME}/.gitconfig" ]]; then
    if ! ask "File ${COLOR_WHITE}${HOME}/.gitconfig${COLOR_YELLOW} already exists. Overwrite?"; then
      echo -e "${COLOR_RED}skip${COLOR_WHITE} ${HOME}/.gitconfig"
      return 0
    fi
  fi

  git config --global user.name 'Latchezar Tzvetkoff'
  git config --global user.email 'latchezar'$'\100''tzvetkoff'$'\056''net'
  [[ "${USER}" != 'git' ]] && git config --global core.hooksPath "\$GIT_DIR/hooks-$(od -An -N32 -tx /dev/urandom | tr -d '\n ')"
  git config --global init.defaultBranch 'master'
  git config --global pull.ff 'only'
  git config --global push.autoSetupRemote 'true'
  git config --global color.ui 'true'
  git config --global diff.tool 'vimdiff'
  git config --global difftool.prompt 'false'
  git config --global merge.tool 'vimdiff'
  git config --global mergetool.prompt 'false'
  git config --global difftool.diffpdf.cmd 'diffpdf "$LOCAL" "$REMOTE"'
  git config --global alias.st 'status'
  git config --global alias.ci 'commit'
  git config --global alias.co 'checkout'
  git config --global alias.dt 'difftool'
  git config --global alias.mt 'mergetool'
  git config --global alias.rb 'rubocop'
  git config --global alias.df 'diff --ignore-all-space'
  git config --global alias.lg 'log --color --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
  git config --global alias.diffpdf 'difftool --tool=diffpdf'
  git config --global remote.origin.tagOpt '--tags'
  echo -e "${COLOR_GREEN}create${COLOR_WHITE} ${HOME}/.gitconfig"
}

#
# create ~/.my.cnf
#

install_mycnf() {
  if [[ -e "${HOME}/.my.cnf" ]]; then
    if ! ask "File ${COLOR_WHITE}${HOME}/.my.cnf${COLOR_YELLOW} already exists. Overwrite?"; then
      echo -e "${COLOR_RED}skip${COLOR_WHITE} ${HOME}/.my.cnf"
      return 0
    fi
  fi

  cat >"${HOME}/.my.cnf" <<EOF
[client]
auto-rehash
user=root
local-infile=1
loose-local-infile=1

[mysqldump]
user=root
EOF
  echo -e "${COLOR_GREEN}create${COLOR_WHITE} ${HOME}/.my.cnf"
}

#
# misc stuff
#

install_misc() {
  case "${OSTYPE}" in
    linux-gnu) "${ROOT}/misc/linux/xterm-256color-clear.sh" "${@}";;
    freebsd*)  "${ROOT}/misc/freebsd/termcap.sh" "${@}";;
    darwin*)   "${ROOT}/misc/osx/osx.sh" "${@}";;
  esac
}

#
# run update on first install
#

update_on_install() {
  if [[ ! -d "${ROOT}/.vim/pack/w00t/opt/vim-pathogen" ]]; then
    "${ROOT}/update.sh"
  fi
}

#
# do the actual job
#

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
  install_files
  install_gitconfig
  install_mycnf
  install_misc "${@}"
  update_on_install
fi
