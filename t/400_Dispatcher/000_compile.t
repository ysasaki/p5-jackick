use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'JacKick::Dispatcher' }

my $obj = new_ok 'JacKick::Dispatcher';
can_ok $obj, qw/router former dispatch/;

done_testing;
