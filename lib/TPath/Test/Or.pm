package TPath::Test::Or;
{
  $TPath::Test::Or::VERSION = '0.008';
}

# ABSTRACT: implements logical disjunction of tests


use Moose;


with 'TPath::Test::Compound';

# required by TPath::Test
sub test {
    my ( $self, $n, $i, $c ) = @_;
    for my $t ( @{ $self->tests } ) {
        return 1 if $t->test( $n, $i, $c );
    }
    return 0;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Test::Or - implements logical disjunction of tests

=head1 VERSION

version 0.008

=head1 DESCRIPTION

For use by compiled TPath expressions. Not for external consumption.

=head1 ROLES

L<TPath::Test::Compound>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
