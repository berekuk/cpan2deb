#!/usr/bin/perl 
use strict;
use 5.010;
use MongoDB;
use boolean; 
use strict;

my $connection = MongoDB::Connection->new(host => 'localhost', port => 27017);
my $database   = $connection->CPAN;
my $dists = $database->dists;
my $mods = $database->mods;


#die unless $col;
$dists->drop();
$dists->ensure_index({ name => 1 },{ unique => true }) || die;
$mods->drop();
$mods->ensure_index({ name => 1 },{ unique => true }) || die;

for (my $i = 0; $i < 9; $i++) {<>};
while(<>) {
    chomp;
    my ($module,$ver,$file) = split;
#    say 'Module: '.$module;
#    say 'Version: '.$ver;
#    say 'File: '.$file;
    my $distr = $file;
    $distr =~ s!(\w/\w{2}/\w{1,}/)!!;
    $distr =~ s!(\.tar|\.tar\.gz|\.tgz|\.tbz|\.tar\.bz2|\.zip)$!!;    
    $distr =~ s/(-[\w\d\._]+)$//;
#    say 'Distr: '.$distr;    
    my $cur = $dists->find({ name => $distr });
    if ($cur) {
#	say 'count: '.$cur->count();
	if ($cur->count == 1) {
	    say 'update '.$distr;
	   $dists->update( { name => $distr }, { '$push' => { mods => $module } }) || die $@;
	} elsif ($cur->count == 0){
	    say 'insert '.$distr;
	    $dists->insert({
		name => $distr,
		file => $file,
		ver => $ver,
		mods => [ $module ]
	    });
	} else {
	    die 'error';
	}
    }
    $mods->insert({ name => $module, dist => $distr });
}