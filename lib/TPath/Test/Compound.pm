package TPath::Test::Compound;
{
  $TPath::Test::Compound::VERSION = '0.007';
}

# ABSTRACT: role of TPath::Tests that combine multiple other tests under some boolean operator

use Moose::Role;
use TPath::TypeConstraints;


with 'TPath::Test::Boolean';


has tests => ( is => 'ro', isa => 'ArrayRef[CondArg]', required => 1 );

1;

__END__

=pod

=head1 NAME

TPath::Test::Compound - role of TPath::Tests that combine multiple other tests under some boolean operator

=head1 VERSION

version 0.007

=head1 ATTRIBUTES

=head2 tests

Subsidiary L<TPath::Test> objects combined by this test.

=head1 ROLES

L<TPath::Test::Boolean>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
