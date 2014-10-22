package TPath::Selector::Test::ChildTag;
$TPath::Selector::Test::ChildTag::VERSION = '1.006';
# ABSTRACT: handles C</foo> where this is not the first step in the path, or C<child::foo>

use Moose;
use TPath::Test::Node::Tag;
use namespace::autoclean;


with 'TPath::Selector::Test';

has tag => ( is => 'ro', isa => 'Str', required => 1 );

sub BUILD {
    my $self = shift;
    $self->_node_test( TPath::Test::Node::Tag->new( tag => $self->tag ) );
}

sub to_string {
    my ( $self, $first ) = @_;
    my $s = $first ? '' : '/';
    $s .= '^' if $self->is_inverted;
    $s .= $self->_stringify_label( $self->tag, $first );
    return $s;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

TPath::Selector::Test::ChildTag - handles C</foo> where this is not the first step in the path, or C<child::foo>

=head1 VERSION

version 1.006

=head1 ROLES

L<TPath::Selector::Test>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
