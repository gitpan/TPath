package TPath::Selector::Test::AnywhereMatch;
{
  $TPath::Selector::Test::AnywhereMatch::VERSION = '0.003';
}

# ABSTRACT: handles C<//~foo~> expression

use Moose;
use TPath::Test::Node::Match;
use namespace::autoclean;


with 'TPath::Selector::Test';

has first => ( is => 'ro', isa => 'Bool', required => 1 );

has rx => ( is => 'ro', isa => 'RegexpRef', required => 1 );

sub BUILD {
    my $self = shift;
    my $nt = TPath::Test::Node::Match->new( rx => $self->rx );
    $self->_node_test($nt);
    my $axis = $self->first ? 'descendant-or-self' : 'descendant';
    $self->_axis($axis);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Test::AnywhereMatch - handles C<//~foo~> expression

=head1 VERSION

version 0.003

=head1 ROLES

L<TPath::Selector::Test>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
