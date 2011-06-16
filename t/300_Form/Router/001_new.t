use strict;
use warnings;
use Test::More;
use Router::Simple;
use Koashi::Form::Router;

my $obj = new_ok 'Koashi::Form::Router', [ router => Router::Simple->new() ];
eval { Koashi::Form::Router->new(); };
ok $@, 'die if missing router';

done_testing;
