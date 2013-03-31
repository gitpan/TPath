package TPath::Selector::Expression;
{
  $TPath::Selector::Expression::VERSION = '0.010';
}

# ABSTRACT: selector that handles the parenthesized portion of C<a(/foo|/bar)> and C<a(/foo|/bar)+>


use v5.10;
use Moose;
use TPath::TypeConstraints;
use namespace::autoclean;


with 'TPath::Selector';


has e => ( is => 'ro', isa => 'TPath::Expression', required => 1 );

sub select {
	my ( $self, $n, $i, $first ) = @_;
	return @{ $self->e->_select( $n, $i, $first ) };
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Expression - selector that handles the parenthesized portion of C<a(/foo|/bar)> and C<a(/foo|/bar)+>

=head1 VERSION

version 0.010

=head1 DESCRIPTION

A selector that handles grouped steps as in C<a(/foo|//bar)?/baz>. This does not handle the quantification, which is
delegated to L<TPath::Selector::Quantified>.

=head1 ATTRIBUTES

=head2 e

The expression within the group.

=head1 ROLES

L<TPath::Selector>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
