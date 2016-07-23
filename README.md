# NAME

CPAN::Common::Index::CPANfile - make index for cpanfile

# SYNOPSIS

    > cat cpanfile
    requires 'Carl', git => 'git://github.com/shoichikaji/Carl.git', ref => 'master';

    # your script
    use CPAN::Common::Index::CPANfile;

    my $index = CPAN::Common::Index::CPANfile->new(directory => "/tmp/repo");
    my $result = $index->search_package({ package => "Carl" });

    use Data::Dumper;
    print Dumper $result;
    # {
    #   package => "Carl",
    #   uri => "file:///tmp/repo/authors/id/D/DU/DUMMY/Carl-0.01.tar.gz",
    #   version => 0.01,
    # }

# DESCRIPTION

CPAN::Common::Index::CPANfile makes index for cpanfile's `git` or `dist` sources.

# COPYRIGHT AND LICENSE

Copyright 2016 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
