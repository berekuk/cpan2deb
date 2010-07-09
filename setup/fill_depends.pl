#!/usr/bin/perl
use Module::Depends;
use Module::Depends::Intrusive;
use Data::Dumper;
use 5.010;
use MongoDB;
use boolean; 
use File::Path qw/mkpath rmtree/;
use strict;
use YAML qw/LoadFile/;
use FindBin;

my $conf = LoadFile("$FindBin::Bin/../conf.yaml");


my $connection = MongoDB::Connection->new(host => 'localhost', port => 27017);
my $database   = $connection->CPAN;
my $dists = $database->dists;


my $c = $dists->find();

my $sucess = 0;
my $fail = 0;
my $nometa = 0;

while (my $dist = $c->next()) {
    say $dist->{name};
    next if $dist->{has_deps};
    my $dir = _extract($dist->{file});
    next unless $dir;
    say '$dir = '.$dir;
    _update_depend($dir,$dist->{_id});
    chdir '/';    
}
say 'sucess: '.$sucess;
say 'faild: '.$fail;
say 'noMETA: '.$nometa;

sub _update_depend {
    my ($dir,$id) = @_;
    if (-d $dir) {
	chdir $dir;
	my $m = Module::Depends->new();
	$m->dist_dir($dir);
	eval {
	    $m->find_modules();
	};  if ($@ || $m->error ) {
	    $nometa++;
	    say '=== '.$m->error;
	    $m = Module::Depends::Intrusive->new();
	    $m->dist_dir($dir);
	    eval {
		$m->find_modules();
	    };
	    if ( $@ || $m->error ) {
		return;
	    }
	} 
	
	say 'updated';
	my $need_up = undef;
	my $up = {
	    '$set' => { has_deps => true }
	}; 
	if ($m->requires && ! ref $m->requires && $m->requires =~ /\w/) {
	    $m->requires({ $m->requires => "0" });
	    
	}
	if ($m->requires && keys %{$m->requires} > 0) {
	    $up->{'$set'}{deps} = $m->requires;
	    $need_up = 1;
	}
	if ($m->build_requires && keys %{$m->build_requires} > 0) {
	    $up->{'$set'}{bdeps} = $m->build_requires;
	    $need_up = 1;
	}
	say 'Deps: '.Dumper($up);
	
	if ( $need_up ) {
	    unless ($dists->update({ _id => $id},$up,{'safe' => 1}) == 1 ) {
		say '=== error: '.$MongoDB::Database::last_error;
	    }
	}
	$sucess++;
	
    }

}

sub _extract {
    my $file = shift;
    $file = $conf->{modules_root}.$file;
    say '==== try to extract '.$file;
    my $dir =  $conf->{temp_dir}.'dep_ext';
    rmtree $dir;
    mkpath $dir;
    if ($file =~ /(t|ar\.)gz$/) {
	chdir $dir;
	system ('tar xzf '.$file );	
    }
    my $re;
    opendir D, $dir;
    while(my $n = readdir D) {
	next if $n eq '.';
	next if $n eq '..';
	$re = $dir.'/'.$n;
    }
    return $re;
}