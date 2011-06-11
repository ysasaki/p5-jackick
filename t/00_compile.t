use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Koashi' }

my $glite = new_ok 'Koashi';

can_ok $glite, qw/to_psgi/;

done_testing;
