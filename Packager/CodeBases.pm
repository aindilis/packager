package Packager::CodeBases;

use Packager::CodeBase;
use Manager::Dialog qw ( Message Choose );
use MyFRDCSA;

use Data::Dumper;

use strict;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Location CodeBases SandboxDir / ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->Location($args{Location} || Dir("sandbox"));
  $self->SandboxDir($args{SandboxDir} || Dir("sandbox"));
  # read in the metadata file
  # don't bother for now, just list the directories
  $self->CodeBases($args{CodeBases} || {});
  $self->ReIndex;
}

sub ReIndex {
  my ($self,%args) = (shift,@_);
  my @dirs = ( $self->Location );
  my $regex = "(" . (join "|", map MyFRDCSA::Head($_), @dirs) . ")\$";
  my $mydirs = join " ", @dirs;
  my $tmp = `find -L $mydirs -maxdepth 1 -printf "%h/%f\n"`;
  foreach my $directory (split /\n/, $tmp) {
    if ($directory !~ /$regex/) {
      # split it into a version and a codebase
      my $file = Packager::Util::File->new(Filename => $directory);
      my $version = $file->ExtractVersion;
      my $codebasename = $file->ExtractCodeBase;
      my $codebase;
      if (exists $self->CodeBases->{$codebasename}) {
	$codebase = $self->CodeBases->{$codebasename};
      } else {
	$codebase = Packager::CodeBase->new(Name => $codebasename,
					    Location => $directory);
	$self->AddCodeBase(CodeBase => $codebase);
      }
      if ($version) {
	if (exists $codebase->Releases->{$version}) {
	  Message(Message => "Release already exists");
	} else {
	  $codebase->AddRelease(Release => Packager::Release->new
				(CodeBase => $codebase,
				 Version => $version,
				 Location => $directory,
				 SandboxDir => $self->SandboxDir));
	}
      }
    }
  }
}

sub ListCodeBases {
  my ($self,%args) = (shift,@_);
  return map {$self->CodeBases->{$_}} sort keys %{$self->CodeBases};
}

sub AddCodeBase {
  my ($self,%args) = (shift,@_);
  if ($args{CodeBase}->Name) {
    if (! exists $self->CodeBases->{$args{CodeBase}->Name} ) {
      $self->CodeBases->{$args{CodeBase}->Name} = $args{CodeBase};
    } else {
      Message(Message => "Cannot create a duplicate codebase.");
      Message(Message => $args{CodeBase}->Name);
    }
  }
}

sub SearchCodeBases {
  my ($self,%args) = (shift,@_);
  my $regex = $args{Regex};
  my @matches;
  foreach my $codebase ($self->ListCodeBases) {
    my $name = $codebase->Name;
    if ($name =~ /$regex/) {
      push @matches, $codebase->Name;
    }
  }
  if (@matches) {
    unless ($UNIVERSAL::packager->Config->{'-y'}) {
      Message(Message => "Select CodeBase");
      my $name2 = Choose(@matches);
      if ($name2 && exists $self->CodeBases->{$name2}) {
	return $self->CodeBases->{$name2};
      }
    } else {
      # use string similarity
      die "Not yet implemented, in SearchCodeBases\n";
    }
  } else {
    Message (Message=>"No Matches");
  }
  return;
}

1;
