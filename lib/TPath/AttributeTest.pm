package TPath::AttributeTest;
{
  $TPath::AttributeTest::VERSION = '0.003';
}

# ABSTRACT: compares an attribute value to another value


use feature qw(switch state);
use Scalar::Util qw(looks_like_number);
use MooseX::SingletonMethod;
use TPath::TypeConstraints;
use namespace::autoclean;


has op => ( is => 'ro', isa => 'Str', required => 1 );


has left => ( is => 'ro', isa => 'ATArg', required => 1 );


has right => ( is => 'ro', isa => 'ATArg', required => 1 );

sub BUILD {
    my $self = shift;
    my ( $l, $r ) = $self->_types;
    my $lr = $l . $r;
    my $func;

    # some coderefs to turn operators into functions
    state $ge_n = sub { $_[0] >= $_[1]           or undef };
    state $ge_s = sub { ( $_[0] cmp $_[1] ) >= 0 or undef };
    state $le_n = sub { $_[0] <= $_[1]           or undef };
    state $le_s = sub { ( $_[0] cmp $_[1] ) <= 0 or undef };
    state $g_n  = sub { $_[0] > $_[1]            or undef };
    state $g_s  = sub { ( $_[0] cmp $_[1] ) > 0  or undef };
    state $l_n  = sub { $_[0] < $_[1]            or undef };
    state $l_s  = sub { ( $_[0] cmp $_[1] ) < 0  or undef };
    state $ne_n = sub { $_[0] != $_[1]           or undef };
    state $ne_s = sub { $_[0] ne $_[1]           or undef };

    # construct the appropriate function
    for ( $self->op ) {
        when ('=')  { $func = $self->_e_func( $l, $r, $lr, \&_se ) }
        when ('==') { $func = $self->_e_func( $l, $r, $lr, \&_de ) }
        when ('<=') { $func = $self->_c_func( $l, $r, $lr, $le_s, $le_n ) }
        when ('<')  { $func = $self->_c_func( $l, $r, $lr, $l_s,  $l_n ) }
        when ('>=') { $func = $self->_c_func( $l, $r, $lr, $ge_s, $ge_n ) }
        when ('>')  { $func = $self->_c_func( $l, $r, $lr, $g_s,  $g_n ) }
        when ('!=') { $func = $self->_c_func( $l, $r, $lr, $ne_s, $ne_n ) }
    }

    # store it
    $self->add_singleton_method( test => $func );
}

# a bunch of private methods that construct custom test methods

# generate = test
sub _e_func {

    # left type, right type, the conjunction, the equality function
    my ( $self, $l, $r, $lr, $ef ) = @_;

    my $lv = $self->left;
    my $rv = $self->right;

    # constant functions
    return 0 + $lv == 0 + $rv ? sub { 1 } : sub { undef }
      if $lr =~ /n[ns]|sn/;
    return "" . $lv eq "" . $rv ? sub { 1 } : sub { undef }
      if $lr eq 'ss';

    # non-silly functions
    for ($l) {
        when ('n') {
            for ($r) {
                when ('a') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $rv->apply( $n, $c, $i );
                        return 0 unless defined $v;
                        if ( my $type = ref $v ) {
                            for ($type) {
                                when ('ARRAY') { return $rv == @$v or undef }
                                default { return }
                            }
                        }
                        $lv == $v or undef;
                    };
                }
                when ('t') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $rv->test( $n, $c, $i );
                        $lv == $v or undef;
                      }
                }
                when ('e') {
                    return sub {
                        my ( undef, $n, undef, $i ) = @_;
                        my @c = $rv->select( $n, $i );
                        $lv == @c or undef;
                      }
                }
                default {
                    confess "fatal logic error! unexpected argument type $r"
                }
            }
        }
        when ('s') {
            for ($r) {
                when ('a') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $rv->apply( $n, $c, $i );
                        return unless defined $v;
                        return $lv eq $v or undef;
                    };
                }
                when ('t') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $rv->test( $n, $c, $i );
                        $lv eq $v or undef;
                      }
                }
                when ('e') {
                    my ( undef, $n, undef, $i ) = @_;
                    my @c = $rv->select( $n, $i );
                    $lv eq join( '', @c ) or undef;
                }
                default {
                    confess "fatal logic error! unexpected argument type $r"
                }
            }
        }
        when ('a') {
            for ($r) {
                when ('n') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $lv->apply( $n, $c, $i );
                        return unless defined $v;
                        if ( my $type = ref $v ) {
                            for ($type) {
                                when ('ARRAY') { return $rv == @$v or undef }
                                default { return }
                            }
                        }
                        $rv == $v or undef;
                    };
                }
                when ('s') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $lv->apply( $n, $c, $i );
                        return unless defined $v;
                        return $rv eq $v or undef;
                    };
                }
                when ('a') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->apply( $n, $c, $i );
                        my $v2 = $rv->apply( $n, $c, $i );
                        return $ef->( $v1, $v2 ) or undef;
                    };
                }
                when ('t') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->apply( $n, $c, $i );
                        my $v2 = $rv->test( $n, $c, $i );
                        return $ef->( $v1, $v2 ) or undef;
                      }
                }
                when ('e') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->apply( $n, $c, $i );
                        my @c = $rv->select( $n, $i );
                        return $ef->( $v1, \@c ) or undef;
                    };
                }
                default {
                    confess "fatal logic error! unexpected argument type $r"
                }
            }
        }
        when ('t') {
            for ($r) {
                when ('n') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->test( $n, $c, $i );
                        return $v1 == $rv or undef;
                    };
                }
                when ('s') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->test( $n, $c, $i );
                        return $v1 eq $rv or undef;
                    };
                }
                when ('a') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->test( $n, $c, $i );
                        my $v2 = $rv->apply( $n, $c, $i );
                        return $ef->( $v1, $v2 ) or undef;
                    };
                }
                when ('t') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->test( $n, $c, $i );
                        my $v2 = $rv->test( $n, $c, $i );
                        return $v1 == $v2 or undef;
                      }
                }
                when ('e') {
                    my ( undef, $n, $c, $i ) = @_;
                    my $v1 = $lv->test( $n, $c, $i );
                    my @c = $lv->select( $n, $i );
                    return $v1 == @c or undef;
                }
                default {
                    confess "fatal logic error! unexpected argument type $r"
                }
            }
        }
        when ('e') {
            for ($r) {
                when ('n') {
                    return sub {
                        my ( undef, $n, undef, $i ) = @_;
                        my @c = $lv->select( $n, $i );
                        return @c == $rv or undef;
                    };
                }
                when ('s') {
                    return sub {
                        my ( undef, $n, undef, $i ) = @_;
                        my @c = $lv->select( $n, $i );
                        return $rv eq join( '', @c ) or undef;
                    };
                }
                when ('a') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my @c = $lv->select( $n, $i );
                        my $v2 = $rv->apply( $n, $c, $i );
                        return $ef->( \@c, $v2 ) or undef;
                    };
                }
                when ('t') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my @c = $lv->select( $n, $i );
                        my $v2 = $rv->test( $n, $c, $i );
                        return @c == $v2 or undef;
                      }
                }
                when ('e') {
                    my ( undef, $n, undef, $i ) = @_;
                    my @c1 = $lv->select( $n, $i );
                    my @c2 = $rv->select( $n, $i );
                    return @c1 == @c2 or undef;
                }
                default {
                    confess "fatal logic error! unexpected argument type $r"
                }
            }
        }
        default { confess "fatal logic error! unexpected argument type $l" }
    }
}

sub _c_func {

# left type, right type, the conjunction, the string comparison function, the number comparison function
    my ( $self, $l, $r, $lr, $sf, $nf ) = @_;

    my $lv = $self->left;
    my $rv = $self->right;

    # constant functions
    return $nf->( $lv, $rv ) ? sub { 1 } : sub { undef }
      if $lr =~ /n[ns]|sn/;
    return $sf->( $lv, $rv ) ? sub { 1 } : sub { undef }
      if $lr eq 'ss';

    # non-silly functions
    for ($l) {
        when ('n') {
            for ($r) {
                when ('a') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $rv->apply( $n, $c, $i );
                        return unless defined $v;
                        if ( my $type = ref $v ) {
                            for ($type) {
                                when ('ARRAY') {
                                    return $nf->( $rv, scalar @$v );
                                }
                                default { return }
                            }
                        }
                        $nf->( $lv, $v );
                    };
                }
                when ('t') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $rv->test( $n, $c, $i );
                        $nf->( $lv, $v );
                      }
                }
                when ('e') {
                    return sub {
                        my ( undef, $n, undef, $i ) = @_;
                        my @c = $rv->select( $n, $i );
                        $nf->( $lv, scalar @c );
                      }
                }
                default {
                    confess "fatal logic error! unexpected argument type $r"
                }
            }
        }
        when ('s') {
            for ($r) {
                when ('a') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $rv->apply( $n, $c, $i );
                        return unless defined $v;
                        return $sf->( $lv, $v );
                    };
                }
                when ('t') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $rv->test( $n, $c, $i );
                        $sf->( $lv, $v );
                      }
                }
                when ('e') {
                    my ( undef, $n, undef, $i ) = @_;
                    my @c = $rv->select( $n, $i );
                    $sf->( $lv, join '', @c );
                }
                default {
                    confess "fatal logic error! unexpected argument type $r"
                }
            }
        }
        when ('a') {
            for ($r) {
                when ('n') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $lv->apply( $n, $c, $i );
                        return unless defined $v;
                        if ( my $type = ref $v ) {
                            for ($type) {
                                when ('ARRAY') {
                                    return $nf->( scalar @$v, $rv );
                                }
                                default { return }
                            }
                        }
                        $nf->( $v, $rv );
                    };
                }
                when ('s') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v = $lv->apply( $n, $c, $i );
                        return unless defined $v;
                        return $sf->( $v, $rv );
                    };
                }
                when ('a') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->apply( $n, $c, $i );
                        my $v2 = $rv->apply( $n, $c, $i );
                        return _reduce( $v1, $v2, $sf, $nf, $n, $c, $i );
                    };
                }
                when ('t') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->apply( $n, $c, $i );
                        my $v2 = $rv->test( $n, $c, $i );
                        return _reduce( $v1, $v2, $sf, $nf, $n, $c, $i );
                      }
                }
                when ('e') {
                    my ( undef, $n, $c, $i ) = @_;
                    my $v1 = $lv->apply( $n, $c, $i );
                    my @c = $rv->select( $n, $i );
                    return _reduce( $v1, \@c, $sf, $nf, $n, $c, $i );
                }
                default {
                    confess "fatal logic error! unexpected argument type $r"
                }
            }
        }
        when ('t') {
            for ($r) {
                when ('n') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->test( $n, $c, $i );
                        return $nf->( $v1, $rv );
                    };
                }
                when ('s') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->test( $n, $c, $i );
                        return $sf->( $v1, $rv );
                    };
                }
                when ('a') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->test( $n, $c, $i );
                        my $v2 = $rv->apply( $n, $c, $i );
                        return _reduce( $v1, $v2, $sf, $nf, $n, $c, $i );
                    };
                }
                when ('t') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->test( $n, $c, $i );
                        my $v2 = $rv->test( $n, $c, $i );
                        return $nf->( $v1, $v2 );
                      }
                }
                when ('e') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my $v1 = $lv->test( $n, $c, $i );
                        my @c = $rv->select( $n, $i );
                        return $nf->( $v1, scalar @c );
                    };
                }
                default {
                    confess "fatal logic error! unexpected argument type $r"
                }
            }
        }
        when ('e') {
            for ($r) {
                when ('n') {
                    return sub {
                        my ( undef, $n, undef, $i ) = @_;
                        my @c = $lv->select( $n, $i );
                        return $nf->( scalar @c, $rv );
                    };
                }
                when ('s') {
                    return sub {
                        my ( undef, $n, undef, $i ) = @_;
                        my @c = $lv->select( $n, $i );
                        return $sf->( join( '', @c ), $rv );
                    };
                }
                when ('a') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my @c = $lv->select( $n, $i );
                        my $v2 = $rv->apply( $n, $c, $i );
                        return _reduce( \@c, $v2, $sf, $nf, $n, $c, $i );
                    };
                }
                when ('t') {
                    return sub {
                        my ( undef, $n, $c, $i ) = @_;
                        my @c = $lv->select( $n, $i );
                        my $v2 = $rv->test( $n, $c, $i );
                        return $nf->( scalar @c, $v2 );
                      }
                }
                when ('e') {
                    return sub {
                        my ( undef, $n, undef, $i ) = @_;
                        my @c1 = $lv->select( $n, $i );
                        my @c2 = $rv->select( $n, $i );
                        return $nf->( scalar @c1, scalar @c2 );
                    };
                }
                default {
                    confess "fatal logic error! unexpected argument type $r"
                }
            }
        }
        default { confess "fatal logic error! unexpected argument type $l" }
    }
}

sub _reduce {
    my ( $v1, $v2, $sf, $nf, $n, $c, $i ) = @_;
    my ( $l, $r ) = map { _type($_) } $v1, $v2;
    for ("$l$r") {
        when ('nn') { return $nf->( $v1, $v2 ) }
        when (/[sn]{2}/) { return $sf->( $v1, $v2 ) }
        when ('nh') { return $nf->( $v1,              scalar keys %$v2 ) }
        when ('hn') { return $nf->( scalar keys %$v1, $v2 ) }
        when ('nr') { return $nf->( $v1,              scalar @$v2 ) }
        when ('rn') { return $nf->( scalar @$v1,      $v2 ) }
        when ('sr') { return $sf->( $v1, join '', @$v2 ) }
        when ('rs') { return $sf->( join( '', @$v1 ), $v2 ) }
        when (/[eta].|.[eta]/) {
            my ( $v3, $v4 ) = ( $v1, $v2 );
            for ($l) {
                when ('e') { $v3 = [ $v1->select( $n, $i ) ] }
                when ('t') { $v3 = $v1->test( $n, $c, $i ) }
                when ('a') { $v3 = $v1->apply( $n, $c, $i ) }
            }
            for ($r) {
                when ('e') { $v4 = [ $v2->select( $n, $i ) ] }
                when ('t') { $v4 = $v2->test( $n, $c, $i ) }
                when ('a') { $v4 = $v2->apply( $n, $c, $i ) }
            }
            return _reduce( $v3, $v4, $sf, $nf, $n, $c, $i );
        }
        default { return $sf->( $v1, $v2 ) }
    }
}

# single equals
sub _se {
    my ( $v1, $v2 ) = @_;

    if ( !( defined $v1 && defined $v2 ) ) {
        return !( $v1 ^ $v2 );
    }
    my ( $l, $r ) = map { _type($_) } $v1, $v2;
    my $lr = "$l$r";
    for ($lr) {
        when ('ss') { return $v1 eq $v2 }
        when ('nn') { return $v1 == $v2 }
        when ('nr') { return $v1 == @$v2 }
        when ('rn') { return @$v1 == $v2 }
        when ('rr') { return @$v1 == @$v2 }
        when ('oo') {
            my $f = $v1->can('equals');
            return $f->( $v1, $v2 ) if $f;
            $f = $v2->can('equals');
            return $f->( $v2, $v1 ) if $f;
            return refaddr $v1 eq refaddr $v2;
        }
        when (/o./) {
            my $f = $v1->can('equals');
            return $f->( $v1, $v2 ) if $f;
            return $v1 eq $v2;
        }
        when (/.o/) {
            my $f = $v2->can('equals');
            return $f->( $v2, $v1 ) if $f;
            return $v1 eq $v2;
        }
        default { return $v1 eq $v2 }
    }
}

# double equals
sub _de {
    my ( $v1, $v2 ) = @_;

    if ( !( defined $v1 && defined $v2 ) ) {
        return !( defined $v1 || defined $v2 );
    }
    my ( $l, $r ) = map { _type($_) } $v1, $v2;
    my $lr = "$l$r";
    for ($lr) {
        when ('ss') { return $v1 eq $v2 }
        when ('nn') { return $v1 == $v2 }
        when ('hn') { return keys %$v1 == $v2 }
        when ('nh') { return $v1 == keys %$v2 }
        when ('hh') {
            my @keys = keys %$v1;
            return 0 unless @keys == keys %$v2;
            for my $k (@keys) {
                return 0 unless exists $v2->{$k};
                my $o1 = $v1->{$k};
                my $o2 = $v2->{$k};
                return 0 unless _de( $o1, $o2 );
            }
            return 1;
        }
        when ('na') { return $v1 == @$v2 }
        when ('an') { return @$v1 == $v2 }
        when ('aa') {
            return 0 unless @$v1 == @$v2;
            for my $i ( 0 .. $#$v1 ) {
                my $o1 = $v1->[$i];
                my $o2 = $v2->[$i];
                return 0 unless _de( $o1, $o2 );
            }
            return 1;
        }
        when ('oo') {
            my $f = $v1->can('equals');
            return $f->( $v1, $v2 ) if $f;
            $f = $v2->can('equals');
            return $f->( $v2, $v1 ) if $f;
            return refaddr $v1 eq refaddr $v2;
        }
        when (/o./) {
            my $f = $v1->can('equals');
            return $f->( $v1, $v2 ) if $f;
            return $v1 eq $v2;
        }
        when (/.o/) {
            my $f = $v2->can('equals');
            return $f->( $v2, $v1 ) if $f;
            return $v1 eq $v2;
        }
        default { return $v1 eq $v2 }
    }
}

sub _types {
    my $self = shift;
    _type( $self->left ), _type( $self->right );
}

# tests type of argument
sub _type {
    my $arg = shift;
    if ( my $type = ref $arg ) {
        return 'h' if $type eq 'HASH';
        return 'r' if $type eq 'ARRAY';
        return 'a' if $arg->isa('TPath::Attribute');
        return 'e' if $arg->isa('TPath::Expression');
        return 't' if $arg->isa('TPath::AttributeTest');
        return 'o';
    }
    return 'n' if looks_like_number $arg;
    return 's';
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

TPath::AttributeTest - compares an attribute value to another value

=head1 VERSION

version 0.003

=head1 DESCRIPTION

Implements predicates such as C<//foo[@a < @b]> or C<ancestor::*[@bar = 1]>. That is, predicates
where an attribute is tested against some value.

This class if for internal consumption only.

=head1 ATTRIBUTES

=head2 op

The comparison operator between the two values.

=head2 left

The left value.

=head2 right

The right value.

=head1 METHODS

=head2 test

The test function applied to the values. This method is constructed in C<BUILD> and
assigned to the attribute test as a singleton method.

Expects a node, a collection, and an index.

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
