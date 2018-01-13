package Packager::Package;

use Manager::Dialog qw ( QueryUser Approve ApproveCommand Choose Message
                         ChooseOrCreateNew ApproveCommands );
use Packager::Package::Makefile;
use PerlLib::SwissArmyKnife;

use Lingua::EN::Summarize;
use MyFRDCSA qw ( Dir ConcatDir Head Body );
use Text::Wrapper;
use Data::Dumper;

use strict;
use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / NameDashVersion PackageFile Location Release
                          SandboxDir SystemSandboxDir RootDirAfterExtraction
                          ChangesFile MyMakefile IsUploaded / ];

sub init {
  my ($self,%args) = @_;
  $self->Release($args{Release});
  #$self->Location($args{Location} || $self->Release->Location);
  $self->NameDashVersion($self->Release->Name."-".$self->Release->Version);
  $self->SandboxDir
    ($args{SandboxDir} ||  ConcatDir(MyFRDCSA::Dir("sandbox")));
  $self->RootDirAfterExtraction(ConcatDir($self->SandboxDir,
					  $self->NameDashVersion,
					  $self->NameDashVersion));
  $self->SystemSandboxDir(ConcatDir($self->SandboxDir,
				    $self->NameDashVersion));
  $self->PackageFile(ConcatDir
		     ($self->SystemSandboxDir,
		      $self->Release->Name."_".
		      $self->Release->Version."-".
		      $self->Release->Revision."_".
		      $self->Release->Architecture.".deb"));
  $self->ChangesFile(ConcatDir
		     ($self->SystemSandboxDir,
		      $self->Release->Name."_".
		      $self->Release->Version."-".
		      $self->Release->Revision."_".
		      $self->Release->Architecture.".changes"));
}

sub IsBuilt {
  my ($self,%args) = @_;
  print "PackageFile: ".$self->PackageFile."\n";
  return -f $self->PackageFile;
}

sub Generate {
  my ($self,%args) = @_;
  if ($self->IsBuilt) {
    Message(Message => "Package exists");
  } else {
    $self->MakePackage(Noninteractively => $args{Noninteractively});
    $self->GenDoc;
    $self->Build(Noninteractively => $args{Noninteractively});
    $self->Test;
  }
}

sub GenDoc {
  my ($self,%args) = @_;
  my $eloc = $self->RootDirAfterExtraction;
  my @results = split /\n/,`find $eloc`;
  my @extracts;

  # license
  my @files = grep(/(license|copyright|copying)/i,@results);
  if (@files) {
    Message(Message =>"Displaying licenses:");
    @extracts = $self->Extract(@files);
    foreach my $extract (@extracts) {
      Message(Message => summarize( $extract, maxlength => 1000));
    }
  } else {
    Message(Message =>"No license");
  }

  # should  be  able to  choose  summary  at  this point,  except  the
  # description generator is not very good yet

  # come up  with a better system  here based on  learning to extract.
  # This  is where we  should learn  all systems  out there  for these
  # kinds of purposes.

  Message(Message =>"Displaying documentation:");
  @files = grep(/(readme|tutorial|manual)/i,@results);
  if (@files) {
    my @shortsummaries;
    my @longsummaries;
    @extracts = $self->Extract(@files);
    foreach my $extract (@extracts) {
      push @shortsummaries, summarize( $extract, maxlength => 60 );
      push @longsummaries, summarize( $extract, maxlength => 1000 );
    }
    my $shortdesc = ChooseOrCreateNew(List => \@shortsummaries);

    # shortdesc should not start with package name

    my $longdesc = ChooseOrCreateNew(List => \@longsummaries);
    if ($shortdesc && $longdesc) {
      my $controlfile = ConcatDir($self->RootDirAfterExtraction,"debian",
				  "control");
      my $controlcontents = `cat $controlfile`;
      $shortdesc =~ s/^(.{60}).*/$1/;
      #$longdesc =~ s///;
      my $wrapper = Text::Wrapper->new(columns => 60);
      $longdesc = $wrapper->wrap($longdesc);

      $longdesc =~ s/^$/./mg;
      $longdesc =~ s/^\s*/ /mg;

      $controlcontents =~ s/^Description:.*/Description: $shortdesc\n$longdesc/ms;
      WriteToFile(Contents => $controlcontents,
		  File => $controlfile);
    }
    # now bring up the editor on the file
    OpenIfExists(ConcatDir($self->RootDirAfterExtraction,"debian","control"));
    OpenIfExists(ConcatDir($self->RootDirAfterExtraction,"Makefile"));
    OpenIfExists(ConcatDir($self->RootDirAfterExtraction,"debian","dirs"));
  } else {
    Message(Message =>"No documentation");
  }
}

sub OpenIfExists {
  my $file = shift;
  if (-f $file) {
    system "$ENV{EDITOR} ".$file;
  } else {
    print "File $file does not exist, skipping editing\n";
  }
}

sub WriteToFile {
  my (%args) = (@_);
  my $OUT;
  open(OUT,">".$args{File}) or return;
  print OUT $args{Contents};
  close(OUT);
  return 1;
}

sub Extract {
  my ($self,@files) = @_;
  my @results;
  # extract  the contents from  the archive  to a  temporary location,
  # then summarize these, and choose the best
  foreach my $file (@files) {
    if (-f $file) {
      my $text = $self->ExtractionWrapper(File => $file);
      push @results, $text if $text;
    }
  }
  return @results;
}

sub ExtractionWrapper {
  my ($self,%args) = @_;
  my $file = $args{File};
  my $text = "";
  my $type = `file $file`;
  if ($file =~ /\.ps$/) {
    $text = `pstotext $file`;
  } elsif ($file =~ /\.pdf$/) {
    $text = `pdftotext $file`;
  } elsif ($type =~ /(ASCII|English)/) {
    $text = `cat $file`;
  }
  return $text;
}

sub DoCommand {
  my $command = shift;
  Message(Message => $command);
  system $command;
}

sub MakePackage {
  my ($self,%args) = @_;
  chdir $self->RootDirAfterExtraction;
  $ENV{DEBEMAIL} ||= "andrewdo\@frdcsa.org";
  $ENV{DEBFULLNAME} ||="Andrew J. Dougherty";
  # $ENV{EDITOR} ||= "emacsclient";
  if (! -d ConcatDir($self->RootDirAfterExtraction,"debian")) {
    # try to detect if it is a single or multiple binary
    my $packageclass = 1 ? '--single' : '--multi';
    my $res =
      ApproveCommands
	(
	 Commands => [
		      "cd ".$self->RootDirAfterExtraction." && dh_make --createorig $packageclass -y",
		      "cd ".$self->RootDirAfterExtraction." && git init .",
		      "cd ".$self->RootDirAfterExtraction." && git add .",
		      "cd ".$self->RootDirAfterExtraction." && git commit -m \"Initial commit\" .",
		      "cd ".$self->RootDirAfterExtraction." && git remote add origin https://github.com/aindilis/sandbox-".$self->Release->Name.".git",
		      "cd ".$self->RootDirAfterExtraction." && git push -u origin master",
		     ],
	 Method => 'serial',
	 AutoApprove => $args{Noninteractively},
	 CheckReturnValues => 1,
	);
    return unless $res->{Success};
  }
  if (! -e ConcatDir($self->RootDirAfterExtraction,"Makefile")) {
    if (0) {
      ApproveCommands
	(
	 Commands => [
		      "cp ".
		      ConcatDir(Dir("internal codebases"),
				"packager",
				"Makefile.example")
		      . " " .
		      ConcatDir($self->RootDirAfterExtraction,
				"Makefile"),
		     ],
	 Methods => 'serial',
	 AutoApprove => $args{Noninteractively},
	 CheckReturnValues => 1,
	);
    } else {
      if (Approve("Generate Makefile?")) {
	$self->MyMakefile(Packager::Package::Makefile->new(Package => $self));
	$self->MyMakefile->Generate;
      }
    }
  }
}

sub Build {
  my ($self,%args) = @_;
  if (Approve("Have you made all your edits?")) {
    if (! -d '/tmp/packager') {
      system 'mkdir -p /tmp/packager';
    }
    if (! -d '/tmp/packager/'.$self->NameDashVersion) {
      system 'mkdir -p /tmp/packager/'.$self->NameDashVersion;
    }
    my $i = 1;
    my $backupdir;
    do {
      $backupdir = '/tmp/packager/'.$self->NameDashVersion.'/'.$i;
      ++$i;
    } while (-d $backupdir);
    if (Approve('Backup to '.$backupdir.' ?')) {
      system 'mkdir '.shell_quote($backupdir);
      my $command = 'cp -ar '.shell_quote($self->SystemSandboxDir).' '.shell_quote($backupdir);
      print "Running $command...\n";
      system $command;
    }
    my $command;
    my $key = "4DB3C58F";
    if (! -f ConcatDir($self->RootDirAfterExtraction,"Makefile")) {
      # $command = "dpkg-buildpackage -rfakeroot -uc -us -nc";
      # https://wiki.debian.org/UsingQuilt
      # $command = "dpkg-buildpackage -rfakeroot -k$key -nc";
      $command = "dpkg-buildpackage -rfakeroot -k$key";
    } else {
      # $command = "dpkg-buildpackage -rfakeroot -uc -us";
      $command = "dpkg-buildpackage -rfakeroot -k$key";
    }
    ApproveCommands
      (
       Commands => [$command],
       Method => 'serial',
       AutoApprove => $args{Noninteractively},
      );
  }
}

sub Test {
  my ($self,%args) = @_;
  my $c = "lintian -vi ".$self->ChangesFile;
  my $r;
  if (Approve($c)) {
    $r = `$c`;
    # now analyze this
    $self->AnalyzeLintianResults(Results => $r);
  }
  ApproveCommand("ln -s " .
		 ConcatDir($self->SandboxDir,
			   $self->NameDashVersion) .
		 " " . Dir("binary packages"));
}

sub AnalyzeLintianResults {
  my ($self,%args) = @_;
  my $r = $args{Results};
  my $errors = {};
  my $warnings = {};
  foreach my $line (split /\n/,$r) {
    if ($line =~ /^(.):\s*(.*)$/) {
      my $flag = $1;
      my $contents = $2;
      if ($flag =~ /W/) {
	$warnings->{$contents} = 1;
      } elsif ($flag =~ /E/) {
	$errors->{$contents} = 1;
      }
    }
  }
  print Dumper($warnings);
  print Dumper($errors);
  return (Errors => $errors,
	  Warnings => $warnings);
}

sub DpkgInstall {
  my ($self,%args) = @_;
  ApproveCommand("sudo dpkg -i ".$self->PackageFile);
}

sub Upload {
  my ($self,%args) = @_;
  my $config = ConcatDir($UNIVERSAL::systemdir, '/dput/dput.cf');
  # if (ApproveCommand("dput -f -c ~/dput.cf -u local ".$self->ChangesFile)) {
  if (ApproveCommand("sudo dput -f -c $config -u services ".$self->ChangesFile)) {
    $self->IsUploaded(1);
  }
}

sub AptGetInstall {
  my ($self,%args) = @_;
  ApproveCommands
    (Commands =>
     ["sudo apt-get update",
      "sudo apt-get install ".$self->Release->Name]);
}

sub Remove {
  my ($self,%args) = @_;
  ApproveCommand("rm ".$self->PackageFile . " " .$self->ChangesFile);
}

1;

