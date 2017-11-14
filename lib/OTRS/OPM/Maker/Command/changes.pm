package OTRS::OPM::Maker::Command::changes;

use strict;
use warnings;

# ABSTRACT: Generate changes file based on vcs commits

use Carp;
use File::Find::Rule;
use File::Basename;
use File::Spec;
use IO::File;
use JSON;
use List::Util qw(first);
use Path::Class ();
use Time::Piece;

use OTRS::OPM::Maker -command;
use OTRS::OPM::Maker::Utils::Git;

our $VERSION = 0.01;

sub abstract {
    return "Generate changes file based on git commits";
}

sub usage_desc {
    return "opmbuild changes [--file <path to changes file>] [--dir <directory of addon>]";
}

sub opt_spec {
    return (
        [ 'file=s', 'Path to .changes file'  ],
        [ 'dir=s',  'Directory of the addon' ],
    );
}

sub validate_args {
    my ($self, $opt, $args) = @_;

    if ( !$opt->{file} ) {
    }

    if ( !$opt->{dir} ) {
        $opt->{dir} = OTRS::OPM::Maker::Utils::Git->find_toplevel( dir => '.' );
    }

    if ( !$opt->{dir} ) {
        $self->usage_error( 'no directory with addon found' );
        exit;
    }
}

sub execute {
    my ($self, $opt, $args) = @_;

    chdir $opt->{dir};

    my $changes_file = Path::Class::File->new( $opt->{file} );
    my $lines        = $changes_file->slurp( iomode => '<:encoding(UTF-8)' );

    my @entries = grep{ ( $_ // '' ) ne '' }split m{
        (?:\s+)?
        (                                         # headline with version and date
            ^
            \d+\.\d+ (?:\.\d+)?                   # version
            \s+ -? \s+
            \d{4}-\d{2}-\d{2} (?:\s|T)            # date
            \d{2}:\d{2}:\d{2} (?:[+-]\d+:\d+)?\s  # time
            (?: - \s [a-f0-9]+ )?                 # optional git commit
        )
        \s+
    }xms, $lines;

    my $last_version;
    my $last_commit;

    ENTRY:
    while ( @entries ) {
        my ($header, $desc) = ( shift(@entries), shift(@entries) );

        my ($version, $date, $commit) = split /\s+-\s+/, $header // '';

        if ( $version ) {
            $last_version = $version;
            $last_commit  = $commit;
            last ENTRY;
        }
    }

    $last_version //= '';

    my @commits = OTRS::OPM::Maker::Utils::Git->commits(
        version => $last_version,
        dir     => $opt->{dir},
    );

    my $fh = IO::File->new( $name . '.changes', 'w' ) or die $!;
    $fh->print( $new . "\n\n" . $lines );
    $fh->close;
}

1;

