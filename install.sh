#!/bin/bash

#
# this script's path
#

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#
# dirs to create
#

INSTALL_DIRS=(\
  "${HOME}/.bashrc.d" \
)

#
# files to symlink
#

INSTALL_SYMLINKS=(\
  "${ROOT}/.aprc:${HOME}/.aprc"                       \
  "${ROOT}/.bash_completion:${HOME}/.bash_completion" \
  "${ROOT}/.bash_profile:${HOME}/.bash_profile"       \
  "${ROOT}/.bashrc.d/go:${HOME}/.bashrc.d/go"         \
  "${ROOT}/.bashrc.d/k8s:${HOME}/.bashrc.d/k8s"       \
  "${ROOT}/.bashrc:${HOME}/.bashrc"                   \
  "${ROOT}/.bin:${HOME}/.bin"                         \
  "${ROOT}/.gemrc:${HOME}/.gemrc"                     \
  "${ROOT}/.irbrc:${HOME}/.irbrc"                     \
  "${ROOT}/.pythonrc:${HOME}/.pythonrc"               \
  "${ROOT}/.tmux.conf:${HOME}/.tmux.conf"             \
  "${ROOT}/.vim:${HOME}/.vim"                         \
  "${ROOT}/.vimrc:${HOME}/.vimrc"                     \
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
# install dirs
#

install_dirs() {
  local dir
  for dir in "${INSTALL_DIRS[@]}"; do
    echo -e "${COLOR_GREEN}mkdir${COLOR_WHITE} ${dir}"
    mkdir -p "${dir}"
  done
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
# create ~/.gitconfig
#

install_gitconfig() {
  if [[ -e "${HOME}/.gitconfig" ]]; then
    if ! ${FORCE} && ! QUESTION "File ${COLOR_WHITE}${HOME}/.gitconfig${COLOR_YELLOW} already exists. Overwrite?"; then
      echo -e "${COLOR_RED}skip${COLOR_WHITE} ${HOME}/.gitconfig"
      return 0
    fi
  fi

  git config --global user.name 'Latchezar Tzvetkoff'
  git config --global user.email 'latchezar'$'\100''tzvetkoff'$'\056''net'
  [[ "${USER}" != 'git' ]] && git config --global core.hooksPath "\$GIT_DIR/hooks-$(od -An -N32 -tx /dev/urandom | tr -d '\n ')"
  git config --global pull.ff 'only'
  git config --global color.ui 'true'
  git config --global alias.st 'status'
  git config --global alias.ci 'commit'
  git config --global alias.co 'checkout'
  git config --global alias.dt 'difftool'
  git config --global alias.mt 'mergetool'
  git config --global alias.rb 'rubocop'
  git config --global alias.df 'diff --ignore-all-space'
  git config --global alias.lg 'log --color --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
  echo -e "${COLOR_GREEN}create${COLOR_WHITE} ${HOME}/.gitconfig"
}

#
# create ~/.my.cnf
#

install_mycnf() {
  if [[ -e "${HOME}/.my.cnf" ]]; then
    if ! ${FORCE} && ! QUESTION "File ${COLOR_WHITE}${HOME}/.my.cnf${COLOR_YELLOW} already exists. Overwrite?"; then
      echo -e "${COLOR_RED}skip${COLOR_WHITE} ${HOME}/.my.cnf"
      return 0
    fi
  fi

  cat >"${HOME}/.my.cnf" <<EOF
[mysql]
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
    linux-gnu)
      "${ROOT}/misc/linux/xterm-256color-clear.sh"
      ;;
    freebsd*)
      "${ROOT}/misc/freebsd/termcap.sh"
      ;;
    darwin*) :
      "${ROOT}/misc/osx/osx.sh"
      ;;
  esac
}

#
# do the actual job
#

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
  install_dirs
  install_symlinks
  install_gitconfig
  install_mycnf
  install_misc
fi
