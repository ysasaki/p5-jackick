package Koashi::Controller;

use strict;
use warnings;
use parent 'Exporter';
use Router::Simple;

our @EXPORT = qw/
    prefix
    any get post
    submitted_and_valid submitted default
    /;

my $ROUTER = Router::Simple->new();
my %PREFIX;

sub prefix {
    my $pkg = caller(0);
    $PREFIX{$pkg} = shift;
}

sub _add_prefix {
    my $pkg = caller(0);
    my $path = shift;
    my $prefix = $PREFIX{$pkg};
    if ( $path && $prefix ) {
        return sprintf '%s%s', $prefix, shift;
    }
    else {
        return $prefix || '';
    }
}

# post '/' => submitted_and_valid { # code block };
sub submitted_and_valid(&) {
    my $code = shift;
    sub {
        my $form;
        $code->($form, @_);
    };
}

# post '/' => submitted { # code block };
sub submitted(&) {
    my $code = shift;
    sub {
        my $form;
        $code->($form, @_);
    };
}

# post '/' => default { # code block };
sub default(&) { $_[0] }

# copy from Router::Simple::Sinatraish 0.02
# any [qw/get post delete/] => '/bye' => sub { ... };
# any '/bye' => sub { ... };
sub any($$;$) {
    if ( @_ == 3 ) {
        my ( $methods, $pattern, $code ) = @_;
        $ROUTER->connect(
            _add_prefix($pattern),
            { code   => $code },
            { method => [ map { uc $_ } @$methods ] }
        );
    }
    else {
        my ( $pattern, $code ) = @_;
        $ROUTER->connect( _add_prefix($pattern), { code => $code }, );
    }
}

sub get {
    $ROUTER->connect(
        _add_prefix( $_[0] ),
        { code   => $_[1] },
        { method => [ 'GET', 'HEAD' ] }
    );
}

sub post {
    $ROUTER->connect(
        _add_prefix( $_[0] ),
        { code   => $_[1] },
        { method => ['POST'] }
    );
}

sub router {$ROUTER}
1;
