package Koashi::Form::Router;

use strict;
use warnings;
use Sub::Args;
use Log::Minimal;
use Digest::MD5;
use namespace::autoclean;

sub new {
    my $class = shift;
    my $args = args( { router => 1 } );
    bless { route => +{}, router => $args->{router} }, $class;
}

sub add {
    my $self = shift;
    my $args = args(
        {   pkg     => 1,
            pattern => 1,
            opts    => 0,
            path    => 1,
            entity  => 1,
        }
    );

    my @methods = $args->{opts} ? @{ $args->{opts}->{method} } : ('ANY');
    my $opts_key = join ',', map { uc $_ } sort @methods;

    my $entity_type = $args->{entity}->type;
    my $route
        = $self->{route}->{ $args->{pkg} }->{ $args->{pattern} }->{$opts_key};

    if ($route) {
        my $code     = $route->[1]->{code};
        my $codetype = ref $code;
        if ( $codetype && $codetype eq 'HASH' ) {
            if ( exists $code->{$entity_type} ) {
                my $method = sprintf '%s:%s', $args->{path}, $entity_type;
                croakf
                    sprintf(
                    "you tried to define %s:%s, but %s:%s is already defined",
                    $method, $method );

            }
            else {
                $code->{$entity_type} = $args->{entity}->code;
            }
        }
        else {
            croakf
                sprintf(
                "you tried to define %s:%s, but %s is already defined",
                $args->{path}, $entity_type, $args->{path} );
        }
    }
    else {
        $self->{route}->{ $args->{pkg} }->{ $args->{pattern} }->{$opts_key}
            = [
            $args->{path},
            {   code    => { $entity_type => $args->{entity}->code },
                pattern => $args->{pattern},
                pkg     => $args->{pkg},
            },
            $args->{opts},
            ];
    }
}

sub build_route {
    my $self  = shift;
    my $route = $self->{route};
    for my $pkg ( keys %$route ) {
        my $in_pkg = delete $route->{$pkg};
        for my $pattern ( keys %$in_pkg ) {
            for my $opts_key ( keys %{ $in_pkg->{$pattern} } ) {
                my ( $path, $args, $opts )
                    = @{ $in_pkg->{$pattern}->{$opts_key} };

                debugf(
                    'define method: [%s] %s:[%s] in %s',
                    $opts->{method}
                    ? join( ',', sort @{ $opts->{method} } )
                    : '',
                    $path,
                    join( ',', sort keys %{ $args->{code} } ),
                    $pkg
                );

                $self->{router}->connect( $path, $args, $opts );
            }
        }
    }
}

1;
