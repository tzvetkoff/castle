#!/usr/bin/env python2

from random import randint
from optparse import OptionParser

if __name__ == '__main__':
	parser = OptionParser()
	parser.add_option('-c', '--charset', dest='charset', type='string', default='0123456789abcdef', metavar='CHARSET', help='set charset [default: %default]')
	parser.add_option('-l', '--length', dest='length', type='int', default=16, metavar='LENGTH', help='password length [default: %default]')
	parser.add_option('-n', '--count', dest='count', type='int', default=8, metavar='COUNT', help='passwords to generate' '[default: %default]')

	options = parser.parse_args()[0]

	for x in range(0, options.count):
		print ''.join( [options.charset[ randint(0, len(options.charset)-1) ] for x in range(0, options.length)] )
