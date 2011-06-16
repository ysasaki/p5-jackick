use strict;
use warnings;
use Test::More;
use Router::Simple;
use Koashi::Form::Router;
use Koashi::Form::Entity;
use HTTP::Request::Common;
use Plack::Test;

subtest 'get' => sub {
    my $fr   = _fr();
    my $pkg  = 'MyApp::Web::Get';
    my $opts = { method => [qw/GET HEAD/] };

    my $add = sub {
        my ( $pattern, $entity ) = @_;
        $fr->add(
            path    => $pattern,
            pkg     => $pkg,
            pattern => $pattern,
            opts    => $opts,
            entity  => $entity,
        );
    };

    $add->(
        '/index',
        _e( 'submitted_and_valid',
            sub { ok 1, '/index:submitted_and_valid called' }
        )
    );
    $add->(
        '/index', _e( 'submitted', sub { ok 1, '/index:submitted called' } )
    );
    $add->( '/index',
        _e( 'default', sub { ok 1, '/index:default called' } ) );

    $fr->build_route;

    my $app = sub {
        my $env   = shift;
        my $match = $fr->{router}->match($env);
        ok $match, 'matched';
        ok exists $match->{code}->{$_}, "$_ exists"
            for qw/default submitted submitted_and_valid/;
        [ 200, [], ['OK'] ];
    };

    test_psgi $app, sub {
        my $cb = shift;
        is $cb->( GET '/index' )->code, 200, 'GET /index';
    };
};

subtest 'post' => sub {
    my $fr   = _fr();
    my $pkg  = 'MyApp::Web::Post';
    my $opts = { method => [qw/POST/] };

    my $add = sub {
        my ( $pattern, $entity ) = @_;
        $fr->add(
            path    => $pattern,
            pkg     => $pkg,
            pattern => $pattern,
            opts    => $opts,
            entity  => $entity,
        );
    };

    $add->(
        '/index',
        _e( 'submitted_and_valid',
            sub { ok 1, '/index:submitted_and_valid called' }
        )
    );
    $add->(
        '/index', _e( 'submitted', sub { ok 1, '/index:submitted called' } )
    );
    $add->( '/index',
        _e( 'default', sub { ok 1, '/index:default called' } ) );

    $fr->build_route;

    my $app = sub {
        my $env   = shift;
        my $match = $fr->{router}->match($env);
        ok $match, 'matched';
        ok exists $match->{code}->{$_}, "$_ exists"
            for qw/default submitted submitted_and_valid/;
        [ 200, [], ['OK'] ];
    };

    test_psgi $app, sub {
        my $cb = shift;
        is $cb->( POST '/index' )->code, 200, 'POST /index';
    };
};

subtest 'default is get, others are post' => sub {
    my $fr  = _fr();
    my $pkg = 'MyApp::Web::GetandPost';

    my $add = sub {
        my ( $pattern, $entity, $opts ) = @_;
        $fr->add(
            path    => $pattern,
            pkg     => $pkg,
            pattern => $pattern,
            opts    => $opts,
            entity  => $entity,
        );
    };

    $add->(
        '/index',
        _e( 'submitted_and_valid',
            sub { ok 1, '/index:submitted_and_valid called' }
        ),
        { method => [qw/POST/] }
    );
    $add->(
        '/index',
        _e( 'submitted', sub { ok 1, '/index:submitted called' } ),
        { method => [qw/POST/] }
    );
    $add->(
        '/index',
        _e( 'default', sub { ok 1, '/index:default called' } ),
        { method => [qw/GET HEAD/] }
    );

    $fr->build_route;

    my $app = sub {
        my $env   = shift;
        my $match = $fr->{router}->match($env);
        if ( $env->{REQUEST_METHOD} eq 'GET' ) {
            ok $match, 'GET matched';
            ok exists $match->{code}->{default}, "default exists";
        }
        else {
            ok $match, 'POST matched';
            ok exists $match->{code}->{$_}, "$_ exists"
                for qw/submitted submitted_and_valid/;
        }
        [ 200, [], ['OK'] ];
    };

    test_psgi $app, sub {
        my $cb = shift;
        is $cb->( POST '/index' )->code, 200, 'POST /index';
        is $cb->( GET '/index' )->code,  200, 'GET /index';
    };
};

subtest 'any' => sub {
    my $fr  = _fr();
    my $pkg = 'MyApp::Web::ANY';

    my $add = sub {
        my ( $pattern, $entity ) = @_;
        $fr->add(
            path    => $pattern,
            pkg     => $pkg,
            pattern => $pattern,
            opts    => undef,
            entity  => $entity,
        );
    };

    $add->(
        '/index',
        _e( 'submitted_and_valid',
            sub { ok 1, '/index:submitted_and_valid called' }
        )
    );
    $add->(
        '/index', _e( 'submitted', sub { ok 1, '/index:submitted called' } )
    );
    $add->( '/index',
        _e( 'default', sub { ok 1, '/index:default called' } ) );

    $fr->build_route;

    my $app = sub {
        my $env   = shift;
        my $match = $fr->{router}->match($env);
        note $env->{REQUEST_METHOD};
        ok $match, 'matched';
        ok exists $match->{code}->{$_}, "$_ exists"
            for qw/default submitted submitted_and_valid/;
        [ 200, [], ['OK'] ];
    };

    test_psgi $app, sub {
        my $cb = shift;
        is $cb->( GET '/index' )->code,  200, 'GET /index';
        is $cb->( POST '/index' )->code, 200, 'POST /index';
        is $cb->( HEAD '/index' )->code, 200, 'HEAD /index';
        is $cb->( PUT '/index' )->code,  200, 'PUT /index';
    };
};

done_testing;

sub _fr { Koashi::Form::Router->new( router => Router::Simple->new ) }

sub _e {
    Koashi::Form::Entity->new(
        type => shift,
        code => shift
    );
}
