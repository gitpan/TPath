package TPath::Selector::Test::AnywhereAttribute;
{
  $TPath::Selector::Test::AnywhereAttribute::VERSION = '0.018';
}

# ABSTRACT: handles C<//@foo> expression

use Moose;
use TPath::Test::Node::Attribute;
use TPath::TypeConstraints;
use namespace::autoclean;


with 'TPath::Selector::Test';

has a => ( is => 'ro', isa => 'TPath::Attribute', required => 1 );

around BUILDARGS => sub {
    my ( $orig, $class, %args ) = @_;
    $class->$orig(
        %args,
        first_sensitive => 1,
        axis            => 'descendant',
    );
};

sub BUILD {
    my $self = shift;
    my $nt = TPath::Test::Node::Attribute->new( a => $self->a );
    $self->_node_test($nt);
}

sub to_string {
    my $self = shift;
    '//' . ( $self->is_inverted ? '^' : '' ) . $self->a->to_string;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Test::AnywhereAttribute - handles C<//@foo> expression

=head1 VERSION

version 0.018

=head1 ROLES

L<TPath::Selector::Test>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
