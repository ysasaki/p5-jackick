package Koashi::Controller;

use strict;
use warnings;
use parent 'Exporter';
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
my %FORM_DEFINITION;
sub former { \%FORM_DEFINITION }

sub form {
    my $pkg = caller(0);
    my ( $pattern, $data ) = @_;
    $FORM_DEFINITION{$pkg}->{$pattern} = $data;
}

my %FORM_ROUTE;

sub build_route_from_form {
    my $class = shift;
    for my $pkg ( keys %FORM_ROUTE ) {
        my $in_pkg = delete $FORM_ROUTE{$pkg};
        my @route_info;
        for my $pattern ( keys %$in_pkg ) {
            my ( $path, $args, $opts ) = @{ $in_pkg->{$pattern} };
            debugf(
                'define method: [%s] %s:[%s] in %s',
                $opts->{method} ? join( ',', sort @{ $opts->{method} } ) : '',
                $path,
                join( ',', sort keys %{ $args->{code} } ),
                $pkg
            );

            $route_info[0] ||= $path;
            if ( $route_info[1] ) {
                $route_info[1]->{code}
                    = { %{ $route_info[1]->{code} }, %{ $args->{code} } };
                $route_info[1]->{pattern} ||= $args->{pattern};
                $route_info[1]->{pkg}     ||= $args->{pkg};
            }
            else {
                $route_info[1] = $args;
            }
            $route_info[2] ||= $opts;
        }
        $ROUTER->connect(@route_info);
    }
}

#===============================================================================
my %PREFIX;

sub prefix {
    my $pkg = caller(0);
    $PREFIX{$pkg} = shift;
}

sub _add_prefix {
    my ( $pkg, $path ) = @_;
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
    my $pkg = caller(0);
    if ( @_ == 3 ) {
        my ( $methods, $pattern, $code ) = @_;
        _connect( $pkg, $pattern, $code,
            { method => [ map { uc $_ } @$methods ] } );
    }
    else {
        my ( $pattern, $code ) = @_;
        _connect( $pkg, $pattern, $code );
    }
}

sub get {
    my $pkg = caller(0);
    my ( $pattern, $code ) = @_;
    _connect( $pkg, $pattern, $code, { method => [ 'GET', 'HEAD' ] } );
}

sub post {
    my $pkg = caller(0);
    my ( $pattern, $code ) = @_;
    _connect( $pkg, $pattern, $code, { method => ['POST'] } );
}

sub _connect {
    my ( $pkg, $pattern, $code, $opts ) = @_;
    my $path = _add_prefix( $pkg, $pattern );
    my $reftype = ref $code;
    if ( $reftype && $reftype eq 'CODE' ) {
        debugf(
            'define method: [%s] %s',
            join( ',',
                ( exists $opts->{method} ? @{ $opts->{method} } : '' ) ),
            $path
        );
        $ROUTER->connect( $path, { code => $code }, $opts );
    }
    elsif ( blessed($code) && $code->isa('Koashi::Form::Entity') ) {
        my $form = $FORM_ROUTE{$pkg}->{$pattern};
        if ($form) {
            my $_code    = $FORM_ROUTE{$pkg}->{$pattern}->[1]->{code};
            my $codetype = ref $_code;
            if ( $codetype && $codetype eq 'HASH' ) {
                if ( exists $_code->{ $code->type } ) {
                    croakf
                        sprintf(
                        "you tried to define %s:%s, but %s:%s is already defined",
                        $path, $code->type, $path, $code->type );

                }
                else {
                    $_code->{ $code->type } = $code->code;
                }
            }
            else {
                croakf
                    sprintf(
                    "you tried to define %s:%s, but %s is already defined",
                    $path, $code->type, $path );
            }
        }
        else {
            $FORM_ROUTE{$pkg}->{$pattern} = [
                $path,
                {   code    => { $code->type => $code->code },
                    pattern => $pattern,
                    pkg     => $pkg,
                },
                $opts
            ];
        }
    }
    else {
        croakf
            "second argument must be coderef or object is-a Koashi::Form::Entity";
    }
}

1;
