use strict;
use warnings;
use Test::More;
use Router::Simple;
use JacKick::Form::Router;

my $obj = new_ok 'JacKick::Form::Router', [ router => Router::Simple->new() ];
eval { JacKick::Form::Router->new(); };
ok $@, 'die if missing router';

done_testing;
