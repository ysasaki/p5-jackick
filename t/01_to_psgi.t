use strict;
use warnings;
use Test::More;
use JacKick;

my $app = JacKick->new->to_psgi;
isa_ok $app, 'CODE', 'to_psgi return coderef';

done_testing;
