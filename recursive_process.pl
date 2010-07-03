#!/usr/bin/perl

use strict;
use warnings;

use YAML qw(LoadFile);
use CPAN::Dependency;

my @unresolved = @ARGV;

my $FILE = 'deps.yml';

while (1) {
    if (-e $FILE) {
        my $data = LoadFile($FILE);

        for my $package (values %$data) {
            next unless $package->{prereqs};
            my @prereqs = keys %{ $package->{prereqs} };
            for (@prereqs) {
                next if $data->{$_};
                push @unresolved, $_;
            }
        }
    }
    last unless @unresolved;

    my $c = CPAN::Dependency->new(verbose => 1);
    $c->load_deps_tree(file => $FILE) if -e $FILE;
    $c->process(@unresolved);
    $c->run;
    $c->save_deps_tree(file => $FILE);
    @unresolved = ();
}
