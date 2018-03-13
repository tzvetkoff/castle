#!/usr/bin/env python2.7

from random import randint
from argparse import ArgumentParser, SUPPRESS

if __name__ == '__main__':
	parser = ArgumentParser()
	parser.add_argument('-c', '--charset', dest='charset', type=str, default='0123456789abcdef', metavar='CHARSET', help='set charset [default: %(default)s]')
	parser.add_argument('-l', '--length', dest='length', type=int, default=16, metavar='LENGTH', help='password length [default: %(default)s]')
	parser.add_argument('-n', '--count', dest='count', type=int, default=8, metavar='COUNT', help='passwords to generate [default: %(default)s]')
	parser.add_argument('-s', '--strong', action='store_true', dest='strong', default=False, help=SUPPRESS)

	args = parser.parse_args()

	if args.strong:
		args.charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*+-'

	for x in range(0, args.count):
		print ''.join( [args.charset[ randint(0, len(args.charset)-1) ] for x in range(0, args.length)] )
