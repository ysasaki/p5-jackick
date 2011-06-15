package Koashi::Request;

use strict;
use warnings;
use parent 'Plack::Request';
use Koashi::Response;

sub response {
    my $self = shift;
    Koashi::Response->new(@_);
}
1;
