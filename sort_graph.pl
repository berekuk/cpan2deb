#!/usr/bin/perl

use strict;
use warnings;

use YAML qw(LoadFile);

my $FILE = 'deps.yml';

my $selected = {};
my @selected;
my $graph = LoadFile($FILE);

while (keys %$graph) {
    my $count = 0;
    DIST:
    for my $dist (keys %$graph) {
        my $prereqs = $graph->{$dist}{prereqs};
        if ($prereqs) {
            # checking that all dependencies are already selected
            for (keys %$prereqs) {
                next DIST unless $selected->{$_};
            }
        }
        delete $graph->{$dist};
        push @selected, $dist;
        $selected->{$dist}++;
        $count++;
    }
    last unless $count;
}

if (keys %$graph) {
    die "Invalid graph, can't sort ".join(',', keys %$graph)." dists";
}

for my $dist (@selected) {
    print "$dist\n";
}
