#!/usr/bin/perl
use strict;
use 5.010;
use File::Copy;
use YAML qw/LoadFile/;
use Switch;
use FindBin;

my $conf = LoadFile("$FindBin::Bin/conf.yaml");

my $action = shift @ARGV;
my ($dist,$cname,$arch,$file) = @ARGV;
die unless $file;


switch($action) {
    case '-p' {
	my $repo_path = $conf->{repo_root}.'/'.$dist.'/dists/'.$cname.'/main/binary-'.$arch.'/';	
	say 'path: '.$repo_path;
	say '=== Warning! not file' unless -f $file;
	copy($file,$repo_path);
	update_repo($dist,$cname,$arch);
    }
}

sub update_repo {
    my ($dist,$cname,$arch) = @_;    
    my $repo_path = $conf->{repo_root}.'/'.$dist.'/dists/'.$cname.'/main/';	    
    say 'path: '.$repo_path;
    chdir $repo_path;
    system("dpkg-scanpackages binary-$arch /dev/null dists/$cname/main/  | gzip -9c > $repo_path/binary-$arch/Packages.gz");
}