package JacKick::Request;

use strict;
use warnings;
use parent 'Plack::Request';
use JacKick::Response;

sub response {
    my $self = shift;
    JacKick::Response->new(@_);
}
1;
