use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);

my $router;
{

    package MyApp::Web::Root;
    use Koashi::Web;

    $router = Koashi::Web->router;
}
isa_ok $router, 'Router::Simple', 'router ok';

my $router2;
{

    package MyApp::Web::User;
    use Koashi::Web;

    $router2 = Koashi::Web->router;
}
is refaddr($router), refaddr($router2), 'refaddrs are same';

done_testing;
