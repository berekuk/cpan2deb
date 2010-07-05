#!/usr/bin/perl 
use strict;
use 5.010;
use MongoDB;
use boolean; 
use strict;
use YAML qw/LoadFile/;
use FindBin;

my $conf = LoadFile("$FindBin::Bin/conf.yaml");



my $connection = MongoDB::Connection->new(host => 'localhost', port => 27017);
my $database   = $connection->CPAN;
my $dists = $database->dists;

my @queue;

while(<>){
    chomp;
    my $cur = $dists->find({ name => $_ });	
    die 'can`t find '.$_  unless $cur->count > 0;
    my $dist = $cur->next();
    say 'add to queue: '.$dist->{file};
    push @queue, $dist->{file};    
}

foreach(@queue){
    say '==== Building: '.$conf->{modules_root}.$_;
    system("perl build.pl  -d ubuntu -c lucid -a amd64   -f $conf->{modules_root}$_") == 0
	or die 'can`t build '.$_.': '.$?;
    
}