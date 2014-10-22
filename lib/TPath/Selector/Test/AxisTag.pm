package TPath::Selector::Test::AxisTag;
{
  $TPath::Selector::Test::AxisTag::VERSION = '0.003';
}

# ABSTRACT: handles C</ancestor::foo> or C</preceding::foo> where this is not the first step in the path, or C<ancestor::foo>

use Moose;
use TPath::Test::Node::Tag;
use namespace::autoclean;


with 'TPath::Selector::Test';

has tag => ( is => 'ro', isa => 'Str', required => 1 );

sub BUILD {
    my $self = shift;
    $self->_node_test( TPath::Test::Node::Tag->new( tag => $self->tag ) );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Test::AxisTag - handles C</ancestor::foo> or C</preceding::foo> where this is not the first step in the path, or C<ancestor::foo>

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
