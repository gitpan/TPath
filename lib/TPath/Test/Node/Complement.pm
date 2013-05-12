package TPath::Test::Node::Complement;
{
  $TPath::Test::Node::Complement::VERSION = '0.016';
}

# ABSTRACT: L<TPath::Test::Node> implementing matching; e.g., C<//^~foo~>, C<//^foo>, and C<//^@foo>

use Moose;
use namespace::autoclean;


with 'TPath::Test::Node';


has nt => ( is => 'ro', isa => 'TPath::Test::Node', required => 1 );

# required by TPath::Test::Node
sub passes {
    my ( $self, $ctx ) = @_;
    return $self->nt->passes($ctx) ? undef : 1;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Test::Node::Complement - L<TPath::Test::Node> implementing matching; e.g., C<//^~foo~>, C<//^foo>, and C<//^@foo>

=head1 VERSION

version 0.016

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
