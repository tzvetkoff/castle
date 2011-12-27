#!/usr/bin/env perl

use strict;
use warnings;

die "Usage: $0 <files>\n" unless $ARGV[0];

for my $file (@ARGV) {
	if (-f $file) {
		open my $handle, '<', $file;
		sysread $handle, $_, -s $handle;
		s/[^{}]//g;
		print;
		print "\n";
	}
}
