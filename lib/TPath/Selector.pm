package TPath::Selector;
{
  $TPath::Selector::VERSION = '0.005';
}

# ABSTRACT: an interface for classes that select nodes from a candidate collection

use Moose::Role;


requires 'select';

1;

__END__

=pod

=head1 NAME

TPath::Selector - an interface for classes that select nodes from a candidate collection

=head1 VERSION

version 0.005

=head1 REQUIRED METHODS

=head2 select

Takes a node an an index and returns a collection of nodes.

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
