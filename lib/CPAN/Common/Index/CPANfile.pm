package CPAN::Common::Index::CPANfile;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";
use parent 'CPAN::Common::Index';
use Capture::Tiny qw(capture_merged);
use File::Spec;
use File::Temp ();
use Module::CPANfile;

sub new {
    my $class = shift;
    my $hash = @_ == 1 ? $_[0] : {@_};
    my $cpanfile = Module::CPANfile->load(
        $hash->{cpanfile} || 'cpanfile',
    );
    my @module = $cpanfile->merged_requirements->required_modules;
    my @need_inject;
    for my $module (@module) {
        my $option = $cpanfile->options_for_module($module) || +{};
        if (my $git = $option->{git}) {
            $git = "$git\@$option->{ref}" if $option->{ref};
            push @need_inject, { module => $module, from => $git };
        } elsif (my $dist = $option->{dist}) {
            # which dist support? read OrePAN2::Injector :-)
            push @need_inject, { module => $module, from => $dist };
        }
    }
    my $self = bless { debug => $hash->{debug} }, $class;
    return $self unless @need_inject;

    require OrePAN2::Injector;
    require OrePAN2::Indexer;
    my $directory = $hash->{directory} || File::Temp::tempdir(CLEANUP => 1);
    $directory =~ s{/?$}{/};
    my $injector = OrePAN2::Injector->new( directory => $directory );
    for my $module (@need_inject) {
        $self->debug("Injecting $module->{module} from $module->{from}");
        my $merged = capture_merged { $injector->inject($module->{from}) };
    }
    my $indexer = OrePAN2::Indexer->new(directory => $directory);
    $self->debug("Indexing $directory");
    my $merged = capture_merged { $indexer->make_index(no_compress => 1) };
    my $source = File::Spec->catfile($directory, "modules/02packages.details.txt");
    $self->debug("Created index $source");
    $self->{index} = $self->_read_source( $source );
    $self->{source} = $source;
    $self->{directory} = $directory;
    $self;
}

sub debug {
    my $self = shift;
    return unless $self->{debug};
    warn "-> [Index::CPANfile] @_\n";
}

sub _read_source {
    my ($self, $file) = @_;
    my %index;
    open my $fh, "<", $file or die "$file: $!";
    my $header = 1;
    while (my $line = <$fh>) {
        if ($line =~ /^\s+$/) {
            $header = 0;
            next;
        }
        next if $header;
        chomp $line;
        my ($module, $version, $dist, @other) = split /\s+/, $line;
        $index{$module} = +{
            version => $version eq 'undef' ? undef : $version,
            dist => $dist,
            other => \@other,
        };
    }
    \%index;
}

sub search_packages {
    my ($self, $args) = @_;
    return unless $self->{index};

    my $module = $args->{package} or die;
    my $try = $self->{index}{$module} or return;
    if (my $version = $args->{version}) {
        if ( !$try->{version} || $try->{version} < $version ) {
            return;
        }
    }
    +{
        package => $module,
        version => $try->{version},
        uri => sprintf("file://%sauthors/id/%s", $self->{directory}, $try->{dist}),
    };
}

sub search_authors { return }


1;
__END__

=encoding utf-8

=head1 NAME

CPAN::Common::Index::CPANfile - make index for cpanfile

=head1 SYNOPSIS

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


=head1 DESCRIPTION

CPAN::Common::Index::CPANfile makes index for cpanfile's C<git> or C<dist> sources.

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
