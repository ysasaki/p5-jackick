package JacKick;

use 5.008008;
use strict;
use warnings;
use Module::Pluggable::Object;
use JacKick::Dispatcher;
use JacKick::Web ();
use Log::Minimal;

our $VERSION = '0.02';

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
    JacKick::Web->build_route_from_form;

    if (   $ENV{PLACK_ENV}
        && $ENV{PLACK_ENV} eq 'development'
        && $ENV{SHOW_KOASHI_ROUTE} )
    {
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )
            = localtime(time);
        my $time = sprintf(
            "%04d-%02d-%02dT%02d:%02d:%02d",
            $year + 1900,
            $mon + 1, $mday, $hour, $min, $sec
        );
        my $route_info = "$time [DEBUG] current route information\n";
        $route_info .= JacKick::Web->router->as_string;
        warn $route_info;
    }

}

sub to_psgi {
    my $self       = shift;
    my $dispatcher = JacKick::Dispatcher->new;
    return sub {
        my $env      = shift;
        my $response = $dispatcher->dispatch($env);
        return $response->finalize;
    };
}

1;
__END__

=head1 NAME

JacKick -

=head1 SYNOPSIS

  use JacKick;

=head1 DESCRIPTION

JacKick is

=head1 AUTHOR

ysasaki E<lt>aloelight@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
