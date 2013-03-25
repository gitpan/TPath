package TPath::Test::Node::Match;
{
  $TPath::Test::Node::Match::VERSION = '0.009';
}

# ABSTRACT: L<TPath::Test::Node> implementing matching; e.g., C<//~foo~>

use Moose;
use namespace::autoclean;


with 'TPath::Test::Node';


has rx => ( is => 'ro', isa => 'RegexpRef', required => 1 );

# required by TPath::Test::Node
sub passes {
    my ( $self, $n, $i ) = @_;
    return $i->f->matches_tag( $n, $self->rx );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Test::Node::Match - L<TPath::Test::Node> implementing matching; e.g., C<//~foo~>

=head1 VERSION

version 0.009

=head1 ATTRIBUTES

=head2 rx

Pattern to match.

=head1 ROLES

L<TPath::Test::Node>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
