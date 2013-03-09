package TPath::Expression;
{
  $TPath::Expression::VERSION = '0.003';
}

# ABSTRACT: a compiled TPath expression


use TPath::TypeCheck;
use TPath::TypeConstraints;
use Scalar::Util qw(refaddr);
use Moose;
use namespace::autoclean -also => qr/^_/;


with 'TPath::Test';


has f => ( is => 'ro', does => 'TPath::Forester', required => 1 );

has _selectors =>
  ( is => 'ro', isa => 'ArrayRef[ArrayRef[TPath::Selector]]', required => 1 );


sub select {
    my ( $self, $n, $i ) = @_;
    confess 'select called on a null node' unless defined $n;
    $self->f->_typecheck($n);
    $i //= $self->f->index($n);
    $i->index;
    my @sel;
    for my $fork ( @{ $self->_selectors } ) {
        push @sel, _sel( $n, $i, $fork, 0 );
    }
    if ( @{ $self->_selectors } > 1 ) {
        my %uniques;
        @sel = map {
            my $ra = refaddr $_;
            if   ( $uniques{$ra} ) { () }
            else                   { $uniques{$ra} = 1; $_ }
        } @sel;
    }
    return wantarray ? @sel : $sel[0];
}

# required by TPath::Test
sub test {
    my ( $self, $n, undef, $i ) = @_;
    !!$self->select( $n, $i );
}

sub _sel {
    my ( $n, $i, $fork, $idx ) = @_;
    my @c = $fork->[ $idx++ ]->select( $n, $i );
    return @c if $idx == @$fork;
    my @sel;
    push @sel, _sel( $_, $i, $fork, $idx ) for @c;
    return @sel;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::Expression - a compiled TPath expression

=head1 VERSION

version 0.003

=head1 SYNOPSIS

  my $f     = MyForester->new;             # make a new forester for my sort of tree
  my $path  = $f->path('//foo[@bar][-1]'); # select the last foo with the bar property
  my $tree  = next_tree();                 # get the next tree (hypothetical function)
  my ($foo) = $path->select($tree);        # get the desired node
  $foo      = $path->first($tree);         # achieves the same result

=head1 DESCRIPTION

An object that will get us the nodes identified by our path expression.

=head1 ATTRIBUTES

=head2 f

The expression's L<TPath::Forester>.

=head1 METHODS

=head2 select

Takes a tree and, optionally, an index and returns the nodes selected from this
tree by the path if you want a list or the first node selected if you want a
scalar. 

If you are doing many selections on a particular tree, you may save some work by 
using a common index for all selections.

=head1 ROLES

L<TPath::Test>

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
