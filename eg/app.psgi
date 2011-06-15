use strict;
use warnings;
use MyApp;
use Plack::Builder;

my $app = MyApp->new( search_path => ['MyApp::C'] )->to_psgi;
builder {
    $app;
};
