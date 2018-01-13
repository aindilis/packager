#!/usr/bin/perl -w

# package Predator::Package::Makefile;

# the point is that rather than hand to all the classification

# first method is simply to use some heuristics, as this is the easiest method

use Dir::List;
use Data::Dumper;
use Predator::CodeBases;
use Cache::File;
use MyFRDCSA;
use File::Stat;
use File::Find::Rule::Permissions;
use File::Basename;

my $codebases = Predator::CodeBases->new();
my $d1;

sub Generate {
  ClassificationHeuristics(@_);
}

sub ClassificationHeuristics {
  my ($regex) = (shift);
  my $codebase = $codebases->SearchCodeBases(Regex => $regex);
  $d1 = $codebase->{Releases}->{$codebase->LatestRelease}
    ->SandboxLocation->CompleteFilename;

  my $sysname = $codebase->Name;

  #   my $dir = Dir::List->new();
  #   my $dirinfo = $dir->dirinfo($d1);

  # rule 1 - executables scripts go to /usr/bin

  my @files =
    File::Find::Rule::Permissions->file()
	->permissions(isExecutable => 1, user => 'nobody')
	  ->in($d1);

  my @UsrBin = Prune
    (
     Files => \@files,
     RejectRules => [
		     sub {/~$/},
		     sub {dirname(shift) ne $d1},
		    ],
    );

  my @UsrShare;
  my @UsrShareDoc;
  my @VarLib;
  my @Etc;
  my @EtcCronD;

  push @install, "cp -ar ".join(" ",map $_, @UsrBin).
    " \$(DESTDIR)/usr/bin" if @UsrBin;
  push @install, "cp -ar ".join(" ",map basename($_), @UsrShare).
    " \$(DESTDIR)/usr/share/$sysname" if @UsrShare;
  push @install, "cp -ar ".join(" ",map basename($_), @UsrShareDoc).
    " \$(DESTDIR)/usr/share/doc/$sysname" if @UsrShareDoc;
  push @install, "cp -ar ".join(" ",map basename($_), @VarLib).
    " \$(DESTDIR)/var/lib/$sysname" if @VarLib;
  push @install, "cp -ar ".join(" ",map basename($_), @Etc).
    " \$(DESTDIR)/etc" if @Etc;
  push @install, "cp -ar ".join(" ",map basename($_), @EtcCronD).
    " \$(DESTDIR)/etc/cron.d/" if @EtcCronD;

  my $install = join("\n",map "\t$_", @install);
  my $makefile = `cat Makefile.template`;
  $makefile =~ s/<SYSNAME>/$sysname/;
  $makefile =~ s/<INSTALL>/$install/;
  print $makefile;
}

sub Prune {
  my (%args) = (@_);
  my @accepted;
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
  return @accepted;
}

sub LearnMappings {
  # read in each Makefile, parse it
  foreach my $c1 ($codebases->ListCodeBases) {
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
  SaveMappings;
}

sub SaveMappings {

}

sub TrainOnExample {

}

# ClassificationHeuristics(@ARGV);

LearnMappings(@ARGV);
