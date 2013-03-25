package TPath::Selector::Id;
{
  $TPath::Selector::Id::VERSION = '0.009';
}

# ABSTRACT: C<TPath::Selector> that implements C<id(foo)>

use Moose;
use namespace::autoclean;


with 'TPath::Selector';

has id => ( isa => 'Str', is => 'ro', required => 1 );

# required by TPath::Selector
sub select {
    my ( $self, undef, $idx ) = @_;
    my $n = $idx->indexed->{ $self->id };
    $n // ();
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Id - C<TPath::Selector> that implements C<id(foo)>

=head1 VERSION

version 0.009

=head1 ROLES

L<TPath::Selector>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
