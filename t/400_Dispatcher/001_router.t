use strict;
use warnings;
use Test::More;
use JacKick::Dispatcher;

my $dispatcher = JacKick::Dispatcher->new;
eval {
    my $router = $dispatcher->router;
    ok 1, 'call router';
    isa_ok $router, 'Router::Simple';
};

done_testing;
