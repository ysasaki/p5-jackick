use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'JacKick::Request' }
my $req = new_ok 'JacKick::Request', [ +{} ];
isa_ok $req, 'Plack::Request';
can_ok $req, qw/response/;

done_testing;
