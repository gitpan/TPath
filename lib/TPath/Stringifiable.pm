package TPath::Stringifiable;
{
  $TPath::Stringifiable::VERSION = '0.018';
}

# ABSTRACT: role requiring that a class have a to_string method


use Moose::Role;
use Scalar::Util qw(looks_like_number);


requires 'to_string';

# method available to to_string that adds escape characters as needed
# params: string -- string to escape
#         chars  -- characters to escape -- \ always added
sub _escape {
    my ( $self, $string, @chars ) = @_;
    my $s = '';
    my %chars = map { $_ => 1 } @chars, '\\';
    for my $c ( split //, $string ) {
        $s .= '\\' if $chars{$c};
        $s .= $c;
    }
    return $s;
}

# general stringification procedure
sub _stringify {
    my ( $self, $arg, @args ) = @_;
    return $arg->to_string(@args)
      if blessed $arg && $arg->can('to_string');
    confess 'unexpected argument type: ' . ref $arg if ref $arg;
    return $arg if looks_like_number $arg;
    return "'" . $self->_escape( $arg, "'" ) . "'";
}

# converts some label -- tag name or attribute name -- into a parsable string
sub _stringify_label {
    my ( $self, $string, $first ) = @_;
    return $string
      if $string =~
      /^(?>\\.|[\p{L}\$_])(?>[\p{L}\$\p{N}_]|[-.:](?=[\p{L}_\$\p{N}])|\\.)*+$/;
    return ( $first ? ':' : '' ) . '"' . $self->_escape($string) . '"'
      unless ( index $string, '"' ) > -1;
    return ( $first ? ':' : '' ) . "'" . $self->_escape($string) . "'"
      unless ( index $string, "'" ) > -1;

    # safety fallback
    return $self->_escape( $string, grep { !/[\p{L}]\$_/ } split //, $string );
}

1;

__END__

=pod

=head1 NAME

TPath::Stringifiable - role requiring that a class have a to_string method

=head1 VERSION

version 0.018

=head1 DESCRIPTION

Role that enforces the presence of a to_string method. Makes sure the absence of this method
where it is expected will be a compile time rather than run time error.

=head1 REQUIRED METHODS

=head2 to_string

Produces a sensible, human-readable stringification of the object. Some implementations of the method
may expect parameters.

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
