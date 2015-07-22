#!/bin/bash

if [[ -z "${1}" ]]; then
  echo "usage: ${0##*/} <files>"
  exit 1
fi

green="\033[01;32m"
red="\033[01;31m"
none="\033[00m"
ok="[  ${green}ok${none}  ]"
fail="[ ${red}fail${none} ]"

for file in ${*}; do
  name=${file%.*}
  ext=${file##*.}

  if [[ ${name} = *.optimized ]]; then
    out=${name%.optimized}.${ext}
  else
    out=${name}.unoptimized.${ext}
  fi

  if [[ ! -f "${file}" ]]; then
    echo -e "${fail} ${file} does not exist"
    exit 1
  elif `xcode-select -print-path`/Platforms/iPhoneOS.platform/Developer/usr/bin/pngcrush -q -revert-iphone-optimizations ${file} ${out}; then
    echo -e "${ok} ${file}"
  else
    echo -e "${fail} ${file}"
    exit 1
  fi
done
