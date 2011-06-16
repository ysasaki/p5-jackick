use strict;
use warnings;
use Test::More;
use Koashi::Dispatcher;

my $dispatcher = Koashi::Dispatcher->new;
eval {
    my $former = $dispatcher->former;
    ok 1, 'call former';
    isa_ok $former, 'HASH';
};

done_testing;
