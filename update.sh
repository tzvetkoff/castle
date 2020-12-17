#!/bin/bash

set -e

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${root}"

reset="\033[0m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"


remote="$(git remote get-url origin)"
echo -e "-> Updating ${green}castle${reset} from ${red}${remote}${reset}"
git pull origin
echo

.vim/pack/w00t/opt/update.sh
.vim/pack/w00t/start/update.sh
