use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

{

    package MyApp;
    use parent 'Koashi';

    package MyApp::C::Root;
    use Koashi::Controller;
    use Test::More;

    post '/' => sub {
        my ( $request, $route ) = @_;
        isa_ok $request, 'Koashi::Request';
        isa_ok $route,   'HASH';
        $request->response( 200, [ 'Content-Type', 'text/plain' ],
            ["Hello, world!\n"] );
    };

    form '/home' => {
        fields => [
            IntField(
                name     => 'users_id',
                required => 1,
            ),
        ],
        custom_validation => sub {
            my $form = shift;
            if ( $form->is_valid ) {
                if ( $form->param('users_id') >= 10 ) {
                    $form->set_error( 'users_id', 'greater_than' );
                }
            }
        },
    };

    post '/home' => submitted_and_valid {
        ok 1, '/home:submitted_and_valid is called';
        my ( $form, $request, $route ) = @_;
        isa_ok $form,    'HTML::Shakan';
        isa_ok $request, 'Koashi::Request';
        isa_ok $route,   'HASH';
        [ 200, [ 'Content-Type', 'text/plain' ], ['OK'] ];
    };

    my $first = 0;
    post '/home' => submitted {
        ok 1, '/home:submitted is called';
        my ( $form, $request, $route ) = @_;
        unless ( $first++ ) {
            isa_ok $form,    'HTML::Shakan';
            isa_ok $request, 'Koashi::Request';
            isa_ok $route,   'HASH';
        }
        [   200,
            [ 'Content-Type', 'text/plain' ],
            [ sprintf( 'users_id=%s', $form->param('users_id') || '' ) ]
        ];
    };

    post '/home' => default {
        ok 1, '/home:default is called';
        my ( $request, $route ) = @_;
        isa_ok $request, 'Koashi::Request';
        isa_ok $route,   'HASH';
        [ 200, [ 'Content-Type', 'text/plain' ], ['OK'] ];
    };
}

my $app = MyApp->new( search_path => 'MyApp::C' )->to_psgi;
test_psgi $app, sub {
    my $cb = shift;

    subtest 'POST /' => sub {
        my $res = $cb->( POST '/' );
        is $res->code, 200, 'code is 200';
        is $res->content, "Hello, world!\n", 'content ok';
    };

    subtest 'HEAD /' => sub {
        my $res = $cb->( HEAD '/' );
        is $res->code, 404, 'code is 404';
    };

    subtest 'GET /' => sub {
        my $res = $cb->( GET '/' );
        is $res->code, 404, 'code is 404';
    };

    subtest 'PUT /' => sub {
        my $res = $cb->( PUT '/' );
        is $res->code, 404, 'code is 404';
    };

    subtest 'POST /not_found' => sub {
        my $res = $cb->( POST '/not_found' );
        is $res->code,    404,         'code is 404';
        is $res->content, "Not Found", 'content ok';
    };

    subtest 'POST /home:default' => sub {
        my $res = $cb->( POST '/home', Content => [] );
        is $res->code,    200,  'code is 200';
        is $res->content, "OK", 'content ok';
    };

    subtest 'POST /home:submitted' => sub {
        my $res = $cb->( POST '/home', Content => [ users_id => undef ] );
        is $res->code,    200,         'code is 200';
        is $res->content, "users_id=", 'content ok';

        $res = $cb->( POST '/home', Content => [ users_id => 30 ] );
        is $res->code,    200,           'code is 200';
        is $res->content, "users_id=30", 'content ok';
    };

    subtest 'POST /home:submitted_and_valid' => sub {
        my $res = $cb->( POST '/home', Content => [ users_id => 1 ] );
        is $res->code,    200,  'code is 200';
        is $res->content, "OK", 'content ok';
    };
};

done_testing;
