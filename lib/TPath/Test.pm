package TPath::Test;
{
  $TPath::Test::VERSION = '0.001';
}

# ABSTRACT: interface of conditional expressions in predicates


use Moose::Role;


requires 'test';

1;

__END__

=pod

=head1 NAME

TPath::Test - interface of conditional expressions in predicates

=head1 VERSION

version 0.001

=head1 DESCRIPTION

Interface of objects expressing tests in predicate expressions. E.g., the C<@a or @b> in 
C<//foo[@a or @b]>. Not to be confused with L<TPath::Test::Node>, which is used to implement
the C<foo> portion of this expression.

=head1 REQUIRED METHODS

=head2 test

Takes a node, a collection of nodes, and an index and returns whether the node
passes the predicate.

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
