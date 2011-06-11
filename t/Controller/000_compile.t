use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Koashi::Controller' }

my @method = qw/any get post/;
can_ok 'Koashi::Controller', @method;

done_testing;
