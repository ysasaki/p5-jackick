package Koashi::Form::Entity;

use strict;
use warnings;

sub new {
    my $class = shift;
    my %args  = @_;

    bless {
        code => $args{code},
        type => $args{type},
    }, $class;
}

sub code { $_[0]->{code} }
sub type { $_[0]->{type} }
1;

