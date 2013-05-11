package TPath::Attribute;
{
  $TPath::Attribute::VERSION = '0.015';
}

# ABSTRACT: handles evaluating an attribute for a particular node


use v5.10;
use Moose;
use namespace::autoclean;


with qw(TPath::Test TPath::Numifiable);


has name => ( is => 'ro', isa => 'Str', required => 1 );


has args => ( is => 'ro', isa => 'ArrayRef', required => 1 );


has code => ( is => 'ro', isa => 'CodeRef', required => 1 );


sub apply {
    my ( $self, $ctx ) = @_;
    my @args = ($ctx);

    # invoke all code to reify arguments
    for my $a ( @{ $self->args } ) {
        my $value = $a;
        my $type  = ref $a;
        if ( $type && $type !~ /ARRAY|HASH/ ) {
            if ( $a->isa('TPath::Attribute') ) {
                $value = $a->apply($ctx);
            }
            elsif ( $a->isa('TPath::AttributeTest') ) {
                $value = $a->test($ctx);
            }
            elsif ( $a->isa('TPath::Expression') ) {
                $value =
                  [ map { $_->n } @{ $a->_select( $ctx, 0 ) } ];
            }
            elsif ( $a->does('TPath::Test') ) {
                $value = $a->test($ctx);
            }
            else { confess 'unknown argument type: ' . ( ref $a ) }
        }
        push @args, $value;
    }
    $self->code->( $ctx->i->f, @args );
}


sub to_num {
    my ( $self, $ctx ) = @_;
    my $val = $self->apply($ctx);
    for ( ref $val ) {
        when ('ARRAY') { return scalar @$val }
        when ('HASH')  { return scalar keys %$val }
        default        { return 0 + $val }
    }
}

# required by TPath::Test
sub test {
    my ( $self, $ctx ) = @_;
    defined $self->apply($ctx);
}

sub to_string {
    my $self = shift;
    my $s    = '@' . $self->_stringify_label( $self->name );
    my @args = @{ $self->args };
    if (@args) {
        $s .= '(' . $self->_stringify( $args[0] );
        for my $arg ( @args[ 1 .. $#args ] ) {
            $s .= ', ' . $self->_stringify($arg);
        }
        $s .= ')';
    }
    return $s;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Attribute - handles evaluating an attribute for a particular node

=head1 VERSION

version 0.015

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

=head2 to_num

Basically an alias for C<apply>. Required by L<TPath::Numifiable>.

=head1 ROLES

L<TPath::Test>, L<TPath::Stringifiable>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
