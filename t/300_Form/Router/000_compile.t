use strict;
use warnings;
use Test::More;
use Router::Simple;

BEGIN { use_ok 'Koashi::Form::Router' }
can_ok 'Koashi::Form::Router', qw/new add build_route/;

done_testing;
