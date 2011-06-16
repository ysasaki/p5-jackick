use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Koashi::Dispatcher' }

my $obj = new_ok 'Koashi::Dispatcher';
can_ok $obj, qw/router former dispatch/;

done_testing;
