package TPath::Predicate::Index;
{
  $TPath::Predicate::Index::VERSION = '0.006';
}

# ABSTRACT: implements the C<[0]> in C<//a/b[0]>


use Moose;


with 'TPath::Predicate';


has idx => ( is => 'ro', isa => 'Int', required => 1 );

sub filter {
    my ( $self, undef, $c ) = @_;
    return $c->[ $self->idx ];
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Predicate::Index - implements the C<[0]> in C<//a/b[0]>

=head1 VERSION

version 0.006

=head1 DESCRIPTION

The object that selects the correct member of collection based on its index.

=head1 ATTRIBUTES

=head2 idx

The index of the item selected.

=head1 ROLES

L<TPath::Predicate>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
