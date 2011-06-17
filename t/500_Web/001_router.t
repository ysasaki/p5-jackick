use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);

my $router;
{

    package MyApp::Web::Root;
    use JacKick::Web;

    $router = JacKick::Web->router;
}
isa_ok $router, 'Router::Simple', 'router ok';

my $router2;
{

    package MyApp::Web::User;
    use JacKick::Web;

    $router2 = JacKick::Web->router;
}
is refaddr($router), refaddr($router2), 'refaddrs are same';

done_testing;
