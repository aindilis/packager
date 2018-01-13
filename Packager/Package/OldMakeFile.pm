package Packager::Package::Makefile;

use Manager::Dialog qw (Message SubsetSelect);
use MyFRDCSA;
use Packager::CodeBases;

use Cache::File;
use Data::Dumper;
use Dir::List;
use File::Stat;
use File::Find::Rule::Permissions;
use File::Basename;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / MyPackage Directory / ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->MyPackage($args{Package});
}

sub Generate {
  my ($self) = (shift);
  $self->ConvertUpstreamSourceToSourcePackage;
}

sub ConvertUpstreamSourceToSourcePackage {
  my ($self) = (shift);
  # if a jar file exists, find or create a wrapper, test it
  $self->ClassificationHeuristics;
}

sub ClassificationHeuristics {
  my ($self) = (shift);
  my $codebase = $self->MyPackage->Release->CodeBase;
  $self->Directory($self->MyPackage->RootDirAfterExtraction);
  my $sysname = $codebase->Name;

  #   my $dir = Dir::List->new();
  #   my $dirinfo = $dir->dirinfo($d1);

  # temporary rules for convenience

  # rule 0 - make java scripts

  # rule 1 - executables scripts go to /usr/bin

  my $directories = {};
  my @files =
    File::Find::Rule::Permissions->file()
	->permissions(isExecutable => 1)
	  ->in($self->Directory);

  Message(Message => "Please select files for /usr/bin");
  my @tmp = SubsetSelect
    (Selection => {},
     Set => $self->Prune
     (
      Files => \@files,
      RejectRules => [
		      sub {/~$/},
		      sub {dirname(shift) ne $self->Directory},
		     ],
     ));

  $directories->{"/usr/bin"} = \@tmp;
  foreach my $dir ("/usr/share/$sysname",
		   "/usr/share/doc/$sysname",
		   "/var/lib/$sysname",
		   "/etc",
		   "/etc/cron.d") {
    $directories->{$dir} = [];
  }

  foreach my $dir (sort keys %$directories) {
    if (@{$directories->{$dir}}) {
      my $tdir = $dir;
      $tdir =~ s/^\///;
      push @dirs, $tdir;

      # should  put in makefile  comments for  these as  place holders
      # should the user have to manually edit them
      push @install, "cp -ar ".join(" ",map $_, @{$directories->{$dir}}).
	" \$(DESTDIR)$dir";
    } else {
      push @install, "# cp -ar \$(DESTDIR)$dir";
    }
  }

  my $install = join("\n",map "\t$_", @install);

  my $c1 = "cat ".
    ConcatDir(Dir("internal codebases"),
	      "packager",
	      "Makefile.template");
  my $makefile = `$c1`;
  my $dirs = join("\n",@dirs);
  $makefile =~ s/<SYSNAME>/$sysname/;
  $makefile =~ s/<INSTALL>/$install/;
  Save(ConcatDir($self->Directory,"Makefile"),$makefile);
  Save(ConcatDir($self->Directory,"debian","dirs"),$dirs);
}

sub Save {
  my ($d,$c) = (shift,shift);
  my $OUT;
  open(OUT,">$d") or die "ouch";
  print OUT $c;
  close(OUT);
}

sub Prune {
  my ($self,%args) = (shift,@_);
  my @accepted;
  my $d1 = $self->Directory;
  foreach my $file (@{$args{Files}}) {
    my ($accept,$reject) = (0,0);
    foreach my $acceptrule (@{$args{AcceptRules} || []}) {
      $accept += &{$acceptrule}($file);
    }
    foreach my $rejectrule (@{$args{RejectRules} || []}) {
      $reject += &{$rejectrule}($file);
    }
    if ($accept or ! $reject) {
      $file =~ s/^$d1\///;
      push @accepted, $file;
    }
  }
  return \@accepted;
}

sub LearnMappings {
  my ($self) = (shift);
  # read in each Makefile, parse it
  foreach my $c1 ($UNIVERSAL::packager->MyCodeBases->ListCodeBases) {
    # extract the original version and  compare it to the Makefile and
    # the stored version
    foreach my $r1 ($c1->ListReleases) {
      if ($r1->HasPackage) {
	# now we  extract a full  model of the entire  source package,
	# and original  source, and learn  rules for this  mapping.

	# these will just be some results of heuristics
	my $usm = $r1->LoadUpstreamSourceModel;

	# for now  we'll just have this  be the Makefile  model
	my $spm = $r1->LoadSourcePackageModel;

	TrainOnExample($spm,$usm);
      }
    }
  }
}

1;
