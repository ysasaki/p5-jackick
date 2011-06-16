use strict;
use warnings;
use Test::More;
use Koashi::Request;

my $req = Koashi::Request->new( +{} );

my $res = $req->response( 404, [], ['Not Found'] );
isa_ok $res, 'Koashi::Response';
isa_ok $res, 'Plack::Response';

done_testing;
