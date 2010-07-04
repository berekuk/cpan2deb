#!/usr/bin/perl
use strict;
use 5.010;

# TODO: rewrite me
my $repo_root = '/opt/repo';
my @arch = qw/i386 amd64/;
my %dist = (
    'ubuntu' => [ 'lucid' ]
);

system('mkdir -p '.$repo_root);
    while ( my ($dist,$names) = each %dist ) {
	foreach my $name (@{$names}) {
	    foreach my $arch (@arch) {
		say 'create: '."$repo_root/$dist/dists/$name/main/binary-$arch";
		system("mkdir -p $repo_root/$dist/dists/$name/main/binary-$arch");
	    }
	    system("mkdir -p $repo_root/$dist/dists/$name/main/source");
	}
    }
