package TPath::Predicate;
{
  $TPath::Predicate::VERSION = '0.001';
}

# ABSTRACT: interface of square bracket sub-expressions in TPath expressions

use Moose::Role;


requires 'filter';

1;

__END__

=pod

=head1 NAME

TPath::Predicate - interface of square bracket sub-expressions in TPath expressions

=head1 VERSION

version 0.001

=head1 METHODS

=head2 filter

Takes a collection of nodes and an index and returns the collection of nodes
for which the predicate is true.

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
