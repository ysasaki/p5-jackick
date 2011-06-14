use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Koashi::Controller' }

my @method = qw/any get post prefix submitted_and_valid submitted default
    form router former
    /;
can_ok 'Koashi::Controller', @method;

done_testing;
