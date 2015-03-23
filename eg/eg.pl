#!/usr/bin/env perl
use 5.20.0;
use utf8;
use warnings;
use experimental 'signatures', 'postderef';
use lib "lib", "../lib";
use CPAN::Common::Index::CPANfile;
use File::Temp 'tempfile';
use Data::Dump;

my ($fh, $cpanfile) = tempfile UNLINK => 1;
print {$fh} <<'...';
requires 'Carl', git => 'git://github.com/shoichikaji/Carl.git', ref => 'master';
...
close $fh;

my $index = CPAN::Common::Index::CPANfile->new(debug => 1, cpanfile => $cpanfile);
my $result = $index->search_packages({ package => "Carl" });

dd $result;
