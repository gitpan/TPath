package TPath::Selector::Quantified;
{
  $TPath::Selector::Quantified::VERSION = '0.011';
}

# ABSTRACT: handles expressions like C<a?> and C<//foo*>


use v5.10;
use Moose;
use TPath::TypeConstraints;
use namespace::autoclean;


with 'TPath::Selector';


has s => ( is => 'ro', isa => 'TPath::Selector', required => 1 );


has quantifier => ( is => 'ro', isa => 'Quantifier', required => 1 );


has top => ( is => 'ro', isa => 'Int', default => 0 );


has bottom => ( is => 'ro', isa => 'Int', default => 0 );

sub select {
	my ( $self, $n, $i, $first ) = @_;
	my @c = $self->s->select( $n, $i, $first );
	for ( $self->quantifier ) {
		when ('?') { return @c, $n }
		when ('*') { return @{ _iterate( $self->s, $i, \@c ) }, $n }
		when ('+') { return @{ _iterate( $self->s, $i, \@c ) } }
		when ('e') {
			my ( $s, $top, $bottom ) =
			  ( $self->s, $self->top, $self->bottom );
			my $c = _enum_iterate( $s, $i, \@c, $top, $bottom, 1 );
			return @$c, $self->bottom < 2 ? $n : ();
		}
	}
}

sub _enum_iterate {
	my ( $s, $i, $c, $top, $bottom, $count ) = @_;
	my @next = map { $s->select( $_, $i ) } @$c;
	my @return = $count++ >= $bottom ? @$c : ();
	unshift @return, @next
	  if $count >= $bottom && ( !$top || $count <= $top );
	unshift @return, @{ _iterate( $s, $i, \@next, $top, $bottom, $count ) }
	  if !$top || $count < $top;
	return \@return;
}

sub _iterate {
	my ( $s, $i, $c ) = @_;
	return [] unless @$c;
	my @next = map { $s->select( $_, $i ) } @$c;
	return [ @{ _iterate( $s, $i, \@next ) }, @$c ];
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Quantified - handles expressions like C<a?> and C<//foo*>

=head1 VERSION

version 0.011

=head1 DESCRIPTION

Selector that applies a quantifier to an ordinary selector.

=head1 ATTRIBUTES

=head2 s

The selector to which the quantifier is applied.

=head2 quantifier

The quantifier.

=head2 top

The largest number of iterations permitted. If 0, there is no limit. Used only by
the C<{x,y}> quantifier.

=head2 bottom

The smallest number of iterations permitted. Used only by the C<{x,y}> quantifier.

=head1 ROLES

L<TPath::Selector>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
