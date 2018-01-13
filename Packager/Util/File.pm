package Packager::Util::File;

use Packager::Rename;

use strict;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / CompleteFilename Filename Directory / ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->CompleteFilename($args{Filename} || "");
  # now calculate all others
  my $filename;
  $filename = $self->CompleteFilename;
  $filename =~ s/^.*\///;
  $self->Filename($filename);
  $filename = $self->CompleteFilename;
  $filename =~ s/(.*)\/.*?$/$1/;
  $self->Directory($filename);
}

sub RelativeToCurrentPath {
  my ($self,%args) = (shift,@_);
  return $self->CompleteFilename;
}

sub RelativeToOtherFile {
  my ($self,%args) = (shift,@_);
  return $self->CompleteFilename;
}

sub ExtractCodeBase {
  my ($self,@files) = (shift,@_);
  my $filename = $self->CompleteFilename;
  my $copy = $filename;
  $filename =~ s/^.*\/(.*)-([0-9\.]+[a-zA-Z]?$)/$1/;
  if ($filename && ($copy ne $filename)) {
    return $filename;
  } else {
    return "0";
  }
}

sub ExtractVersion {
  my ($self,@files) = (shift,@_);
  my $filename = $self->CompleteFilename;
  $filename =~ s/.*-([0-9\.]+[a-zA-Z]?$)/$1/;
  if ($filename) {
    return $filename;
  } else {
    return Packager::Rename::Date();
  }
}

1;
