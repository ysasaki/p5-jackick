use strict;
use warnings;
use Test::More;
use Koashi;

my $app = Koashi->new->to_psgi;
isa_ok $app, 'CODE', 'to_psgi return coderef';

done_testing;
