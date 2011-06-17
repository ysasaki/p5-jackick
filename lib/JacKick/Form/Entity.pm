package JacKick::Form::Entity;

use strict;
use warnings;
use Sub::Args;
use namespace::clean;

sub new {
    my $class = shift;
    my $args  = args( { code => 1, type => 1 } );

    bless {
        code => $args->{code},
        type => $args->{type},
    }, $class;
}

sub code { $_[0]->{code} }
sub type { $_[0]->{type} }

1;
