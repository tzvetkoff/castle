#!/usr/bin/perl

## force strict mode and warnings
use strict;
use warnings;

## regular expressions for extracting names
my $pak = qr!^.*/([^/]+)/([^/]+)/files$!;
my $bin = qr!^.*s?bin/(.+)$!;

## collect catalog files
my @catalogs = ();
splice(@catalogs, scalar @catalogs, 0, glob("/var/lib/pacman/local/*/files"));
splice(@catalogs, scalar @catalogs, 0, glob("/var/cache/pkgtools/lists/*/*/files"));

## walk through catalogs and match commands
foreach my $catalog (@catalogs) {
	## extract repository and package name
	$catalog =~ $pak;
	my $repo = $1;
	my $package = $2;

	## grep file for binaries
	open(my $input, "<", $catalog);
	while (<$input>) {
		chomp;
		if ($_ =~ $bin) {
			print $1, " ", $repo, " ", $package, " /", $_, "\n";
		}
	}
	close($input);
}
