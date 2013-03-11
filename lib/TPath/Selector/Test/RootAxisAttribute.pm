package TPath::Selector::Test::RootAxisAttribute;
{
  $TPath::Selector::Test::RootAxisAttribute::VERSION = '0.005';
}

# ABSTRACT: handles C</ancestor::@foo> or C</preceding::@foo> where this is the first step in the path

use feature 'state';
use Moose;
use namespace::autoclean;

extends 'TPath::Selector::Test::AxisAttribute';

sub candidates {
    my ( $self, undef, $i, $c ) = @_;
    $self->SUPER::candidates( $i->root, $i, $c );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Test::RootAxisAttribute - handles C</ancestor::@foo> or C</preceding::@foo> where this is the first step in the path

=head1 VERSION

version 0.005

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
