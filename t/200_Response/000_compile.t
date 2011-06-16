use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Koashi::Response' }
my $req = new_ok 'Koashi::Response',
    [ [ 200, [ 'Content-Type', 'text/plain' ], ["Hello, world!\n"] ] ];
isa_ok $req, 'Plack::Response';

done_testing;
