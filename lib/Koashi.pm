package Koashi;
use strict;
use warnings;
our $VERSION = '0.01';

sub new {
    my $class = shift;
    bless {}, $class;
}

sub to_psgi {
    return sub {

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
