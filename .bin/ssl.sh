#!/bin/bash

if [[ "$1" == "--help" ]]; then
	echo "Usage: $0 [basename]"
	echo "  -- if basename is omitted \"server\" is used (e.g. server.key, server.pem...)"
	exit 0
fi

base="$1"
if [[ -z "$base" ]]; then
	base="server"
fi

openssl genrsa -out ${base}.key 1024												|| exit
openssl rsa -in ${base}.key -out ${base}.pem										|| exit
openssl req -new -key ${base}.key -out ${base}.csr									|| exit
openssl x509 -req -days 60 -in ${base}.csr -signkey ${base}.key -out ${base}.crt	|| exit
