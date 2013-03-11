package TPath::Selector::Test;
{
  $TPath::Selector::Test::VERSION = '0.005';
}

# ABSTRACT: role of selectors that apply some test to a node to select it


use Moose::Role;
use TPath::TypeConstraints;


with 'TPath::Selector';


has predicates => (
    is         => 'ro',
    isa        => 'ArrayRef[TPath::Predicate]',
    default    => sub { [] },
    auto_deref => 1
);


has axis =>
  ( is => 'ro', isa => 'Axis', writer => '_axis', default => sub { 'child' } );

# axis translated into a forester method name
has faxis => (
    is   => 'ro',
    isa  => 'Str',
    lazy => 1,
    default =>
      sub { my $self = shift; ( my $v = $self->axis ) =~ tr/-/_/; "axis_$v" }
);


has node_test =>
  ( is => 'ro', isa => 'TPath::Test::Node', writer => '_node_test' );


sub candidates {
    my ( $self, $n, $i ) = @_;
    my $axis = $self->faxis;
    $i->f->$axis( $n, $self->node_test, $i );
}

# implements method required by TPath::Selector
sub select {
    my ( $self, $n, $i ) = @_;
    my @candidates = $self->candidates( $n, $i );
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

version 0.005

=head1 DESCRIPTION

A L<TPath::Selector> that holds a list of L<TPath::Predicate>s.

=head1 ATTRIBUTES

=head2 predicates

Auto-deref'ed list of L<TPath::Predicate> objects that filter anything selected
by this selector.

=head2 axis

The axis on which nodes are sought; C<child> by default.

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
