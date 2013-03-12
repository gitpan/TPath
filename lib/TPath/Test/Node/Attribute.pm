package TPath::Test::Node::Attribute;
{
  $TPath::Test::Node::Attribute::VERSION = '0.006';
}

# ABSTRACT: L<TPath::Test::Node> implementing matching; e.g., C<//~foo~>

use Moose;
use namespace::autoclean;


with 'TPath::Test::Node';


has a => ( is => 'ro', isa => 'TPath::Attribute', required => 1 );

# required by TPath::Test::Node
sub passes {
    my ( $self, $n, $i ) = @_;
    return $self->a->test( $n, $i, [] ) ? 1 : undef;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Test::Node::Attribute - L<TPath::Test::Node> implementing matching; e.g., C<//~foo~>

=head1 VERSION

version 0.006

=head1 ATTRIBUTES

=head2 a

Attribute to detect.

=head1 ROLES

L<TPath::Test::Node>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
