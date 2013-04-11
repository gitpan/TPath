package TPath::Predicate::Attribute;
{
  $TPath::Predicate::Attribute::VERSION = '0.012';
}

# ABSTRACT: implements the C<[@foo]> in C<//a/b[@foo]>


use Moose;
use TPath::TypeConstraints;


with 'TPath::Predicate';


has a => ( is => 'ro', isa => 'TPath::Attribute', required => 1 );

sub filter {
    my ( $self, $i, $c ) = @_;
    return grep { $self->a->test( $_, $i, $c ) } @$c;
}

sub to_string {
    $_[0]->a->to_string;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Predicate::Attribute - implements the C<[@foo]> in C<//a/b[@foo]>

=head1 VERSION

version 0.012

=head1 DESCRIPTION

The object that selects the correct member of collection based whether they have a particular attribute.

=head1 ATTRIBUTES

=head2 a

The attribute evaluated.

=head1 ROLES

L<TPath::Predicate>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
