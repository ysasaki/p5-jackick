use strict;
use warnings;
use Test::More;
use Koashi::Dispatcher;

my $dispatcher = Koashi::Dispatcher->new;
eval {
    my $router = $dispatcher->router;
    ok 1, 'call router';
    isa_ok $router, 'Router::Simple';
};

done_testing;
