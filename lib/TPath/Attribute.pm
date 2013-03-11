package TPath::Attribute;
{
  $TPath::Attribute::VERSION = '0.004';
}

# ABSTRACT: handles evaluating an attribute for a particular node


use feature qw(switch);
use Moose;
use namespace::autoclean;


with 'TPath::Test';


has name => ( is => 'ro', isa => 'Str', required => 1 );


has args => ( is => 'ro', isa => 'ArrayRef', required => 1 );


has code => ( is => 'ro', isa => 'CodeRef', required => 1 );


sub apply {
    my ( $self, $n, $i, $c ) = @_;
    my @args = ( $n, $i, $c );

    # invoke all code to reify arguments
    for my $a ( @{ $self->args } ) {
        my $value = $a;
        my $type  = ref $a;
        if ( $type && $type !~ /ARRAY|HASH/ ) {
            if ( $a->isa('TPath::Attribute') ) {
                $value = $a->apply( $n, $i, $c );
            }
            elsif ( $a->isa('TPath::AttributeTest') ) {
                $value = $a->test( $n, $i, $c );
            }
            elsif ( $a->isa('TPath::Expression') ) {
                $value = [ $a->select( $n, $i ) ];
            }
            elsif ( $a->does('TPath::Test') ) {
                $value = $a->test( $n, $i, $c );
            }
            else { confess 'unknown argument type: ' . ( ref $a ) }
        }
        push @args, $value;
    }
    $self->code->( $i->f, @args );
}

# required by TPath::Test
sub test {
    my ( $self, $n, $i, $c ) = @_;
    defined $self->apply( $n, $i, $c );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Attribute - handles evaluating an attribute for a particular node

=head1 VERSION

version 0.004

=head1 DESCRIPTION

For use in compiled TPath expressions. Not for external consumption.

=head1 ATTRIBUTES

=head2 name

The name of the attribute. E.g., in C<@foo>, C<foo>.

=head2 args

The arguments the attribute takes, if any.

=head2 code

The actual code reference invoked when C<apply> is called.

=head1 METHODS

=head2 apply

Expects a node, and index, and a collection. Returns some value.

=head1 ROLES

L<TPath::Test>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
