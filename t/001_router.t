use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);

my $router;
{

    package MyApp::Web::Root;
    use Koashi::Controller;

    $router = Koashi::Controller->router;
}
isa_ok $router, 'Router::Simple', 'router ok';

my $router2;
{

    package MyApp::Web::User;
    use Koashi::Controller;

    $router2 = Koashi::Controller->router;
}
is refaddr($router), refaddr($router2), 'refaddrs are same';

done_testing;
