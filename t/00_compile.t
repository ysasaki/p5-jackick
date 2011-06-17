use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'JacKick' }

my $glite = new_ok 'JacKick';

can_ok $glite, qw/to_psgi/;

done_testing;
