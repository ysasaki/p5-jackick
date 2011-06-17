use strict;
use warnings;
use Test::More;
use Router::Simple;

BEGIN { use_ok 'JacKick::Form::Router' }
can_ok 'JacKick::Form::Router', qw/new add build_route/;

done_testing;
