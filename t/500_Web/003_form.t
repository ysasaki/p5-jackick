use strict;
use warnings;
use Test::More;
use Koashi::Web;

subtest 'submitted_and_valid' => sub {

    package MyApp::C::Root;
    use Koashi::Web;
    use Test::More;

    prefix '';

    my @fields = ( TextField( name => 'title', required => 1 ) );
    form '/save', \@fields;

    my $form = Koashi::Web->former;
    is_deeply $form->{'MyApp::C::Root'}->{'/save'}, \@fields,
        'form data is saved';

    my $code = submitted_and_valid {
        ok 1, 'inner coderef is called';
        my $form = shift;
    };

    isa_ok $code, 'Koashi::Form::Entity',
        'submitted_and_valid return Koashi::Form::Entity';

    post '/save', $code;

};

subtest 'submitted' => sub {

    my $code = submitted {
        ok 1, 'inner coderef is called';
    };

    isa_ok $code, 'Koashi::Form::Entity',
        'submitted return Koashi::Form::Entity';
};

subtest 'default' => sub {

    my $code = default {
        ok 1, 'inner Koashi::Form::Entity is called';
    };

    isa_ok $code, 'Koashi::Form::Entity',
        'default return Koashi::Form::Entity';
};
done_testing;
