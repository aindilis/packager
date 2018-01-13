package Packager::Packages;

use Manager::Dialog;
use strict;
use MyFRDCSA;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Location Packages / ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->Location($args{Location} || MyFRDCSA::Dir("home"));
  $self->Packages($args{Packages} || {});
}

sub ListPackages {
  my ($self,%args) = (shift,@_);
  return values %{$self->Packages};
}

sub SearchPackages {
  my ($self,%args) = (shift,@_);
  my $regex = $args{Regex};
  foreach my $package ($self->ListPackages) {
    if ($package->Name =~ eval $regex) {
      push @matches, $package->Name;
    }
  }
  Message("Select Package");
  my $package Choose(@matches)
}

1;
