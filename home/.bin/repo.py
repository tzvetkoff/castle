#!/usr/bin/env python

from sys import argv
from glob import glob
from os import stat
from os.path import basename

## packages root
root = '/var/lib/pacman/sync/'

## default args
repo = None
do_list = False
do_help = False
name_like = None
desc_like = None

## parse args
args = argv[1:]
while len(args):
	if args[0] == '--help':
		do_help = True
	elif args[0] == '--list':
		do_list = True
	elif args[0] == '--name':
		if len(args) > 1:
			name_like = args[1]

			args.reverse()
			args.pop()
			args.reverse()
		else:
			do_help = True
	elif args[0] == '--desc':
		if len(args) > 1:
			desc_like = args[1]

			args.reverse()
			args.pop()
			args.reverse()
		else:
			do_help = True
	else:
		if not repo:
			repo = args[0]
		else:
			do_help = True

	args.reverse()
	args.pop()
	args.reverse()

## print repo list
if do_list:
	repos = glob(root + '*')
	repos.sort()
	for repo in repos:
		print basename(repo)

	exit(0)

## print help
if do_help or not repo:
	print 'Usage: %s [options] <repo>' % (argv[0])
	print 'Options:'
	print '    --list          Lists repositories'
	print '    --name <name>   List only packages with names containing <name>'
	print '    --desc <desc>   List only packages with description containing <desc>'
	print '    --help          Shows this message and exit'

	exit(1)

## check if repo exists
try:
	stat(root + repo)
except OSError:
	print 'Repository %s does not exist!' % (argv[1])

	exit(1)

## loop packages
packages = glob(root + argv[1] + '/*')
packages.sort()
for package in packages:
	f = open(package + '/desc')
	data = f.read().split('\n')
	f.close()

	if '%NAME%' in data:
		name = data[data.index('%NAME%') + 1]
	else:
		name = basename(package)

	if '%VERSION%' in data:
		vers = data[data.index('%VERSION%') + 1]
	else:
		vers = 'unknown'

	if '%DESC%' in data:
		desc = data[data.index('%DESC%') + 1]
	else:
		desc = 'unknown'

	if (not name_like or name_like in name) and (not desc_like or desc_like in desc):
		print '%-24s [ %-16s ] %s' % (name, vers, desc)
