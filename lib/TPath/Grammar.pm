# ABSTRACT: parses TPath expressions into ASTs

package TPath::Grammar;
{
  $TPath::Grammar::VERSION = '0.005';
}

use v5.10;
use strict;
use warnings;
use Carp;

use parent qw(Exporter);

our @EXPORT_OK = qw(parse %AXES);


our %AXES = map { $_ => 1 } qw(
  ancestor
  ancestor-or-self
  child
  descendant
  descendant-or-self
  following
  following-sibling
  leaf
  parent
  preceding
  preceding-sibling
  self
  sibling
  sibling-or-self
);

our $path_grammar = do {
    use Regexp::Grammars;
    qr{
       <nocontext:>
       <timeout: 100>
    
    
    ^ <treepath> $
    
    
       <rule: treepath> <[path]> (?: \| <[path]> )*
    
       <token: path> (?!@) <[segment=first_step]> <[segment=subsequent_step]>* | <error:>
    
       <token: first_step> <separator>? <step> | <error: Expected path step>
    
       <token: id>
          id\( ( (?>[^\)\\]|\\.)++ ) \)
          (?{ $MATCH=clean_escapes($^N) })
          | <error: Expected id expression>
    
       <token: subsequent_step> <separator> <step> | <error: Expected path step>
    
       <token: separator> \/[\/>]?+ | <error:>
    
       <token: step> <full> <[predicate]>* | <abbreviated> | <error:>
    
       <token: full> <axis>? <forward>
    
       <token: axis> (?<!//) (?<!/>) (<%AXES>) ::
          (?{ $MATCH = $^N })
          | <error:>
    
       <token: abbreviated> (?<!/[/>]) (?: \.{1,2}+ | <id> )
    
       <token: forward> <wildcard> | <specific> | <pattern> | <attribute>
           | <error: Expecting tag selector>
    
       <token: wildcard> \* | <error:>
    
       <token: specific>
          ( <.name> )
          (?{ $MATCH = clean_escapes($^N) })
          | <error: Expected specific tag name>
    
       <token: pattern>
          (~(?>[^~]|~~)++~)
          (?{ $MATCH = clean_pattern($^N) })
          | <error:>
    
       <token: aname>
          @ ( <.name> )
          (?{ $MATCH = clean_escapes($^N ) })
          | <error: expected attribute name>
       
       <token: name>
          (?>\\.|[\p{L}\$_])(?>[\p{L}\$\p{N}_]|[-.:](?=[\p{L}_\$\p{N}])|\\.)*+
    
       <rule: attribute> <aname> <args>? | <error:>
    
       <rule: args> \( <[arg]> (?: , <[arg]> )* \) | <error: Expected attribute arguments>
    
       <token: arg>
          <treepath> | <v=literal> | <v=num> | <attribute> | <attribute_test> | <condition>
          | <error: Expected attribute argument>
    
       <token: num> <.signed_int> | <.float> | <error:>
    
       <token: signed_int> [+-]?+ <.int>   
    
       <token: float> [+-]?+ <.int>? \.\d++ (?: [Ee][+-]?+ <.int> )?+
    
       <token: literal>
          ((?> <.squote> | <.dquote> ))
          (?{ $MATCH = clean_literal($^N) })
          | <error:>
    
       <token: squote> ' (?>[^'\\]|\\.)*+ '
    
       <token: dquote> " (?>[^"\\]|\\.)*+ "   
    
       <rule: predicate>
          \[ (*COMMIT) (?: <idx=signed_int> | <condition> ) \]
          | <error:>
    
       <token: int> \b(?:0|[1-9][0-9]*+)\b
    
       <rule: condition> 
          <[item=not]>? <[item]> (?: <[item=operator]> <[item=not]>? <[item]> )*
          | <error: Expecting sequence of boolean operators and operands>

       <token: not>
          ( 
             (?: ! | (?<=[\s\[(]) not (?=\s) ) 
             (?: \s*+ (?: ! | (?<=\s) not (?=\s) ) )*+ 
          )
          (?{$MATCH = clean_not($^N)})
          | <error:>
       
       <token: operator>
          (?: <.or> | <.xor> | <.and> )
          (?{$MATCH = clean_operator($^N)})
          | <error: Expecting binary boolean operator>
       
       <token: xor>
          ( \^ | (?<=\s) xor (?=\s) )
           
       <token: and>
          ( & | (?<=\s) and (?=\s) )
           
       <token: or>
          ( \|{2} | (?<=\s) or (?=\s) )
    
       <token: term> 
          <attribute> | <attribute_test> | <treepath>
    
       <rule: attribute_test>
          <[args=attribute]> <cmp> <[args=value]> | <[args=value]> <cmp> <[args=attribute]>
          | <error:>
    
       <token: cmp> [<>=]=?+|!= | <error: Expecting comparison operator>
    
       <token: value> <v=literal> | <v=num> | <attribute>
    
       <rule: group> \( <condition> \) | <error:>
    
       <token: item>
          <term> | <group> | <error: Expected operand in a boolean expression>
    }x;
};


sub parse {
    my ($expr) = @_;
    if ( $expr =~ $path_grammar ) {
        my $ref = \%/;
        if ( contains_condition($ref) ) {
            normalize_parens($ref);
            operator_precedence($ref);
            merge_conditions($ref);
            fix_predicates($ref);
        }
        return optimize($ref);
    }
    else {
        confess "could not parse '$expr' as a TPath expression:\n" . join "\n",
          @!;
    }
}

# remove no-op steps etc.
sub optimize {
    my $ref = shift;
    clean_no_op($ref);
    return $ref;
}

# remove . and /. steps
sub clean_no_op {
    my $ref = shift;
    for ( ref $ref ) {
        when ('HASH') {
            my $paths = $ref->{path};
            for my $path ( @{ $paths // [] } ) {
                my @segments = @{ $path->{segment} };
                my @cleaned;
                for my $i ( 1 .. $#segments ) {
                    my $step = $segments[$i];
                    push @cleaned, $step
                      unless ( $step->{step}{abbreviated} // '' ) eq '.';
                }
                if (@cleaned) {
                    my $step = $segments[0];
                    if ( ( $step->{step}{abbreviated} // '' ) eq '.' ) {
                        my $sep  = $step->{separator};
                        my $next = $cleaned[0];
                        my $nsep = $next->{separator};
                        if ($sep) {
                            unshift @cleaned, $step
                              unless $nsep eq '/' && $next->{step}{full}{axis};
                        }
                        else {
                            if ( $nsep eq '/' ) {
                                delete $next->{separator};
                            }
                            else {
                                unshift @cleaned, $step;
                            }
                        }
                    }
                    else {
                        unshift @cleaned, $step;
                    }
                }
                else {
                    @cleaned = @segments;
                }
                $path->{segment} = \@cleaned;
            }
            clean_no_op($_) for values %$ref;
        }
        when ('ARRAY') {
            clean_no_op($_) for @$ref;
        }
    }
}

# remove unnecessary levels in predicate trees
sub fix_predicates {
    my $ref  = shift;
    my $type = ref $ref;
    for ($type) {
        when ('HASH') {
            while ( my ( $k, $v ) = each %$ref ) {
                if ( $k eq 'predicate' ) {
                    for my $i ( 0 .. $#$v ) {
                        my $item = $v->[$i];
                        next if exists $item->{idx};
                        if ( ref $item->{condition} eq 'ARRAY' ) {
                            $item = $item->{condition}[0];
                            splice @$v, $i, 1, $item;
                        }
                        fix_predicates($item);
                    }
                }
                else {
                    fix_predicates($v);
                }
            }
        }
        when ('ARRAY') { fix_predicates($_) for @$ref }
    }
}

# merge nested conditions with the same operator into containing conditions
sub merge_conditions {
    my $ref  = shift;
    my $type = ref $ref;
    return $ref unless $type;
    for ($type) {
        when ('HASH') {
            while ( my ( $k, $v ) = each %$ref ) {
                if ( $k eq 'condition' ) {
                    if ( !exists $v->{args} ) {
                        merge_conditions($_) for values %$v;
                        next;
                    }

                    # depth first
                    merge_conditions($_) for @{ $v->{args} };
                    my $op = $v->{operator};
                    my @args;
                    for my $a ( @{ $v->{args} } ) {
                        my $condition = $a->{condition};
                        if ( defined $condition ) {
                            my $o = $condition->{operator};
                            if ( defined $o ) {
                                if ( $o eq $op ) {
                                    push @args, @{ $condition->{args} };
                                }
                                else {
                                    push @args, $a;
                                }
                            }
                            else {
                                push @args, $condition;
                            }
                        }
                        else {
                            push @args, $a;
                        }
                    }
                    $v->{args} = \@args;
                }
                else {
                    merge_conditions($v);
                }
            }
        }
        when ('ARRAY') { merge_conditions($_) for @$ref }
        default { confess "unexpected type $type" }
    }
}

# group operators and arguments according to operator precedence ! > & > ^ > ||
sub operator_precedence {
    my $ref  = shift;
    my $type = ref $ref;
    return $ref unless $type;
    for ($type) {
        when ('HASH') {
            while ( my ( $k, $v ) = each %$ref ) {
                if ( $k eq 'condition' && ref $v eq 'ARRAY' ) {
                    my @ar = @$v;

                    # normalize ! strings
                    @ar = grep { $_ } map {
                        if ( !ref $_ && /^!++$/ ) {
                            ( my $s = $_ ) =~ s/..//g;
                            $s;
                        }
                        else { $_ }
                    } @ar;
                    $ref->{$k} = \@ar if @$v != @ar;

                    # depth first
                    operator_precedence($_) for @ar;
                    return $ref if @ar == 1;

                    # build binary logical operation tree
                  OUTER: while ( @ar > 1 ) {
                        for my $op (qw(! & ^ ||)) {
                            for my $i ( 0 .. $#ar ) {
                                my $item = $ar[$i];
                                next if ref $item;
                                if ( $item eq $op ) {
                                    if ( $op eq '!' ) {
                                        splice @ar, $i, 2,
                                          {
                                            condition => {
                                                operator => '!',
                                                args     => [ $ar[ $i + 1 ] ]
                                            }
                                          };
                                    }
                                    else {
                                        splice @ar, $i - 1, 3,
                                          {
                                            condition => {
                                                operator => $op,
                                                args     => [
                                                    $ar[ $i - 1 ],
                                                    $ar[ $i + 1 ]
                                                ]
                                            }
                                          };
                                    }
                                    next OUTER;
                                }
                            }
                        }
                    }

                    # replace condition with logical operation tree
                    $ref->{condition} = $ar[0]{condition};
                }
                else {
                    operator_precedence($v);
                }
            }
        }
        when ('ARRAY') { operator_precedence($_) for @$ref }
        default { confess "unexpected type $type" }
    }
    return $ref;
}

# looks for structures requiring normalization
sub contains_condition {
    my $ref  = shift;
    my $type = ref $ref;
    return 0 unless $type;
    if ( $type eq 'HASH' ) {
        while ( my ( $k, $v ) = each %$ref ) {
            return 1 if $k eq 'condition' || contains_condition($v);
        }
        return 0;
    }
    for my $v (@$ref) {
        return 1 if contains_condition($v);
    }
    return 0;
}

# removes redundant parentheses and simplifies condition elements somewhat
sub normalize_parens {
    my $ref  = shift;
    my $type = ref $ref;
    return $ref unless $type;
    for ($type) {
        when ('ARRAY') {
            normalize_parens($_) for @$ref;
        }
        when ('HASH') {
            for my $name ( keys %$ref ) {
                my $value = $ref->{$name};
                if ( $name eq 'condition' ) {
                    my @ar = @{ $value->{item} };
                    for my $i ( 0 .. $#ar ) {
                        $ar[$i] = normalize_item( $ar[$i] );
                    }
                    $ref->{condition} = \@ar;
                }
                else {
                    normalize_parens($value);
                }
            }
        }
        default {
            confess "unexpected type: $type";
        }
    }
    return $ref;
}

# normalizes parentheses in a condition item
sub normalize_item {
    my $item = shift;
    return $item unless ref $item;
    if ( exists $item->{term} ) {
        return normalize_parens( $item->{term} );
    }
    elsif ( exists $item->{group} ) {

        # remove redundant parentheses
        while ( exists $item->{group}
            && @{ $item->{group}{condition}{item} } == 1 )
        {
            $item = $item->{group}{condition}{item}[0];
        }
        return normalize_parens( $item->{group} // $item->{term} );
    }
    else {
        confess
          'items in a condition are expected to be either <term> or <group>';
    }
}

# some functions to undo escaping and normalize strings

sub clean_literal {
    my $m = shift;
    $m = substr $m, 1, -1;
    $m =~ s/\\(.)/$1/g;
    return $m;
}

sub clean_pattern {
    my $m = shift;
    $m = substr $m, 1, -1;
    $m =~ s/~~/~/g;
    return $m;
}

sub clean_not {
    my $m = shift;
    $m =~ s/not/!/g;
    $m =~ s/\s++//g;
    return $m;
}

sub clean_operator {
    my $m = shift;
    $m =~ s/and/&/;
    $m =~ s/xor/^/;
    $m =~ s/or/||/;
    return $m;
}

sub clean_escapes {
    my $m = shift // '';
    $m =~ s/\\(.)/$1/g;
    return $m;
}

1;

__END__

=pod

=head1 NAME

TPath::Grammar - parses TPath expressions into ASTs

=head1 VERSION

version 0.005

=head1 SYNOPSIS

    use TPath::Grammar qw(parse);

    my $ast = parse('/>a[child::b || @foo("bar")][-1]');

=head1 DESCRIPTION

C<TPath::Grammar> exposes a single function: C<parse>. Parsing is a preliminary step to
compiling the expression into an object that will select the tree nodes matching
the expression.

C<TPath::Grammar> is really intended for use by C<TPath> modules, but if you want 
a parse tree, here's how to get it.

Also exportable from C<TPath::Grammar> is C<%AXES>, the set of axes understood by TPath
expressions. See L<TPath> for the list and explanation.

=head1 FUNCTIONS

=head2 parse

Converts a TPath expression to a parse tree, normalizing boolean expressions
and parentheses and unescaping escaped strings. C<parse> throws an error with
a stack trace if the expression is unparsable. Otherwise it returns a hashref.

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
