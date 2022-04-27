#!/bin/bash

if [[ "${1}" = '-h' || "${1}" = '--help' ]]; then
  echo "Usage: ${0} [file.b]"
  exit 0
fi

I='/dev/stdin'
if [[ -n "${1}" ]]; then
  I="${1}"
fi

C='s[0]=0; p=0;'

while read -rn1 c; do
  case "${c}" in
    \+) C="${C} s[\$p]=\$((\${s[\$p]}+1));";;
     -) C="${C} s[\$p]=\$((\${s[\$p]}-1));";;
    \>) C="${C} p=\$((\$p+1));";;
    \<) C="${C} p=\$((\$p-1));";;
    \.) C="${C} printf \\\\\$(printf '%03o' \${s[\$p]});";;
    \,) C="${C} read -n1 c; s[\$p]=\`printf '%d' \"'\$c\"\`;";;
    \[) C="${C} while [[ \${s[\$p]} > 0 ]]; do ";;
    \]) C="${C} done;";;
  esac;
done < "${I}";

eval "${C}"
