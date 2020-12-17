#!/bin/bash

set -e

#
# This script's path
#

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#
# Some colors
#

reset="\033[0m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"

#
# Walk modules.txt and install/update each module
#

while read -r remote local branch; do
  if [[ -d "${root}/${local}" && -d "${root}/${local}/.git" ]]; then
    pushd "${root}/${local}" >/dev/null

    remote="$(git remote get-url origin)"
    echo -e "-> Updating ${green}${local}${reset} from ${red}${remote}${reset}${branch:+ (${yellow}${branch}${reset})}"

    if [[ -n "${branch}" ]]; then
      git checkout "${branch}" && git pull origin "${branch}"
    else
      git pull origin
    fi

    popd >/dev/null
    echo
  else
    echo -e "-> Fetching ${green}${local}${reset} from ${red}${remote}${reset}${branch:+ (${yellow}${branch}${reset})}"

    if [[ -n "${branch}" ]]; then
      git clone "${remote}" --depth 1 --branch "${branch}" "${root}/${local}"
    else
      git clone "${remote}" --depth 1 "${root}/${local}"
    fi

    echo
  fi
done < "${root}/modules.txt"
