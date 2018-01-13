package Packager::Mod::PBuilder;

# system to handle PBuilder functionality for Packager

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / PBuilderBaseDir / ];

sub init {
  my ($self,%args) = (shift,@_);
  #(desired, aquired,  packaged, installed, etc.)
  $self->PBuilderBaseDir
    ($args{PBuilderBaseDir} ||
     ConcatDir($self->PackagerDir,"pbuilder"));
}

sub Create {
  my ($self,%args) = (shift,@_);
}

sub Refresh {
  my ($self,%args) = (shift,@_);
}

sub Remove {
  my ($self,%args) = (shift,@_);
}

sub DeterminePackageDependencies {
  my ($self,%args) = (shift,@_);
}

1;
