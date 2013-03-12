package TPath::Selector::Test::ClosestTag;
{
  $TPath::Selector::Test::ClosestTag::VERSION = '0.006';
}

# ABSTRACT: handles C</E<gt>foo>

use Moose;
use TPath::Test::Node::Tag;
use namespace::autoclean;


with 'TPath::Selector::Test';

has tag => ( is => 'ro', isa => 'Str', required => 1 );

sub BUILD {
    my $self = shift;
    $self->_node_test( TPath::Test::Node::Tag->new( tag => $self->tag ) );
}

# required by TPath::Selector::Test
sub candidates {
    my ( $self, $n, $i ) = @_;
    return $i->f->closest( $n, $self->node_test, $i );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Test::ClosestTag - handles C</E<gt>foo>

=head1 VERSION

version 0.006

=head1 ROLES

L<TPath::Selector::Test>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
