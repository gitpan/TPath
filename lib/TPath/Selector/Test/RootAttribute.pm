package TPath::Selector::Test::RootAttribute;
{
  $TPath::Selector::Test::RootAttribute::VERSION = '0.007';
}

# ABSTRACT: handles C</@foo>

use Moose;
use TPath::Test::Node::Attribute;
use TPath::TypeConstraints;
use namespace::autoclean;


with 'TPath::Selector::Test';

has a => ( is => 'ro', isa => 'TPath::Attribute', required => 1 );

sub BUILD {
    my $self = shift;
    $self->_node_test( TPath::Test::Node::Attribute->new( a => $self->a ) );
}

# required by TPath::Selector::Test
sub candidates {
    my ( $self, undef, $i ) = @_;
    my $r = $i->root;
    return $self->node_test->passes( $r, $i ) ? $r : ();
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Test::RootAttribute - handles C</@foo>

=head1 VERSION

version 0.007

=head1 ROLES

L<TPath::Selector::Test>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
