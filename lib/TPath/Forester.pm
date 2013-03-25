package TPath::Forester;
{
  $TPath::Forester::VERSION = '0.009';
}

# ABSTRACT: a generator of TPath expressions for a particular class of nodes


use feature 'state';
use Moose::Role;

use TPath::Compiler qw(compile);
use TPath::Grammar qw(parse);
use TPath::Index;
use TPath::StderrLog;
use TPath::Test::Node::True;


with qw(TPath::Attributes::Standard TPath::TypeCheck);


requires qw(children tag);


has log_stream => (
    is      => 'rw',
    isa     => 'TPath::LogStream',
    default => sub { TPath::StderrLog->new }
);


has _tests => (
    is      => 'ro',
    isa     => 'ArrayRef[CodeRef]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        add_test    => 'push',
        has_tests   => 'count',
        clear_tests => 'clear',
    },
    auto_deref => 1
);

# map from attribute names to their implementations
has _attributes => (
    is      => 'ro',
    isa     => 'HashRef[CodeRef]',
    lazy    => 1,
    builder => '_collect_attributes'
);

sub _collect_attributes {
    my $self       = shift;
    my $class      = ref $self;
    my %attributes = ();
    for my $method ( $class->meta->get_all_methods ) {
        next unless $method->can('attributes');
        my @annotations = grep /^Attr\b/, @{ $method->attributes };
        if (@annotations) {
            my $annotation = shift @annotations;
            if ( $annotation eq 'Attr' ) {
                $attributes{ $method->name } = $method->body;
            }
            else {
                if ( $annotation =~ /^Attr\((.*)\)$/ ) {
                    $attributes{$1} = $method->body;
                }
                else {
                    confess "malformed annotation $annotation on method "
                      . $method->name;
                }
            }
        }
    }
    return \%attributes;
}


sub add_attribute {
    my ( $self, $name, $attr, %options ) = @_;
    die 'attributes must have non-empty names' unless $name;
    die "attribute $name but be a code reference" unless ref $attr eq 'CODE';
    if ( $options{-force} ) {
        $self->_attributes->{$name} = $attr;
    }
    elsif ( $options{-override} ) {
        carp("override used by attribute $name does not exist")
          unless exists $self->_attributes->{$name};
        $self->_attributes->{$name} = $attr;
    }
    else {
        croak("attribute $name already exists")
          if exists $self->_attributes->{$name};
        $self->_attributes->{$name} = $attr;
    }
}


sub attribute {
    my ( $self, $n, $aname, $i, $c, @params ) = @_;
    $c //= [$n];
    $i //= $self->index($n);
    $self->_attributes->{$aname}->( $self, $n, $i, $c, @params );
}


sub path {
    my ( $self, $expr ) = @_;
    my $ast = parse($expr);
    return compile( $ast, $self );
}


sub index {
    my ( $self, $node ) = @_;
    TPath::Index->new(
        f         => $self,
        root      => $node,
        node_type => $self->node_type
    );
}


sub parent {
    my ( $self, $n, $i ) = @_;
    return $i->parent($n);
}


sub id { }

sub _kids {
    my ( $self, $n, $i ) = @_;
    my @children = $self->children( $n, $i );
    return @children unless $self->has_tests;
    grep {
        my $good = 1;
        for my $t ( $self->_tests ) {
            $good &= $t->( $self, $_, $i );
            last unless $good;
        }
        $good;
    } @children;
}

sub axis_ancestor { my $self = shift; $self->_ancestors(@_) }

sub axis_ancestor_or_self {
    my ( $self, $n, $t, $i ) = @_;
    my @nodes = $self->_ancestors( $n, $t, $i );
    push @nodes, $n if $t->passes( $n, $i );
    return @nodes;
}

sub axis_child { my $self = shift; $self->_children(@_) }

sub axis_descendant { my $self = shift; $self->_descendants(@_) }

sub axis_descendant_or_self {
    my ( $self, $n, $t, $i ) = @_;
    my @descendants = $self->_descendants( $n, $t, $i );
    push @descendants, $n if $t->passes( $n, $i );
    return @descendants;
}

sub axis_following { my $self = shift; $self->_following(@_) }

sub axis_following_sibling { my $self = shift; $self->_following_siblings(@_) }

sub axis_leaf { my $self = shift; $self->_leaves(@_) }

sub axis_parent {
    my ( $self, $n, $t, $i ) = @_;
    my $parent = $self->parent( $n, $i );
    return () unless $parent;
    return $t->passes( $parent, $i ) ? $parent : ();
}

sub axis_preceding { my $self = shift; $self->_preceding(@_) }

sub axis_preceding_sibling { my $self = shift; $self->_preceding_siblings(@_) }

sub axis_self {
    my ( $self, $n, $t, $i ) = @_;
    return $t->passes( $n, $i ) ? $n : ();
}

sub axis_sibling { my $self = shift; $self->_siblings(@_) }

sub axis_sibling_or_self { my $self = shift; $self->_siblings_or_self(@_) }

sub closest {
    my ( $self, $n, $t, $i, $first ) = @_;
    return $n if !$first && $t->passes( $n, $i );
    my @children = $self->_kids( $n, $i );
    my @closest;
    for my $c (@children) {
        push @closest, $self->closest( $c, $t, $i, 0 );
    }
    return @closest;
}

sub _siblings_or_self {
    my ( $self, $n, $t, $i ) = @_;
    return $n if $i->is_root($n) && $t->passes( $n, $i );
    grep { $t->passes( $_, $i ) } $self->_kids( $self->parent( $n, $i ), $i );
}

sub _siblings {
    my ( $self, $n, $t, $i ) = @_;
    my @siblings = $self->_untested_siblings( $self->parent( $n, $i ), $i );
    grep { $t->passes( $_, $i ) } @siblings;
}

sub _untested_siblings {
    my ( $self, $n, $i ) = @_;
    return () if $self->is_root( $n, $i );
    my $ra = refaddr $n;
    grep { refaddr $_ ne $ra } $self->_kids( $self->parent( $n, $i ), $i );
}

sub _preceding {
    my ( $self, $n, $t, $i ) = @_;
    return () if $self->is_root( $n, $i );
    my @preceding;
    state $tt = TPath::Test::Node::True->new;
    my @ancestors = $self->_ancestors( $n, $tt, $i );
    for my $a ( @ancestors[ 1 .. $#ancestors ] ) {
        for my $p ( $self->_preceding_siblings( $a, $tt, $i ) ) {
            push @preceding, $self->_descendants( $p, $t, $i );
            push @preceding, $p if $t->passes( $p, $i );
        }
    }
    for my $p ( $self->_preceding_siblings( $n, $tt, $i ) ) {
        push @preceding, $self->_descendants( $p, $t, $i );
        push @preceding, $p if $t->passes( $p, $i );
    }
    return @preceding;
}

sub _preceding_siblings {
    my ( $self, $n, $t, $i ) = @_;
    return () if $self->is_root( $n, $i );
    my @siblings = $self->_kids( $self->parent( $n, $i ), $i );
    return () if @siblings == 1;
    my @preceding_siblings;
    for my $s (@siblings) {
        last if $s eq $n;
        push @preceding_siblings, $s if $t->passes( $s, $i );
    }
    return @preceding_siblings;
}

sub _leaves {
    my ( $self, $n, $t, $i ) = @_;
    my @children = $self->_kids( $n, $i );
    return $t->passes( $n, $i ) ? $n : () unless @children;
    my @leaves;
    push @leaves, $self->_leaves( $_, $t, $i ) for @children;
    return @leaves;
}

sub _following {
    my ( $self, $n, $t, $i ) = @_;
    return () if $self->is_root( $n, $i );
    my @following;
    state $tt = TPath::Test::Node::True->new;
    my @ancestors = $self->_ancestors( $n, $tt, $i );
    for my $a ( @ancestors[ 1 .. $#ancestors ] ) {
        for my $p ( $self->_following_siblings( $a, $tt, $i ) ) {
            push @following, $self->_descendants( $p, $t, $i );
            push @following, $p if $t->passes( $p, $i );
        }
    }
    for my $p ( $self->_following_siblings( $n, $tt, $i ) ) {
        push @following, $self->_descendants( $p, $t, $i );
        push @following, $p if $t->passes( $p, $i );
    }
    return @following;
}

sub _following_siblings {
    my ( $self, $n, $t, $i ) = @_;
    return () if $self->is_root( $n, $i );
    my @siblings = $self->_kids( $self->parent( $n, $i ), $i );
    return () if @siblings == 1;
    my ( @following_siblings, $add );
    my $ra = refaddr $n;
    for my $s (@siblings) {
        if ($add) {
            push @following_siblings, $s if $t->passes( $s, $i );
        }
        else {
            $add = $ra eq refaddr $s;
        }
    }
    return @following_siblings;
}

sub _descendants {
    my ( $self, $n, $t, $i ) = @_;
    my @children = $self->_kids( $n, $i );
    return () unless @children;
    my @descendants;
    for my $c (@children) {
        push @descendants, $self->_descendants( $c, $t, $i );
        push @descendants, $c if $t->passes( $c, $i );
    }
    return @descendants;
}


sub is_leaf {
    my ( $self, $n, $i ) = @_;
    my @children = $self->_kids( $n, $i );
    return !@children;
}


sub is_root {
    my ( $self, $n, $i ) = @_;
    $i->is_root($n);
}

sub _ancestors {
    my ( $self, $n, $t, $i ) = @_;
    my @nodes;
    while ( !$self->is_root( $n, $i ) ) {
        my $parent = $self->parent( $n, $i );
        unshift @nodes, $parent if $t->passes( $parent, $i );
        $n = $parent;
    }
    return @nodes;
}

sub _children {
    my ( $self, $n, $t, $i ) = @_;
    my @children = $self->_kids( $n, $i );
    return () unless @children;
    grep { $t->passes( $_, $i ) ? $_ : () } @children;
}


sub has_tag {
    my ( $self, $n, $tag ) = @_;
    my $t = $self->tag($n);
    return undef unless defined $t;
    $t eq $tag;
}


sub matches_tag {
    my ( $self, $n, $rx ) = @_;
    my $t = $self->tag($n);
    return undef unless defined $t;
    $t =~ $rx;
}


sub wrap { return $_[1] }

1;

__END__

=pod

=head1 NAME

TPath::Forester - a generator of TPath expressions for a particular class of nodes

=head1 VERSION

version 0.009

=head1 SYNOPSIS

  # we apply the TPath::Forester role to a class

  {
    package MyForester;

    use Moose;                                      # for simplicity we omit removing Moose droppings, etc.
    use MooseX::MethodAttributes;                   # needed if you're going to add some attributes

    with 'TPath::Forester';                         # compose in the TPath::Forester methods and attributes

    # define abstract methods
    sub children    { $_[1]->children }             # our nodes know their children
    sub parent      { $_[1]->parent }               # our nodes know their parent
    sub has_tag     {                               # our nodes have a tag attribute which is
       my ($self, $node, $tag) = @_;                #   their only tag
       $node->tag eq $tag;
    }
    sub matches_tag { 
       my ($self, $node, $re) = @_;
       $node->tag =~ $re;
    }

    # define an attribute
    sub baz :Attr   {   
      # the canonical order of arguments, none of which we need
      # my ($self, $node, $index, $collection, @args) = @_;
      'baz';
    }
  }

  # now select some nodes from a tree

  my $f     = MyForester->new;                      # make a forester
  my $path  = $f->path('//foo/>bar[@depth = 4]');   # compile a path
  my $root  = fetch_tree();                         # get a tree of interest
  my @nodes = $path->select($root);                 # find the nodes of interest

  # say our nodes have a text method that returns a string

  $f->add_test( sub { shift->text =~ /^\s+$/ } );   # ignore whitespace nodes
  $f->add_test( sub { shift->text =~ /^-?\d+$/ } ); # ignore integers
  $f->add_test( sub { ! length shift->text } );     # ignore empty nodes

  # reset to ignoring nothing

  $f->clear_tests;

=head1 DESCRIPTION

A C<TPath::Forester> understands your trees and hence can translate TPath expressions
into objects that will select the appropriate nodes from your trees. It can also generate
an index appropriate to your trees if you're doing multiple selects on a particular tree.

C<TPath::Forester> is a role. It provides most, but not all, methods and attributes
required to construct L<TPath::Expression> objects. You must specify how to find a node's
children and its parent (you may have to rely on a L<TPath::Index> for this), and you
must define how a tag string or regex may match a node, if at all.

=head2 Why "Forester"

Foresters are people who can tell you about trees. A class with the role C<TPath::Forester>
can also tell you about trees. I think know "arborist" sounds better, but I don't feel like
refactoring everything to use a new name.

=head1 ATTRIBUTES

=head2 log_stream

A L<TPath::LogStream> required by the C<@log> attribute. By default it is L<TPath::StderrLog>. This attribute
is required by the C<@log> attribute from L<TPath::Attributes::Standard>.

=head1 METHODS

=head2 add_test, has_tests, clear_tests

Add a code ref that will be used to test whether a node is ignorable. The
return value of this code will be treated as a boolean value. If it is true,
the node, and all its children, will be passed over as possible items to return
from a select.

Example test:

  $f->add_test(sub {
      my ($forester, $node, $index) = @_;
      return $forester->has_tag('foo');
  });

Every test will receive the forester itself, the node, and the index as arguments. This example test
will cause the forester C<$f> to ignore C<foo> nodes.

This method has the companion methods C<has_tests> and C<clear_tests>. The former says
whether the list is empty and the latter clears it.

=head2 add_attribute

Expects a name, a code reference, and possibly options. Adds the attribute to the forester.

If the attribute name is already in use, the method will croak unless you specify that this
attribute should override the already named attribute. E.g.,

  $f->add_attribute( 'foo', sub { ... }, -override => 1 );

If you specify the attribute as overriding and the name is *not* already in use, the method
will carp. You can use the C<-force> option to skip all this checking and just add the
attribute.

Note that the code reference will receive the forester, a node, an index, a collection of nodes, and
optionally any additional arguments. B<If you want the attribute to evaluate as undefined for
a particular node, it must return C<undef> for this node.>

=head2 attribute

Expects a node, an attribute name, an index, a collection, and a parameter list. Returns
the value of the attribute in that context. If C<undef> is provided for the collection and
index, default values are created -- a single element collection containing the node and a
new index.

=head2 path

Takes a TPath expression and returns a L<TPath::Expression>.

=head2 index

Takes a tree node and returns a L<TPath::Index> object that
L<TPath::Expression> objects can use to cache information about
the tree rooted at the given node.

=head2 parent

Expects a node and an index and returns the parent of the given node according to the index.
If your nodes know their own parents, you probably want to override this method. See also
L<TPath::Index>.

=head2 id

Expects a node. Returns id of node, if any. By default this method always returns undef.
Override if your node has some defined notion of id.

=head2 is_leaf

Expects a node, and an index.

Returns whether the context node is a leaf. Override this with something more
efficient where available. E.g., where the node provides an C<is_leaf> method,

  sub is_leaf { $_[1]->is_leaf }

=head2 is_root

Expects a node and an index.

Returns whether the context node is the root. Delegates to index.

Override this with something more efficient where available. E.g., where the 
node provides an C<is_root> method,

  sub is_root { $_[1]->is_root }

=head2 has_tag

Expects a node and a string. Returns whether the node, in whatever sense is appropriate
to this sort of node, "has" the string as a tag. See the required C<tag> method.

=head2 matches_tag

Expects a node and a compiled regex. Returns whether the node, in whatever sense is appropriate
to this sort of node, has a tag that matches the regex. See the required C<tag> method.

=head2 wrap

Expects a node and possibly an options hash. Returns a node of the type understood by the forester.

If your forester must coerce things into a tree of the right type, override this method, which otherwise
just passes through its second argument.

Note, if you do need to override the default wrap, you'll have to jump through a few Moose hoops. The
basic pattern is

  ...
  use Moose;
  ...
  with 'TPath::Forester' => { -excludes => 'wrap' };
  ...

  {
      no warnings 'redefine';
      sub wrap {
          my ($self, $node, %opts) = @_;
          return $node if blessed $node and $node->isa('MyNode');
          # coerce
          ...
      }
  }

See L<TPath::Forester::Ref> for an example.

=head1 ROLES

L<TPath::Attributes::Standard>, L<TPath::TypeCheck>

=head1 REQUIRED METHODS

=head2 children

Expects a node and an index. Returns the children of the node as a list.

=head2 tag

Expects a node and returns the value selectors are matched against, or C<undef> if the node
has no tag.

If your node type cannot be so easily mapped to a particular tag, you may want to override the
C<has_tag> and C<matches_tag> methods and supply a no-op method for C<tag>.

=head1 AUTHOR

David F. Houghton <dfhoughton@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by David F. Houghton.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
