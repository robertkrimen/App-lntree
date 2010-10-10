package App::lntree;
# ABSTRACT: Create a link (symbolic or hard) tree 

use strict;
use warnings;

use Path::Class;
use File::Spec;
use File::Spec::Link;
use Getopt::Usaginator <<_END_;

    Usage: lntree <src> <dst>

_END_

sub run {
    my $self = shift;
    my @arguments = @_;

    usage 0 unless @arguments;
    usage "Missing <src> or <dst>" unless @arguments > 1;

    my $src = shift @arguments;
    my $dst = shift @arguments;

    usage "Missing <src>" unless defined $src;
    usage "Source directory ($src) does not exist or is not a directory" unless -d $src;

    $self->lntree( $src, $dst );
}

sub lntree {
    my $self = shift;
    my $src = shift;
    my $dst = shift;

    $src = dir $src;
    $dst = dir $dst;
    my $absolute = $dst->is_absolute;
    $src->recurse( callback => sub {
        my $file = shift;
        my ( $from_path, $to_path ) = App::lntree->resolve( $src, $dst, $file );
        if ( -d $file ) {
            my $dir = $dst->subdir( $to_path );
            $dir->mkpath;
        }
        else {
            my $file = $dst->file( $to_path );
            my $link_path = $from_path;
            if ( -l $file ) {
                unlink $file or warn "Unable to unlink symlink \"$to_path\": $!\n";
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
        my $depth = @path - 1; # How many .. should be in the from path
        $from_path = File::Spec->catpath( ( ( '..' ) x $depth ), File::Spec->abs2rel( $path, $to ) );
    }

    my $to_path = File::Spec->catpath( $to, File::Spec->abs2rel( $path, $from ) );

    return ( $from_path, $to_path );
}

1;
