#!/bin/bash

#
# files to symlink @ ~/
#

HOME_SYMLINKS=(\
  .aprc             \
  .bash_profile     \
  .bashrc           \
  .bash_completion  \
  .bin              \
  .gemrc            \
  .irbrc            \
  .nano             \
  .nanorc           \
  .pythonrc         \
  .vimrc            \
  .vim              \
)

# freebsd
[[ ${OSTYPE} = freebsd* ]] && HOME_SYMLINKS=("${HOME_SYMLINKS[@]}" .termcap)

#
# colors
#

COLOR_RED="\033[01;31m"
COLOR_GREEN="\033[01;32m"
COLOR_YELLOW="\033[01;33m"
COLOR_BLUE="\033[01;34m"
COLOR_WHITE="\033[00;00m"

#
# this script's path
#

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#
# force flag
#

if [[ "${1}" = '-f' || "${1}" = '--force' ]]; then
  FORCE='true'
else
  FORCE='false'
fi

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
# symlink files @ ~/
#

create_home_symlinks() {
  for symlink in "${HOME_SYMLINKS[@]}"; do
    if [[ -e "${HOME}/${symlink}" ]]; then
      if ${FORCE} || QUESTION "File ${COLOR_WHITE}${HOME}/${symlink}${COLOR_YELLOW} already exists. Overwrite?"; then
        rm -rf -- "${HOME}/${symlink}"
      else
        echo -e "${COLOR_RED}skip${COLOR_WHITE} ${HOME}/${symlink}"
        continue
      fi
    fi

    echo -e "${COLOR_GREEN}install${COLOR_WHITE} ${HOME}/${symlink}"
    ln -s "${ROOT}/${symlink}" "${HOME}/${symlink}"
  done
}

#
# create ~/.gitconfig
#

create_home_gitconfig() {
  if [[ -e "${HOME}/.gitconfig" ]]; then
    if ! ${FORCE} && ! QUESTION "File ${COLOR_WHITE}${HOME}/.gitconfig${COLOR_YELLOW} already exists. Overwrite?"; then
      echo -e "${COLOR_RED}skip${COLOR_WHITE} ${HOME}/.gitconfig"
      return 0
    fi
  fi

  git config --global core.hooksPath "\$GIT_DIR/hooks-$(od -An -N32 -tx /dev/urandom | tr -d '\n ')"
  git config --global user.name 'Latchezar Tzvetkoff'
  git config --global user.email 'latchezar'$'\100''tzvetkoff'$'\056''net'
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

create_home_mycnf() {
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
# do the actual job
#

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
  create_home_symlinks
  create_home_gitconfig
  create_home_mycnf
fi
