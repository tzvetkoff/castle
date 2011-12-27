#!/bin/bash

base='/home/svn/'

if [[ -z "${2}" ]]; then
	echo "Usage: ${0} <name> <description> [user=pass] ..."
	exit 1
fi

repo="${base}${1}"
shift
desc="${1}"
shift

echo "Creating repository \`${repo}' (${desc}) ..."
svnadmin create "${repo}"

echo 'Setting up default configuration ...'
cat >"${repo}/conf/svnserve.conf" <<EOF
[general]
anon-access = read
auth-access = write
password-db = passwd
realm = ${desc}

EOF

echo 'Setting up users ...'
cat >"${repo}/conf/passwd" <<EOF
[users]
# user = password
EOF

while [[ ! -z "${1}" ]]; do
	echo "Adding user ${1/=*}"
	echo "${1/=*} = ${1#*=}" >>"${repo}/conf/passwd"
	shift
done

#chmod a+w -R "${repo}"
