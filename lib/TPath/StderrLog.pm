package TPath::StderrLog;
{
  $TPath::StderrLog::VERSION = '1.001';
}

# ABSTRACT: implementation of TPath::LogStream that simply prints to STDERR


use Moose;
use namespace::autoclean;

with 'TPath::LogStream';

sub put {
    my ( $self, $message ) = @_;
    print STDERR $message // '', "\n";
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::StderrLog - implementation of TPath::LogStream that simply prints to STDERR

=head1 VERSION

version 1.001

=head1 DESCRIPTION

Default L<TPath::LogStream>.

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
