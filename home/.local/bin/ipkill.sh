#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 <ip address>"
	exit 31337
fi

if [ ! -z "$2" ]; then
	SIGNAL="$1"
	IPADDR="$2"
else
	SIGNAL="-9"
	IPADDR="$1"
fi

lsof -i TCP@${IPADDR} | grep TCP > /tmp/ipkill.tmp

OFS=${IFS}
IFS=$'\n'
arr=($(< /tmp/ipkill.tmp))
IFS=${OFS}

i=0
while [ ! -z "${arr[$i]}" ]; do
	line=`echo ${arr[$i]} | tr '\t' ' '`
	line=`echo ${line} | sed 's/  / /g'`
	line=`echo ${line} | sed 's/  / /g'`
	line=`echo ${line} | sed 's/  / /g'`
	line=`echo ${line} | sed 's/  / /g'`
	line=`echo ${line} | sed 's/  / /g'`
	line=`echo ${line} | sed 's/  / /g'`
	line=`echo ${line} | sed 's/  / /g'`
	set $line
	echo kill $SIGNAL $2
	kill $SIGNAL $2
	let i++
done
