use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Koashi::Request' }
my $req = new_ok 'Koashi::Request', [ +{} ];
isa_ok $req, 'Plack::Request';

done_testing;
