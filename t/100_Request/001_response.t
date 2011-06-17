use strict;
use warnings;
use Test::More;
use JacKick::Request;

my $req = JacKick::Request->new( +{} );

my $res = $req->response( 404, [], ['Not Found'] );
isa_ok $res, 'JacKick::Response';
isa_ok $res, 'Plack::Response';

done_testing;
