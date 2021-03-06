use strict;
use warnings;
use Test::More;

subtest 'prefix defined' => sub {
    my $prefix;
    {

        package MyApp::Web::User;
        use JacKick::Web;

        prefix '/user';
        $prefix = JacKick::Web::_add_prefix( __PACKAGE__, '' );
    }

    is $prefix, '/user', 'prefix set';
};

subtest 'prefix not deifned' => sub {
    my $prefix;
    {

        package MyApp::Web::Game;
        use JacKick::Web;

        $prefix = JacKick::Web::_add_prefix( __PACKAGE__, '' );
    }

    is $prefix, '', 'prefix is empty string';
};

subtest 'only path' => sub {
    my $prefix;
    {

        package MyApp::Web::Game;
        use JacKick::Web;

        $prefix = JacKick::Web::_add_prefix( __PACKAGE__, '/upload' );
    }

    is $prefix, '/upload', 'only use path info';
};
done_testing;
