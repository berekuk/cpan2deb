#!/usr/bin/perl
use strict;
use 5.010;
use Getopt::Std::Strict 'a:m:d:c:f:', 'opt'; 
use File::Path qw/mkpath rmtree/;
use File::Copy;
use File::Basename;
use FindBin;

use constant {
    TEMPDIR => '/ram/builder/',
    IMAGEDIR => '/opt/images/'
};

die 'you must specify moudle name' unless $OPT{m};
die 'you must specify dicrib name' unless $OPT{d};
die 'you must specify disrib codename' unless $OPT{c};
die 'you must specify arch' unless $OPT{a};
die 'you must specify module filename' unless $OPT{f};

my $module_name = $OPT{m};
my $dist = $OPT{d};
my $codename = $OPT{c};
my $arch = $OPT{a};
my $file_name = $OPT{f};

say sprintf('=== Packaging %s from %s/%s %s',$module_name,$dist,$codename,$arch);

# TODO: remove me
# make source package

rmtree(TEMPDIR);
mkpath(TEMPDIR.'/src');

copy($file_name,TEMPDIR.'/src/');
chdir TEMPDIR.'/src/';
system("tar xvzf ".basename($file_name));
my $file = basename($file_name);
my $dir = $file;
$dir =~ s/\.tar\.gz//;
$dir =~ s/\.tgz//;

say 'Dir name: '.$dir;

system("dh-make-perl $dir");
chdir TEMPDIR.'/src/'.$dir;
system("dpkg-buildpackage -S");
chdir TEMPDIR.'/src/';
system("pbuilder build --hookdir $FindBin::Bin/pbuilder_hooks --basetgz /opt/images/lucid-amd64.tgz --buildplace /ram/pbuild/base --aptcache /ram/pbuild/cache/ --architecture amd64 --buildresult /ram/builder/bin/  ".TEMPDIR.'/src/'.'*.dsc');
system("$FindBin::Bin/repo.pl -p $dist $codename $arch ".TEMPDIR.'/bin/'.'*.deb');

