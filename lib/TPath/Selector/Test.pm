package TPath::Selector::Test;
{
  $TPath::Selector::Test::VERSION = '0.013';
}

# ABSTRACT: role of selectors that apply some test to a node to select it


use v5.10;
use Moose::Role;
use TPath::TypeConstraints;
use TPath::Test::Node::Complement;


with 'TPath::Selector';


has predicates => (
    is         => 'ro',
    isa        => 'ArrayRef[TPath::Predicate]',
    default    => sub { [] },
    auto_deref => 1
);


has axis =>
  ( is => 'ro', isa => 'Axis', writer => '_axis', default => 'child' );


has first_sensitive => ( is => 'ro', isa => 'Bool', default => 0 );

# axis translated into a forester method name
has faxis => (
    is   => 'ro',
    isa  => 'Str',
    lazy => 1,
    default =>
      sub { my $self = shift; ( my $v = $self->axis ) =~ tr/-/_/; "axis_$v" }
);


has is_inverted =>
  ( is => 'ro', isa => 'Bool', default => 0, writer => '_mark_inverted' );

around 'to_string' => sub {
    my ( $orig, $self, @args ) = @_;
    my $s = $self->$orig(@args);
    for my $p ( @{ $self->predicates } ) {
        $s .= '[' . $p->to_string . ']';
    }
    return $s;
};

sub _stringify_match {
    my ( $self, $re ) = @_;

    # chop off the "(?-xism:" prefix and ")" suffix
    $re = substr $re, 8, length($re) - 9;
    $re =~ s/~/~~/g;
    return "~$re~";
}


has node_test =>
  ( is => 'ro', isa => 'TPath::Test::Node', writer => '_node_test' );

sub _invert {
    my $self = shift;
    $self->_node_test(
        TPath::Test::Node::Complement->new( nt => $self->node_test ) );
    $self->_mark_inverted(1);
}


sub candidates {
    my ( $self, $n, $i, $first ) = @_;
    my $axis = $self->_select_axis($first);
    $i->f->$axis( $n, $self->node_test, $i );
}

sub _select_axis {
    my ( $self, $first ) = @_;
    if ( $first && $self->first_sensitive ) {
        for ( $self->axis ) {
            when ('child')      { return 'axis_self' }
            when ('descendant') { return 'axis_descendant_or_self' }
        }
    }
    return $self->faxis;
}

# implements method required by TPath::Selector
sub select {
    my ( $self, $n, $i, $first ) = @_;
    my @candidates = $self->candidates( $n, $i, $first );
    for my $p ( $self->predicates ) {
        last unless @candidates;
        @candidates = $p->filter( $i, \@candidates );
    }
    return @candidates;
}

1;

__END__

=pod

=head1 NAME

TPath::Selector::Test - role of selectors that apply some test to a node to select it

=head1 VERSION

version 0.013

=head1 DESCRIPTION

A L<TPath::Selector> that holds a list of L<TPath::Predicate>s.

=head1 ATTRIBUTES

=head2 predicates

Auto-deref'ed list of L<TPath::Predicate> objects that filter anything selected
by this selector.

=head2 axis

The axis on which nodes are sought; C<child> by default.

=head2 first_sensitive

Whether this this test may use a different axis depending on whether it is the first
step in a path.

=head2 is_inverted

Whether the test corresponds to a complement selector.

=head2 node_test

The test that is applied to select candidates on an axis.

=head1 METHODS

=head2 candidates

Expects a node and an index and returns nodes selected before filtering by predicates.

=head1 ROLES

L<TPath::Selector>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
