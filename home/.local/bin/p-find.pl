#!/usr/bin/perl

use strict;
use warnings;

## check argument
if (!$ARGV[0]) {
	print "Usage: $0 <command>\n";
	exit 1;
}

## fetch file and fast grep
open(my $file, "<", "/var/cache/bin.cache");
my @found = grep(m/^${ARGV[0]} /, <$file>);
close($file);

## print results
if (scalar @found) {
	print "Command `", $ARGV[0], "' may be provided by one of the following packages:\n\n";
	foreach my $result (@found) {
		my @parts = split(" ", $result);
		print $parts[1] . "/" . $parts[2] . ": " . $parts[3], "\n";
	}

	exit 0;
}

exit 1;
