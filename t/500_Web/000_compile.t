use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Koashi::Web' }

my @method = qw/any get post prefix submitted_and_valid submitted default
    form router former build_route_from_form
    /;
can_ok 'Koashi::Web', @method;

done_testing;
