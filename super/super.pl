#!perl -w

use strict;
use Benchmark qw(:all);
use Config; printf "Perl/%vd on $Config{archname}\n", $^V;

{
    package BaseClass;
    sub new{ bless {}, shift }

    sub foo{
        my($self) = @_;
        # ...
    }
    
    sub bar{
        my($self) = @_;
        $self->pre_bar();
        # ...
    }
    
    sub pre_bar {
        # empty
    }
}

{
    package DerivedClass;
    use parent -norequire => qw(BaseClass);
    
    sub foo{
        my($self) = @_;
        $self->pre_foo();
        $self->SUPER::foo();
    }
    
    sub pre_foo {
        my($self) = @_;
        # ...
    }

    # no need to override bar()
    sub pre_bar {
        my($self) = @_;
        # ...
    }
}

print "\n";
cmpthese -1 => {
    'SUPER/Base' => sub{
        my $o = BaseClass->new();
        $o->foo() for 1 .. 10;
    },
    'non-SUPER/Base' => sub{
        my $o = BaseClass->new();
        $o->bar() for 1 .. 10;
    },


    'SUPER/Derived' => sub{
        my $o = DerivedClass->new();
        $o->foo() for 1 .. 10;
    },
    'non-SUPER/Derived' => sub{
        my $o = DerivedClass->new();
        $o->bar() for 1 .. 10;
    },
};

