use strict;
use utf8;
use warnings;
use Test::More;
use CPAN::Common::Index::CPANfile;
use File::Temp 'tempfile';

my ($fh, $cpanfile) = tempfile UNLINK => 1;
print {$fh} <<'...';
requires 'Carl', git => 'git://github.com/shoichikaji/Carl.git', ref => 'master';
...
close $fh;

my $index = CPAN::Common::Index::CPANfile->new(cpanfile => $cpanfile);
my $result;

$result = $index->search_packages({ package => "Carl" });
is $result->{package}, "Carl";
ok defined $result->{version};

$result = $index->search_packages({ package => "Carl::CLI" });
is $result->{package}, "Carl::CLI";
ok !defined $result->{version};

$result = $index->search_packages({ package => "Carl", version => 99999 });
is $result, undef;

$result = $index->search_packages({ package => "Plack" });
is $result, undef;

done_testing;
