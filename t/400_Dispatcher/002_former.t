use strict;
use warnings;
use Test::More;
use JacKick::Dispatcher;

my $dispatcher = JacKick::Dispatcher->new;
eval {
    my $former = $dispatcher->former;
    ok 1, 'call former';
    isa_ok $former, 'HASH';
};

done_testing;
