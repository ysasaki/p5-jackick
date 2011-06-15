package Koashi::Dispatcher;

use strict;
use warnings;
use Koashi::Controller ();
use Koashi::Request;
use Koashi::Response;
use Log::Minimal;
use Scalar::Util qw(blessed);
use namespace::autoclean;

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

    my $route = $self->router->match($env);
    my $response;
    if ($route) {
        my $request  = Koashi::Request->new($env);
        my $code     = $route->{code};
        my $codetype = ref $code;

        if ( $codetype && $codetype eq 'CODE' ) {
            $response = $route->{code}->( $request, $route );
        }
        elsif ( $codetype && $codetype eq 'HASH' ) {
            $response = $self->_dispatch_form( $request, $code, $route );
        }
        else {
            debugf( 'dispatch failed: unknown codetype: %s',
                $codetype || '__UNDEF__' );
            $response = [ 404, [], ['Not Found'] ];
        }
    }
    else {
        $response = [ 404, [], ['Not Found'] ];
    }

    if ( $response && blessed($response) && $response->isa('Plack::Response') )
    {
        return $response;
    }
    elsif ( $response && ref $response eq 'ARRAY' ) {
        return $self->_make_response(@$response);
    }
    else {
        croakff(
            'response failed: request for %s %s did not return arrayref or object is-a Plack::Response. resposne: %s',
            $env->{REQUEST_METHOD} || 'GET',
            $env->{PATH_INFO} || $env,
            ddf($response)
        );
    }
}

#===============================================================================
sub _make_response {
    my $self = shift;
    Koashi::Response->new(@_);
}

sub _dispatch_form {
    my $self = shift;
    my ( $request, $code, $route ) = @_;
    my $form_difinition
        = $self->former->{ $route->{pkg} }->{ $route->{pattern} };

    my $response;
    if ($form_difinition) {
        my $form = $self->_make_form( $request, $form_difinition );
        if ( $form->submitted_and_valid ) {
            $response
                = $self->_exec( $code, 'submitted_and_valid', $form, $request,
                $route );
        }
        elsif ( $form->submitted ) {
            $response
                = $self->_exec( $code, 'submitted', $form, $request, $route );
        }
        else {
            $response
                = $self->_exec( $code, 'default', undef, $request, $route );
        }
    }
    else {
        warnf(
            "dispatch failed: %s's seem to be form, but form data did not find",
            $route->{pattern}
        );
        debugf( 'form:%s',  ddf( $self->former ) );
        debugf( 'route:%s', ddf($route) );
        $response = $self->_make_response( 404, [], ['Not Found'] );
    }

    return $response;
}

sub _make_form {
    my $self = shift;
    my ( $request, $data ) = @_;
    my $reftype = ref $data;

    my %args;
    if ( $reftype && $reftype eq 'ARRAY' ) {
        %args = ( fields => $data, request => $request );
    }
    elsif ( $reftype && $reftype eq 'HASH' ) {
        %args = ( %$data, request => $request );
    }
    else {
        croakff( 'form failed: form definition is invalid: %s', ddf($data) );
    }
    return HTML::Shakan->new(%args);
}

sub _exec {
    my $self = shift;
    my ( $code, $type, $form, $request, $route ) = @_;
    debugf( 'dispatch: %s:%s', $route->{pattern}, $type );

    my $_code = $code->{$type};
    if ( !$_code or ref $_code ne 'CODE' ) {
        croakff( 'exec failed: %s:%s is not defined or not a code reference',
            $route->{pattern}, $type );
    }

    my @args = $form ? ( $form, $request, $route ) : ( $request, $route );
    return $_code->(@args);

}

1;
