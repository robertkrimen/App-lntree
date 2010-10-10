#!/usr/bin/env perl
use strict;
use warnings;
use Test::Most;

use App::lntree;
use File::Spec;

my ( $from, $to, $from_path, $to_path );

sub path { return File::Spec->catfile( @_ ) }

$from = 'src';
$to = 'dst';

( $from_path, $to_path ) = App::lntree->resolve( $from, $to, path(qw/ src a /) );
is( $from_path, path(qw/ .. src a /) );
is( $to_path, path(qw/ a /) );

( $from_path, $to_path ) = App::lntree->resolve( $from, $to, 'src/b/c' );
is( $from_path, path(qw/ .. .. src b c /) );
is( $to_path, path(qw/ b c /) );

( $from_path, $to_path ) = App::lntree->resolve( $from, path( '/', $to ), 'src/b/c' );
is( $from_path, File::Spec->rel2abs( path(qw/ src b c /) ) );
is( $to_path, path(qw/ b c /) );

done_testing;
