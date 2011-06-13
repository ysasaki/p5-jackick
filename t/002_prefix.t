use strict;
use warnings;
use Test::More;

subtest 'user' => sub {
    my $prefix;
    {

        package MyApp::Web::User;
        use Koashi::Controller;

        prefix '/user';
        $prefix = Koashi::Controller::_add_prefix('');
    }

    is $prefix, '/user', 'prefix set';
};

subtest 'game' => sub {
    my $prefix;
    {

        package MyApp::Web::Game;
        use Koashi::Controller;

        $prefix = Koashi::Controller::_add_prefix('');
    }

    is $prefix, '', 'prefix is empty string';
};
done_testing;
