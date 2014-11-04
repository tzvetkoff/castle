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

	if [[ ${name} = *.unoptimized ]]; then
		out=${name%.unoptimized}.${ext}
	else
		out=${name}.optimized.${ext}
	fi

	if [[ ! -f "${file}" ]]; then
		echo -e "${fail} ${file} does not exist"
		exit 1
	elif `xcode-select -print-path`/Platforms/iPhoneOS.platform/Developer/usr/bin/pngcrush -iphone -f 0 -q ${file} ${out}; then
		echo -e "${ok} ${file}"
	else
		echo -e "${fail} ${file}"
		exit 1
	fi
done
