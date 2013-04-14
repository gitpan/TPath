
use strict;
use warnings;

use 5.010000;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "general purpose path languages for trees",
  "AUTHOR" => "David F. Houghton <dfhoughton\@gmail.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "TPath",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "TPath",
  "PREREQ_PM" => {
    "Exporter" => 0,
    "List::Util" => 0,
    "Moose" => "2.0604",
    "Moose::Role" => "2.0604",
    "Moose::Util::TypeConstraints" => "2.0604",
    "MooseX::MethodAttributes::Role" => "0.28",
    "MooseX::SingletonMethod" => "0.03",
    "POSIX" => 0,
    "Regexp::Grammars" => "1.026",
    "Scalar::Util" => 0,
    "Time::HiRes" => 0,
    "aliased" => 0,
    "feature" => 0,
    "namespace::autoclean" => 0,
    "overload" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "Carp" => 0,
    "File::Basename" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "List::MoreUtils" => 0,
    "MooseX::MethodAttributes" => 0,
    "Test::Exception" => 0,
    "Test::More" => "0.88",
    "Test::Trap" => 0
  },
  "VERSION" => "0.013",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



