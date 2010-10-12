package App::lntree;
# ABSTRACT: Create a symlink-based mirror of a directory

use strict;
use warnings;

# TODO Source as file, target as file?
# TODO Absolute source, absolute target?
# TODO Test file/directory/symlink overwriting

use Path::Class;
use File::Spec;
use File::Spec::Link;
use Getopt::Usaginator <<_END_;

    Usage: lntree <source> <target>

_END_

sub run {
    my $self = shift;
    my @arguments = @_;

    usage 0 unless @arguments;
    usage "Missing <source> or <target>" unless @arguments > 1;

    my $source = shift @arguments;
    my $target = shift @arguments;

    usage "Missing <source>" unless defined $source;
    usage "Source directory ($source) does not exist or is not a directory" unless -d $source;

    $self->lntree( $source, $target );
}

sub lntree {
    my $self = shift;
    my $source = shift;
    my $target = shift;

    $source = dir $source;
    $target = dir $target;
    my $absolute = $target->is_absolute;
    $source->recurse( callback => sub {
        my $file = shift;
        my ( $from_path, $to_path ) = App::lntree->resolve( $source, $target, $file );
        if ( -d $file ) {
            my $dir = $target->subdir( $to_path );
            $dir->mkpath;
        }
        else {
            my $file = $target->file( $to_path );
            my $link_path = $from_path;
            if ( -l $file ) {
                unlink $file or warn "Unable to unlink symlink \"$to_path\": $!\n";
            }
            elsif ( -e $file ) {
                return;
            }
            symlink $link_path, $file or die "Unable to symlink \"$link_path -> \"$to_path\": $!\n";
        }
    } );
}

sub resolve {
    my $self = shift;
    my $from = shift;
    my $to = shift;
    my $path = shift;

    my $absolute = File::Spec->file_name_is_absolute( $to );

    my $from_path;
    if ( $absolute ) {
        $from_path = File::Spec->rel2abs( $path );
    }
    else {
        my @path = File::Spec->splitdir( $path );
        my $depth = @path - 2; # How many .. should be in the from path
        $from_path = File::Spec->canonpath( join '/', ( ( '..' ) x $depth ), File::Spec->abs2rel( $path, $to ) );
    }

    my $to_path = File::Spec->canonpath( join '/', File::Spec->abs2rel( $path, $from ) );

    return ( $from_path, $to_path );
}

1;

__END__

=pod

=head1 SYNOPSIS

    lntree ~/project1 target/
    lntree ~/project2 target/

    # target/ is now a combination of project1 & project2, with project2 taking precedence

=head1 DESCRIPTION

App::lntree is a utility for making a symlink-based mirror of a directory. The algorithm is:

    - Directories are always recreated, NOT symlinked
    - A symlink conflict will be resolved by removing the original symlink
    - Regular files (including directories) are left untouched

=head1 USAGE

=head2 lntree <source> <target>

Create a symlink mirror of <source> into <target>, creating <target> if necessary

=cut
