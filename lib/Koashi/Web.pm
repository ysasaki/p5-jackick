package Koashi::Web;

use strict;
use warnings;
use parent 'Exporter';
use Sub::Args;
use Router::Simple;
use HTML::Shakan ();    # for loading HTML::Shakan::Fields::*
use HTML::Shakan::Fields;
use Koashi::Form::Entity;
use Koashi::Form::Router;
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
    my ( $pattern, $data ) = args_pos( 1, 1 );
    $FORM_DEFINITION{$pkg}->{$pattern} = $data;
}

my $FORM_ROUTER = Koashi::Form::Router->new( router => $ROUTER );

sub build_route_from_form {
    $FORM_ROUTER->build_route;
}

#===============================================================================
my %PREFIX;

sub prefix {
    my $pkg = caller(0);
    ( $PREFIX{$pkg} ) = args_pos(1);
}

sub _add_prefix {
    my ( $pkg, $path ) = args_pos( 1, 1 );
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
    my ( $pattern, $code ) = args_pos( 1, 1 );
    _connect( $pkg, $pattern, $code, { method => [ 'GET', 'HEAD' ] } );
}

sub post {
    my $pkg = caller(0);
    my ( $pattern, $code ) = args_pos( 1, 1 );
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
        $FORM_ROUTER->add(
            pkg     => $pkg,
            pattern => $pattern,
            opts    => $opts,
            path    => $path,
            entity  => $code,
        );
    }
    else {
        croakf
            "second argument must be coderef or object is-a Koashi::Form::Entity";
    }
}

1;
