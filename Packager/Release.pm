package Packager::Release;

use Packager::Util::File;
use Packager::Rename;
use Packager::Package;
use PerlLib::SwissArmyKnife;
use Manager::Dialog qw ( Choose Message ApproveCommand ApproveCommands
			 SubsetSelect );
use MyFRDCSA qw ( Dir ConcatDir );

use Switch;

use strict;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Name CodeBase Package Version License Status Location
                          Revision Architecture SandboxDir InstallDir DirName
                          SandboxLocation/ ];

sub init {
  my ($self,%args) = @_;
  #(desired, aquired,  packaged, installed, etc.)
  $self->CodeBase($args{CodeBase} || "");
  $self->Package($args{Package} || "");
  $self->Version($args{Version} || $self->GetVersion);
  $self->License($args{License} || "");
  $self->Status($args{Status} || "");
  $self->Name($self->CodeBase->Name);
  $self->DirName($self->Name . "-" . $self->Version);
  $self->SandboxDir($args{SandboxDir} || MyFRDCSA::Dir("sandbox"));
  $self->InstallDir(ConcatDir($self->SandboxDir,$self->DirName));
  $self->Location
    (Packager::Util::File->new
     (Filename => $args{Location} || ""));
  $self->SandboxLocation
    (Packager::Util::File->new
     (Filename => ConcatDir($self->InstallDir,$self->DirName)));
  $self->Revision("1");
  $self->Architecture($args{Architecture} || "amd64");
}

sub GetVersion {
  my ($self,@files) = @_;
  my $filename = $self->Location->Filename;
  $filename =~ s/.*-([0-9\.]+$)/$1/;
  if ($filename) {
    return $filename;
  } else {
    return Packager::Stash::Date();
  }
}


sub SelectAction {
  my ($self,%args) = @_;
  my $choice;
  my $conf = $UNIVERSAL::packager->Config->CLIConfig;
  unless ($args{Noninteractively}) {

    my @choices = qw( Stash Extract ExtractMultiple Build Rebuild Test
		     Edit DpkgInstall Upload AptGetInstall
		     RemovePackage RemoveSandbox RemoveExternal );

    foreach my $confchoice (@choices) {
      if (exists $conf->{$confchoice}) {
	$choice = $confchoice;
	last;
      }
    }
    unless (defined $choice) {
      $choice = Choose(@choices);
    }
  } else {
    $choice = $self->FindNextAction;
    # $choice = 'Upload';
  }
  if ($choice) {
    print "Choice: $choice\n";
    my $array =
      {
       # Stash => &Stash,
       Extract => \&Extract,
       ExtractMultiple => \&ExtractMultiple,
       Build => \&Build,
       Rebuild => \&Rebuild,
       Test => \&Test,
       Edit => \&Edit,
       DpkgInstall => \&DpkgInstall,
       Upload => \&Upload,
       AptGetInstall => \&AptGetInstall,
       RemovePackage => \&RemovePackage,
       RemoveSandbox => \&RemoveSandbox,
       RemoveExternal => \&RemoveExternal,
      };
    print Dumper({
		  Choice => $choice,
		  MyArgs1 => \%args,
		 }) if 0;
    $array->{$choice}->($self,%args);
  }
}

sub Extract {
  my ($self,%args) = @_;
  print "Checking InstallDir: <".$self->InstallDir.">\n";
  if (-d $self->InstallDir) {
    Message(Message => "Already extracted");
    return 1;
  }
  my $directory = $self->Location->CompleteFilename;
  print "<<<$directory>>>\n";
  my $file = Choose(split /\n/, `ls $directory`);
  my $command;
  my $newdir = $file;
  print $file."\n";
  $newdir =~ s/.*\///;
  my @order = qw (tgz tar.z tar.gz tar.bz2 tbz2 bz2 zip tar jar rar gz xz);
  my %commands = (
		  tgz => "tar -xzf <FILE>",
		  "tar.z" => "tar -xzf <FILE>",
		  "tar.gz" => "tar -xzf <FILE>",
		  "tar.bz2" => "tar -xjf <FILE>",
		  tbz2 => "tar -xjf <FILE>",
		  bz2 => "bzip2 -d <FILE>", # add something to check if it's actually a tar underneath the bz2.  tar --use-compress-prog=bzip2 xf foo.tar.bz2
		  zip => "unzip <FILE>",
		  rar => "unrar x <FILE>",
		  tar => "tar -xvf <FILE>",
		  jar => "mkdir tmp; cp <FILE> tmp",
		  # gz => "gunzip <FILE>",
		  xz => "tar -xf <FILE>",
		 );
  my $virgin = 1;
  foreach my $key (@order) {
    if ($newdir =~ /\.${key}$/i) {
      if ($virgin) {
	$virgin = 0;
	my $curcom = $commands{$key};
	$curcom =~ s|<FILE>|\"$directory/$file\"|;
	my @commands =
	  (
	   "mkdir -p ".shell_quote($self->InstallDir),
	   "cd ".shell_quote($self->InstallDir)." && $curcom",
	  );
	if (ApproveCommands
	    (
	     Commands => \@commands,
	     Method => 'serial',
	     AutoApprove => $args{Noninteractively},
	     CheckReturnValues => 1,
	    )) {
	  # now check that it is in the apropriate place
	  chdir $self->InstallDir;
	  my @files = split /\n/,`ls`;
	  if (scalar @files > 1 ) {
	    ApproveCommands
	      (
	       Commands => [
			    "mkdir ".shell_quote($self->DirName),
			    "mv * ".shell_quote($self->DirName),
			   ],
	       Method => 'serial',
	       AutoApprove => $args{Noninteractively},
	       CheckReturnValues => 1,
	      );
	  } elsif (scalar @files == 1) {
	    ApproveCommands
	      (
	       Commands => [
			    "mv ".shell_quote($files[0])." ".shell_quote($self->DirName),
			   ],
	       Method => 'serial',
	       AutoApprove => $args{Noninteractively},
	       CheckReturnValues => 1,
	      );
	  } else {
	    print "WTF?!\n";
	  }
	  Message(Message => "Extracted");
	  return 1;
	}
      }
    }
  }
}

sub ExtractMultiple {
  my ($self,%args) = @_;
  print "Checking InstallDir: <".$self->InstallDir.">\n";
  if (-d $self->InstallDir) {
    Message(Message => "Already extracted");
    return 1;
  }
  my $directory = $self->Location->CompleteFilename;
  print "<<<$directory>>>\n";
  my $possibilities = [split /\n/, `ls $directory`];
  my @result = SubsetSelect
    (
     Set => $possibilities,
     Selection => {},
    );
  print Dumper(\@result);
  my $destdir = $self->InstallDir."/".$self->DirName;
  my $command = "mkdir -p $destdir";
  return unless ApproveCommand($command);
  foreach my $file (@result) {
    my $command;
    my $newdir = $file;
    print $file."\n";
    $newdir =~ s/.*\///;
    my @order = qw (tgz tar.z tar.gz tar.bz2 tbz2 bz2 zip tar jar rar);
    my %commands = (tgz => "tar -xzf <FILE>",
		    "tar.z" => "tar -xzf <FILE>",
		    "tar.gz" => "tar -xzf <FILE>",
		    "tar.bz2" => "tar -xjf <FILE>",
		    tbz2 => "tar -xjf <FILE>",
		    bz2 => "bzip2 -d <FILE>",
		    zip => "unzip <FILE>",
		    rar => "unrar x <FILE>",
		    tar => "tar -xvf <FILE>",
		    jar => "mkdir tmp; cp <FILE> tmp"
		   );
    my $virgin = 1;
    foreach my $key (@order) {
      if ($newdir =~ /^(.+)\.${key}$/i) {
	my $finalplace = "$destdir/$1";
	if ($virgin) {
	  $virgin = 0;
	  my $curcom = $commands{$key};
	  $curcom =~ s|<FILE>|\"$directory/$file\"|;
	  my $command = "mkdir -p \"$finalplace\" && cd \"$finalplace\" && $curcom";
	  if (ApproveCommand($command)) {
	    # now check that it is in the apropriate place
	    chdir $finalplace;
	    my @files = split /\n/,`ls`;
	    if (scalar @files > 1 ) {
	      # it's okay
	    } elsif (scalar @files == 1) {
	      chdir "..";
	      if (0) {
		ApproveCommand("mv \"$finalplace\"/* . && rmdir \"$finalplace\"");
	      }
	    } else {
	      print "WTF?!";
	    }
	    Message(Message => "An archive extracted");
	    last;
	  }
	}
      }
    }
  }
  return 1;
}

sub HasPackage {
  my ($self,%args) = @_;
  if (-e ConcatDir(MyFRDCSA::Dir("binary packages"),$self->DirName)) {
    return 1;
  }
}

sub Load {
  my ($self,%args) = @_;
  $self->Package
    (Packager::Package->new
     (Release => $self,
      SandboxDir => $self->SandboxDir));
}

sub Build {
  my ($self,%args) = @_;
  if ($self->Extract) {
    # can go ahead and make a new package
    $self->Load;
    $self->Package->Generate
      (
       Noninteractively => $args{Noninteractively},
       );
  }
}

sub Rebuild {
  my ($self,%args) = @_;
  $self->Remove;
  $self->Build;
}

sub Test {
  my ($self,%args) = @_;
  $self->Build;
  if ($self->Package->IsBuilt) {
    # can go ahead upload the package
    $self->Package->Test;
  }
}

sub Edit {
  my ($self,%args) = @_;
  $self->Build;
  if ($self->Package->IsBuilt) {
    # can go ahead upload the package
    $self->Package->Edit;
  }
}

sub DpkgInstall {
  my ($self,%args) = @_;
  $self->Load;
  if ($self->Package->IsBuilt) {
    # can go ahead upload the package
    $self->Package->DpkgInstall;
  }
}

sub Upload {
  my ($self,%args) = @_;
  $self->Build;
  if ($self->Package->IsBuilt) {
    # can go ahead upload the package
    $self->Package->Upload;
  }
}

sub AptGetInstall {
  my ($self,%args) = @_;
  $self->Load;
  if (! $self->Package->IsUploaded) {
    $self->Upload;
  }
  if ($self->Package->IsUploaded) {
    $self->Package->AptGetInstall;
  }
}

sub RemovePackage {
  my ($self,%args) = @_;
  $self->Load;
  if ($self->Package->IsBuilt) {
    # can go ahead remove the package
    $self->Package->Remove;
  } else {
    Message(Message => "Package is not built");
  }
}

sub RemoveSandbox {
  my ($self,%args) = @_;
  ApproveCommand("rm -rf ".$self->InstallDir);
}

sub RemoveExternal {
  my ($self,%args) = @_;
  ApproveCommand("rm -rf ".$self->Location->CompleteFilename);
}

sub LoadSourcePackageModel {

}

sub LoadUpstreamSourceModel {

}

# sub FindNextAction {
#   my ($self,%args) = @_;
#   my $tests =
#     # Tests to see whether the action is the next action to perform,
#     # return a 1 if it is the next action that needs to be performed
#     {
#      # Stash => sub { },
#      Extract => sub {my ($self) = @_; return ! -d $self->InstallDir;},
#      # ExtractMultiple => sub { },
#      Build => sub {my ($self) = @_; $self->Load; return (! $self->Package->IsBuilt);},
#      # # Rebuild => sub { },
#      # Test => sub {my ($self) = @_; $self->Load; $self->Package->IsBuilt;},
#      # Edit => sub { },
#      # # DpkgInstall => sub { },
#      Upload => sub {
#        my ($self) = @_;
#        $self->Load;
#        if ($self->Package->IsBuilt) {
# 	 my $tmp = `grep -R frdcsa.org /etc/apt/sources.list`;
# 	 if ($tmp =~ /frdcsa/) {
# 	   my $name = $self->Name;
# 	   my $tmp2 = `apt-cache search '\b$name\b'`;
# 	   if ($tmp2 =~ /^$name - /) {
# 	     return 0;
# 	   }
# 	 }
#        }
#        return 1;
#      },
#      AptGetInstall => sub {
#        my ($self) = @_;
#        my $name = $self->Name;
#        my $tmp = `dpkg -l | grep -E '\b$name\b'`;
#        if ($tmp =~ /ii\s+$name\s/) {
# 	 return 1;
#        }
#        return 0;
#      },
#      # # RemovePackage => sub { },
#      # # RemoveSandbox => sub { },
#      # # RemoveExternal => sub { },
#      Installed => sub {
#        return 1;
#      },
#     };
#   my @testorder = qw(Extract Build Upload AptGetInstall Installed);
#   my $highestpassed = "Extract";
#   foreach my $test (@testorder) {
#     if (! $tests->{$test}->($self)) {
#       $highestpassed = $test;
#     } else {
#       last;
#     }
#   }
#   print "Highestpassed: $highestpassed\n" if 0;
#   return $highestpassed;
# }

sub Installed {
  my ($self,%args) = @_;
  print "Installed, nothing left to do.\n";
}

1;
