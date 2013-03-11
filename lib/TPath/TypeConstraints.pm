package TPath::TypeConstraints;
{
  $TPath::TypeConstraints::VERSION = '0.005';
}

# ABSTRACT: assorted type constraints

use Moose::Util::TypeConstraints;
use TPath::Grammar qw(%AXES);

class_type $_ for qw(TPath::Attribute TPath::Expression TPath::AttributeTest);

role_type $_ for qw(TPath::Test::Boolean TPath::Selector TPath::Forester TPath::Predicate);

union 'ATArg', [qw( Num TPath::Attribute Str )];

union 'CondArg', [qw(TPath::Attribute TPath::Expression TPath::AttributeTest TPath::Test::Boolean)];

enum 'Axis' => keys %AXES;

__END__

=pod

=head1 NAME

TPath::TypeConstraints - assorted type constraints

=head1 VERSION

version 0.005

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
