package TPath::Test::XOr;
{
  $TPath::Test::XOr::VERSION = '0.005';
}

# ABSTRACT: implements logical function of tests which returns true iff only one test is true


use Moose;

with 'TPath::Test::Compound';

# required by TPath::Test
sub test {
    my ( $self, $n, $i, $c ) = @_;
    my $count = 0;
    for my $t ( @{ $self->tests } ) {
        if ( $t->test( $n, $i, $c ) ) {
            return 0 if $count;
            $count++;
        }
    }
    return $count;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Test::XOr - implements logical function of tests which returns true iff only one test is true

=head1 VERSION

version 0.005

=head1 DESCRIPTION

For use by compiled TPath expressions. Not for external consumption.

NOTE: though this is called C<TPath::Test::XOr> and corresponds to the C<^> operator,
it is really best understood as a one-of or uniqueness test. If it governs two operands,
it is logically equivalent to exclusive or. If it governs more than one, it is B<not> necessarily
equivalent to evaluating a sequence of pairwise exclusive or constructs. I have written things
this way because I figure this is more useful in general and the true exclusive or logic can
be recreated easily enough by adding parentheses to group operands.

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
