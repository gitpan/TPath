package TPath::Test::Boolean;
{
  $TPath::Test::Boolean::VERSION = '0.006';
}

# ABSTRACT: any empty role used to tag boolean TPath::Tests

use Moose::Role;

with 'TPath::Test';

1;

__END__

=pod

=head1 NAME

TPath::Test::Boolean - any empty role used to tag boolean TPath::Tests

=head1 VERSION

version 0.006

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
