#!/usr/bin/perl -w

use strict;
use warnings;

if (!$ARGV[0]) {
	print 'Usage: ', $0, " <executable>\n";
	exit 1;
}

my @hash = ($ARGV[0]);

walk($ARGV[0], '');

sub walk {
	my $arg = shift;
	my $ind = shift;

	my $_ = `ldd $arg 2>/dev/null`;

	s/.* => (.+) \(.*\)/$1/g;
	s/.* => .*//g;
	s/.* \(.*\)//g;

	s/\s+/ /g;
	s/^\s+//;
	s/\s+$//;

	my @libs = split;

	for my $lib (@libs) {
		#print $lib, "\n";

		if (!grep { $lib eq $_ } @hash) {
			push @hash, $lib;
			print $ind, $lib, "\n";
			walk($lib, $ind . '  ');
		}
	}
}
