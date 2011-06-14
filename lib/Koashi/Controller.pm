package Koashi::Controller;

use strict;
use warnings;
use parent 'Exporter';
use Carp;
use Router::Simple;
use HTML::Shakan ();    # for loading HTML::Shakan::Fields::*
use HTML::Shakan::Fields;
use Koashi::Form::Entity;
use Scalar::Util qw(blessed);
use Log::Minimal;
use namespace::autoclean;

our @EXPORT = qw/
    prefix
    any get post
    submitted_and_valid submitted default
    form
    /;

sub import {
    my $class = shift;
    $class->export_to_level(1);
    HTML::Shakan::Fields->export_to_level(1);
}

#===============================================================================
my $ROUTER = Router::Simple->new();
sub router {$ROUTER}

#===============================================================================
my %FORM;
sub former {\%FORM}

sub form {
    my $pkg = caller(0);
    my ( $pattern, $data ) = @_;
    $FORM{$pkg}->{$pattern} = $data;
}

#===============================================================================
my %PREFIX;

sub prefix {
    my $pkg = caller(0);
    $PREFIX{$pkg} = shift;
}

sub _add_prefix {
    my $pkg    = caller(0);
    my $path   = shift;
    my $prefix = $PREFIX{$pkg};
    return sprintf '%s%s', $prefix || '', $path || '';
}

#===============================================================================
# post '/' => submitted_and_valid { # code block };
sub submitted_and_valid(&) {
    Koashi::Form::Entity->new(
        code => $_[0],
        type => 'submitted_and_valid'
    );
}

# post '/' => submitted { # code block };
sub submitted(&) {
    Koashi::Form::Entity->new(
        code => $_[0],
        type => 'submitted'
    );
}

# post '/' => default { # code block };
sub default(&) {
    Koashi::Form::Entity->new(
        code => $_[0],
        type => 'default',
    );
}

#===============================================================================
# copy from Router::Simple::Sinatraish 0.02
# any [qw/get post delete/] => '/bye' => sub { ... };
# any '/bye' => sub { ... };
sub any($$;$) {
    if ( @_ == 3 ) {
        my ( $methods, $pattern, $code ) = @_;
        debugf( 'define method: any %s method:%s',
            $pattern, join ',', map { uc $_ } @$methods );
        _connect( $pattern, $code,
            { method => [ map { uc $_ } @$methods ] } );
    }
    else {
        my ( $pattern, $code ) = @_;
        debugf( 'define method: any %s', $pattern );
        _connect( $pattern, $code );
    }
}

sub get {
    my ( $pattern, $code ) = @_;
    debugf( 'define method: get %s', $pattern );
    _connect( $pattern, $code, { method => [ 'GET', 'HEAD' ] } );
}

sub post {
    my ( $pattern, $code ) = @_;
    debugf( 'define method: post %s', $pattern );
    _connect( $pattern, $code, { method => ['POST'] } );
}

sub _connect {
    my $pkg = caller(0);
    my ( $pattern, $code, $opts ) = @_;
    my $path    = _add_prefix($pattern);
    my $reftype = ref $code;
    if ( $reftype && $reftype eq 'CODE' ) {
        $ROUTER->connect( $path, { code => $code }, $opts );
    }
    elsif ( blessed($code) && $code->isa('Koashi::Form::Entity') ) {
        my $route = $ROUTER->match($path);
        if ($route) {
            my $codetype = ref $route->{code};
            if ( $codetype && $codetype eq 'HASH' ) {
                if ( exists $route->{code}->{ $code->type } ) {
                    croak
                        sprintf(
                        "you tried to define %s:%s, but %s:%s is already defined",
                        $path, $code->type, $path, $code->type );

                }
                else {
                    $route->{code}->{ $code->type } = $code->code;
                }
            }
            else {
                croak
                    sprintf(
                    "you tried to define %s:%s, but %s is already defined",
                    $path, $code->type, $path );
            }
        }
        else {
            $ROUTER->connect(
                $path,
                {   code    => { $code->type => $code->code },
                    pattern => $pattern,
                    pkg     => $pkg,
                },
                $opts
            );
        }
    }
    else {
        croak
            "second argument must be coderef or object is-a Koashi::Form::Entity";
    }
}

1;
