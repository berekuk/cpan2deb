#!/usr/bin/perl

use strict;
use warnings;

use lib '.';

use YAML qw(LoadFile);
use CPAN::Dependency;
use CPAN::SQLite;

my $seen = {};

my $FILE = 'deps.yml';

my $sqlite = CPAN::SQLite->new;

my $c = CPAN::Dependency->new(verbose => 1);
$c->load_deps_tree(file => $FILE) if -e $FILE;

sub dist2modules {
    my $dist = shift;
    $sqlite->query(mode => "dist", name => $dist, type => "name");
    return map { $_->{mod_name} } @{ $sqlite->{results}{mods} };
}

my @unresolved_dists = @ARGV;
{
    my $data = $c->deps_by_dists();
    @unresolved_dists = grep { not $data->{$_} } @unresolved_dists;
}
my @unresolved = map { dist2modules($_) } @unresolved_dists;

while (1) {
    my $data = $c->deps_by_dists();

    for my $package (values %$data) {
        next unless $package->{prereqs};
        my @prereqs = keys %{ $package->{prereqs} };
        for (@prereqs) {
            next if $data->{$_};
            next if $seen->{$_};
            warn "pushing $_ modules to unresolved";
            push @unresolved, dist2modules($_);
        }
    }
    last unless @unresolved;

    $c->process(@unresolved);
    $seen->{$_}++ for @unresolved;

    my $dists_before = scalar keys %$data;
    $c->run;
    my $dists_after = scalar keys %{ $c->deps_by_dists() };
    if ($dists_before == $dists_after) {
        die "run() failed while processing ".join(',', @unresolved).", no new distributions found in tree ($dists_before before, $dists_after after)";
    }
    $c->save_deps_tree(file => $FILE);
    @unresolved = ();
}
