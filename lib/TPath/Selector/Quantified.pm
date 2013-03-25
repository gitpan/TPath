package TPath::Selector::Quantified;
{
  $TPath::Selector::Quantified::VERSION = '0.009';
}

# ABSTRACT: handles expressions like C<a?> and C<//foo*>


use v5.10;
use Moose;
use TPath::TypeConstraints;
use namespace::autoclean;


with 'TPath::Selector';


has s => ( is => 'ro', isa => 'TPath::Selector', required => 1 );


has quantifier => ( is => 'ro', isa => 'Quantifier', required => 1 );

sub select {
	my ( $self, $n, $i, $first ) = @_;
	my @c = $self->s->select( $n, $i, $first );
	for ( $self->quantifier ) {
		when ('?') { return @c, $n }
		when ('*') { return @{ _iterate( $self->s, $first, $i, \@c ) }, $n }
		when ('+') { return @{ _iterate( $self->s, $first, $i, \@c ) } }
	}
}

sub _iterate {
	my ( $s, $first, $i, $c ) = @_;
	return [] unless @$c;
	my @next = map { $s->select( $_, $i, $first ) } @$c;
	return [ @{ _iterate( $s, $first, $i, \@next ) }, @$c ];
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Quantified - handles expressions like C<a?> and C<//foo*>

=head1 VERSION

version 0.009

=head1 DESCRIPTION

Selector that applies a quantifier to an ordinary selector.

=head1 ATTRIBUTES

=head2 s

The selector to which the quantifier is applied.

=head2 quantifier

The quantifier.

=head1 ROLES

L<TPath::Selector>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
