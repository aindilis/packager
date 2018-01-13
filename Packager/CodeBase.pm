package Packager::CodeBase;

use Packager::Rename;
use Packager::Release;
use Packager::Util::File;
use Manager::Dialog qw ( Choose ApproveCommand ApproveCommands Message );
use Sort::Versions;

use strict;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Name URIs Authors Location Type Releases
                          Repository / ];

sub init {
  my ($self,%args) = (shift,@_);
  #(desired, aquired,  packaged, installed, etc.)
  $self->Location
    (Packager::Util::File->new
     (Filename => $args{Location}));
  $self->Name($args{Name} || $self->Location->Filename);
  $self->URIs($args{URIs} || {});
  $self->Authors($args{Authors} || {});
  $self->Type($args{Type} || "");
  $self->Releases($args{Releases} || {});
  $self->Repository($args{Repository});
}

sub AddRelease {
  my ($self,%args) = (shift,@_);
  $self->Releases->{$args{Release}->Version} = $args{Release};
}

sub ListReleases {
  my ($self,%args) = (shift,@_);
  return values %{$self->Releases};
}

sub LatestRelease {
  my ($self,%args) = (shift,@_);
  my @l = sort { versioncmp($b, $a) } sort keys %{$self->Releases};
  return shift @l;
}

sub ListAuthors {
  my ($self,%args) = (shift,@_);
  return values %{$self->Authors};
}

sub SelectRelease {
  my ($self,%args) = (shift,@_);
  if ($args{Version}) {
    foreach my $release (keys %{$self->Releases}) {
      if ($args{Version} eq $release) {
	return $release;
      }
    }
    warn "Version <".$args{Version}."> not found\n";
    #FIXME throw error here
    return;
  } elsif ($UNIVERSAL::packager->Config->CLIConfig->{'-y'}) {
    return $self->LatestRelease;
  } else {
    return Choose(keys %{$self->Releases});
  }
}

1;
