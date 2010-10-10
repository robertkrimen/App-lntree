#!/usr/bin/env perl
use strict;
use warnings;
use Test::Most;

use App::lntree;
use File::Temp qw/ tempdir /;
use Path::Class;

my $src = dir(qw/ t assets src /);
my $dst = tempdir;

App::lntree->lntree( $src, $dst );
ok( -l file $dst, qw/ a / );
is( file( $dst, qw/ a /)->stat->size, 14 );
ok( -d dir $dst, qw/ b / );
ok( -l file $dst, qw/ b c / );
is( file( $dst, qw/ b c /)->stat->size, 0 );

done_testing;
