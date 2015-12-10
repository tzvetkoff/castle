#!/bin/bash

#
# files to install
#

H=(\
  .aprc           \
  .bash_profile   \
  .bashrc         \
  .bin            \
  .gemrc          \
  .irbrc          \
  .my.cnf         \
  .nano           \
  .nanorc         \
  .pythonrc       \
  .vimrc          \
  .vim            \
)

#
# colors
#

R="\033[01;31m"
G="\033[01;32m"
Y="\033[01;33m"
B="\033[01;34m"
W="\033[00;00m"

#
# this script's path
#

P=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

#
# force?
#
if [[ "${1}" = "-f" || "${1}" = "--force" ]]; then
  F="yes"
else
  F=""
fi

#
# question? [Y/n]
#

Q() {
  echo -ne "${Y}${*} ${B}[Y/n]${W} "
  read -n 1 -r
  echo
  if [[ ${REPLY} =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

#
# install files in ${HOME}
#

pushd ${HOME} >/dev/null
for z in ${H[@]}; do
  if [[ -e ./${z} ]]; then
    if [[ -n ${F} ]] || Q "File ${W}${HOME}/${z}${Y} already exists. Overwrite?"; then
      rm -rf -- ${z}
    else
      echo -e "${R}skip${W} ${z}"
      continue
    fi
  fi

  echo -e "${G}install${W} ${z}"
  ln -s ${P}/${z} ./${z}
done
popd >/dev/null

#
# configure git
#

git config --global user.name 'Latchezar Tzvetkoff'
git config --global user.email 'latchezar'$'\100''tzvetkoff'$'\056''net'
git config --global alias.st 'status'
git config --global alias.ci 'commit'
git config --global alias.co 'checkout'
git config --global alias.dt 'difftool'
git config --global alias.mt 'mergetool'
