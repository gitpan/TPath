package TPath::Selector::Test::ChildMatch;
{
  $TPath::Selector::Test::ChildMatch::VERSION = '0.004';
}

# ABSTRACT: handles C</~foo~> where this is not the first step in the path, or C<child::~foo~>

use Moose;
use TPath::Test::Node::Match;
use namespace::autoclean;


with 'TPath::Selector::Test';

has rx => ( is => 'ro', isa => 'RegexpRef', required => 1 );

sub BUILD {
    my $self = shift;
    $self->_node_test( TPath::Test::Node::Match->new( rx => $self->rx ) );
}


sub candidates {
    my ( $self, $n, $i ) = @_;
    return $i->f->_children( $n, $self->node_test, $i );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Test::ChildMatch - handles C</~foo~> where this is not the first step in the path, or C<child::~foo~>

=head1 VERSION

version 0.004

=head1 METHODS

=head2 candidates

Expects node and index. Returns root node if it has the specified tag.

=head1 ROLES

L<TPath::Selector::Test>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
