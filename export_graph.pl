#!/usr/bin/perl
use Module::Depends;
use Module::Depends::Intrusive;
use Data::Dumper;
use 5.010;
use MongoDB;
use boolean; 
use YAML qw/DumpFile/;
use Hash::Merge qw/merge/;


my $connection = MongoDB::Connection->new(host => 'localhost', port => 27017);
my $database   = $connection->CPAN;
my $dists = $database->dists;
my $mods = $database->mods;


my $c = $dists->find({ has_deps => true });

my %H;
while( my $dist = $c->next() ) {
    say '== process '.$dist->{name};
    my $deps = merge($dist->{deps},$dist->{bdeps});
    my $rdeps = {};
    foreach (keys %{$deps}) {
	  my $name = _resolve_mod($_);
	  if ($name && $name =~ /\w/ ) {
	    $rdeps->{$name} = 0;
	  }
    }
    $H{$dist->{name}} = {
	prereqs => $rdeps
    };
}
DumpFile('deps.yaml',\%H);

sub _resolve_mod {
    my $name = shift;
    my $c = $mods->find({ 'name' => $name })->next();
    return $c->{dist} if $c;    
}