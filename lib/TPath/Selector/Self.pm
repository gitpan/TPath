package TPath::Selector::Self;
{
  $TPath::Selector::Self::VERSION = '0.011';
}

# ABSTRACT: L<TPath::Selector> that implements C<.>

use Moose;
use namespace::autoclean;


with 'TPath::Selector';

# required by TPath::Selector
sub select {
	my ( undef, $n ) = @_;
	$n;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Selector::Self - L<TPath::Selector> that implements C<.>

=head1 VERSION

version 0.011

=head1 ROLES

L<TPath::Selector>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
