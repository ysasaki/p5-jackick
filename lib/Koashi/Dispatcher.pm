package Koashi::Dispatcher;

use strict;
use warnings;
use Koashi::Controller ();
use Koashi::Request;
use Koashi::Response;
use Log::Minimal;

sub new {
    my $class = shift;
    bless {
        router => Koashi::Controller->router,
        former => Koashi::Controller->former,
    }, $class;
}

sub router { $_[0]->{router} }
sub former { $_[0]->{former} }

sub dispatch {
    my $self = shift;
    my $env  = shift;

    debugf( 'dispatch: %s', $env->{PATH_INFO} || $env );

    my $route = $self->router->match($env);
    my $response;
    if ($route) {
        my $request  = Koashi::Request->new($env);
        my $code     = $route->{code};
        my $codetype = ref $code;

        if ( $codetype && ref $codetype eq 'CODE' ) {
            $response = $route->{code}->( $request, $route );
        }
        elsif ( $codetype && ref $codetype eq 'HASH' ) {
            my $form = HTML::Shakan->new(
                $self->former->{ $route->{pkg} }->{ $route->{pattern} } );

            if ($form) {
                if ( $form->submitted_and_valid ) {
                    debugf( 'dispatch: %s:submitted_and_valid',
                        $route->{pattern} );
                    $response = $code->{submitted_and_valid}->{code}
                        ->( $form, $request, $route );
                }
                elsif ( $form->submitted ) {
                    debugf( 'dispatch: %s:submitted', $route->{pattern} );
                    $response = $code->{submitted}->{code}
                        ->( $form, $request, $route );
                }
                else {
                    debugf( 'dispatch: %s:default', $route->{pattern} );
                    $response
                        = $code->{default}->{code}->( $request, $route );
                }
            }
            else {
                warnf( "form for %s does not find. use default code instead",
                    $code->{pattern} );
                $response
                    = $code->{default}->{code}->( undef, $request, $route );
            }
        }
        else {
            debugf( 'dispatch: unknown codetype: %s',
                $codetype || '__UNDEF__' );
            $response = _r( 500, [], ['Internal Server Error'] );
        }

    }
    else {
        $response = _r( [ 404, [], ['Not Found'] ] );
    }
    return $response;
}

sub _r { Koashi::Response->new(@_) }
1;
