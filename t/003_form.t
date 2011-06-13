use strict;
use warnings;
use Test::More;
use Koashi::Controller;

subtest 'submitted_and_valid' => sub {

    my $code = submitted_and_valid {
        ok 1, 'inner coderef is called';
    };

    isa_ok $code, 'CODE', 'submitted_and_valid return coderef';
    $code->();
};

subtest 'submitted' => sub {

    my $code = submitted {
        ok 1, 'inner coderef is called';
    };

    isa_ok $code, 'CODE', 'submitted return coderef';
    $code->();
};

subtest 'default' => sub {

    my $code = default {
        ok 1, 'inner coderef is called';
    };

    isa_ok $code, 'CODE', 'submitted return coderef';
    $code->();
};
done_testing;
