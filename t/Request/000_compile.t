use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Koashi::Request' }
my $req = new_ok 'Koashi::Request', [ +{} ];
isa_ok $req, 'Plack::Request';
can_ok $req, qw/response/;

done_testing;
