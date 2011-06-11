use strict;
use warnings;
use MyApp;
use Plack::Builder;

my $app = MyApp->new->to_psgi;
builder {
    $app;
};
