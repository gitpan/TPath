package TPath::Selector::Test::Root;
{
  $TPath::Selector::Test::Root::VERSION = '0.012';
}

# ABSTRACT: handles C<:root>

use Moose;
use namespace::autoclean;


with 'TPath::Selector::Test';


sub candidates {
    my ( $self, undef, $i ) = @_;
    return $i->root;
}

sub to_string { ':root' }

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Test::Root - handles C<:root>

=head1 VERSION

version 0.012

=head1 METHODS

=head2 candidates

Expects node and index. Returns root node.

=head1 ROLES

L<TPath::Selector::Test>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
