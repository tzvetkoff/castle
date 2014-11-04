#!/bin/bash

if [[ -z "${1}" ]]; then
	echo "Usage: ${0} <name>"
	exit 1
fi

ps aux|grep "${*}"|grep -v grep|grep -v "`basename ${0}`"|while read x; do
	p=`echo "${x}"|awk '{print $2}'`
	m=`ps -orss -p${p}|tail -n 1`
	echo "${p} ${m}K"
done
