package Packager::Mod::SVNBuildPackage;

# Module to manage Packager interface with svn-buildpackage

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / SVN / ];

sub init {
  my ($self,%args) = (shift,@_);
}

sub BuildPackage {
  my ($self,%args) = (shift,@_);
}

sub IntegrateNewUpstream {
  my ($self,%args) = (shift,@_);
}

1;
