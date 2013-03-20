#!/bin/bash

#
# files to install in ${HOME}
#

H=(\
	.aprc						\
	.bash_profile				\
	.bashrc						\
	.bin						\
	.gemrc						\
	.motd						\
	.my.cnf						\
	.nano						\
	.nanorc						\
	.vimrc						\
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
		if ! Q "File ${W}${HOME}/${z}${Y} already exists. Overwrite?"; then
			echo -e "${R}skip${W} ${z}"
			continue
		fi
	fi

	echo "${G}install${W} ${z}"
	ln -s ${P}/home/${z} ./${z}
done
popd >/dev/null
