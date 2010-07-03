#!/usr/bin/perl
use strict;
use CPAN::Mini;

CPAN::Mini->update_mirror(
   remote => "http://cpan.tomsk.ru/",
   local  => "$ARGV[0]",
   trace  => 1
);