package Packager::Package::Makefile;

use BOSS::ICodebase qw(GetPerlModuleLinks);
use Manager::Dialog qw (Approve Message SubsetSelect);
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

  my $ret = $self->DoChecksForInternalCodebase;
  push @install, @{$ret->{Make}};
  push @dirs, @{$ret->{Dirs}};

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
  if (Approve("Save debian/dirs information?")) {
    Save(ConcatDir($self->Directory,"debian","dirs"),$dirs);
  }
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

sub DoChecksForInternalCodebase {
  my ($self, %args) = @_;
  # generate the control, dir and makefiles
  # generate the control file
  # add the description, etc of the program
  # generate makefile
  # identify the perl modules and where the perl modules are...
  my $system = $self->MyPackage->Release->Name;
  my $rdir = $self->MyPackage->RootDirAfterExtraction;
  my $methods = {
		 "doc" => {
			   Dirs => "usr/share/doc/$system",
			   Makefile => "cp -ar doc \$(DESTDIR)/usr/share/doc/$system",
			  },
		 "etc" => {
			   Dirs => "etc/$system",
			   Makefile => "cp -ar etc/\$(SYSNAME) \$(DESTDIR)/etc",
			  },
		 "var" => {
			   Dirs => "var/lib/$system",
			   Makefile => "cp -ar var/lib/\$(SYSNAME) \$(DESTDIR)/var/lib",
			  },
		 "__perlmods" => {
				  Dirs => "usr/share/perl5",
				  Producer => sub {
				    my $ret = GetPerlModuleLinks(@_);
				    my $a = $ret->{LinkDirectory};
				    my $b = $ret->{LinkModule};
				    $a =~ s|.*\/(.*)$|$1|;
				    $b =~ s|.*\/(.*)$|$1|;
				    return {
					    Make => ["cp -ar ".
						     join(" ",map {"\"$_\""} ($a,$b)).
						     " \$(DESTDIR)/usr/share/perl5"],
					    Dirs => ["usr/share/perl5"],
					   },
					 },
				 },
		};
  # get the modules, we get that in the program that updates links

  my @dirs;
  my @make;
  foreach my $k (keys %$methods) {
    my $j = $methods->{$k};
    print "$rdir/$k\n";
    if (-e "$rdir/$k") {
      push @dirs, $j->{Dirs};
      push @make, $j->{Makefile};
    } elsif (exists $j->{Producer}) {
      my $res = $j->{Producer}->($system);
      push @dirs, @{$res->{Dirs}};
      push @make, @{$res->{Make}};
    }
  }

  print Dumper(\@dirs,\@make);

  return {
	  Dirs => \@dirs,
	  Make => \@make,
	 };
}

1;
