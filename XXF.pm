package XXF;

use v5.10;
use Moose;
use MooseX::MethodAttributes;

with 'TPath::Forester';

sub children {
    my $n = $_[1];
    return () unless $n->isa('XML::XPath::Node::Element');
    return $n->getChildNodes;
}

sub tag {
    my $n = $_[1];
    return '' unless $n->isa('XML::XPath::Node::Element');
    return $n->getName;
}

sub xxf() {
    state $singleton = do {
        my $f = XXF->new;
        $f->add_test(
            sub {
                my $n = $_[1];
                return $n->isa('XML::XPath::Node::Element')
                  or $n->isa('XML::XPath::Node::Text');
            }
        );
        $f;
    };
}

sub text : Attr { $_[1]->n->string_value }

__PACKAGE__->meta->make_immutable;

1;
