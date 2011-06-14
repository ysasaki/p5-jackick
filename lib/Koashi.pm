package Koashi;
use strict;
use warnings;
use Module::Pluggable::Object;
use Koashi::Dispatcher;
our $VERSION = '0.01';

sub new {
    my $class = shift;
    my %args  = (
        search_path => [],
        @_,
    );
    my $self = bless \%args, $class;
    $self->_load_classes;
    $self;
}

sub _load_classes {
    my $self = shift;

    # just load
    my $finder = Module::Pluggable::Object->new(
        search_path => $self->{search_path},
        require     => 1,
    );
    my @plugins = $finder->plugins;
}

sub to_psgi {
    my $self       = shift;
    my $dispatcher = Koashi::Dispatcher->new;
    return sub {
        my $env      = shift;
        my $response = $dispatcher->dispatch($env);
        return $response->finalize;
    };
}

1;
__END__

=head1 NAME

Koashi -

=head1 SYNOPSIS

  use Koashi;

=head1 DESCRIPTION

Koashi is

=head1 AUTHOR

ysasaki E<lt>aloelight@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
