#!/bin/bash

usage() {
  echo 'usage:'
  echo "  ${0} [options]"
  echo
  echo 'options:'
  echo '  -s, --strong          strong passwords [default: no]'
  echo '  -c C, --charset=C     custom charset [default: 0123456789abcdef]'
  echo '  -l L, --length=L      length of generated passwords [default: 16]'
  echo '  -n N, --count=N       number of passwords to generate [default: 8]'
  exit "${1}"
}

charset='0123456789abcdef'
length=16
count=8

while [[ -n "${1}" ]]; do
  case "${1}" in
    -h|--help) usage 0;;

    -s|--strong) charset='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*+-';;

    -c|--charset) charset="${2}"; shift;;
    -c*)          charset="${1:2}";;
    --charset=*)  charset="${1:10}";;

    -l|--length) length="${2}"; shift;;
    -l*)         length="${1:2}";;
    --length=*)  length="${1:10}";;

    -n|--count) count="${2}"; shift;;
    -n*)        count="${1:2}";;
    --count=*)  count="${1:10}";;

    -*) echo "${0}: invalid option: ${1}" >&2; echo >&2; usage 1 >&2;;
  esac

  shift
done

for ((i = 0; i < count; ++i)) do
  tr -dc "${charset}" < /dev/urandom | fold -w "${length}" | head -1
done
