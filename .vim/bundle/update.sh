#!/bin/bash

#
# This script's path
#

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#
# Walk modules.txt and install/update each module
#

while read -r remote local branch; do
  if [[ -d "${ROOT}/${local}" && -d "${ROOT}/${local}/.git" ]]; then
    pushd "${ROOT}/${local}"
    if [[ -n "${branch}" ]]; then
      git checkout "${branch}" && git pull origin "${branch}"
    else
      git pull origin
    fi
    popd
  else
    if [[ -n "${branch}" ]]; then
      git clone "${remote}" --depth 1 --branch "${branch}" "${ROOT}/${local}"
    else
      git clone "${remote}" --depth 1 "${ROOT}/${local}"
    fi
  fi
done < "${ROOT}/modules.txt"
