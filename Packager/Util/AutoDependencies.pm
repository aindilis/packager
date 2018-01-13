package Packager::Util::AutoDependencies;

# develop a Perl system that, if the perl program doesn't load, it
# checks to see what to install (install-script-dependencies, plus
# stuff for the debian packages for it) to make it load

use Data::Dumper;
use Expect;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyExpect /

  ];

sub init {
  my ($self,%args) = @_;

}

sub InstallScriptDependencies {
  my ($self,%args) = @_;
  # first check that all the dependencies for programs have loaded correctly...
  $self->GetProgramDependencies;

  # check that the script loads properly

  # get all the 
  if (! defined $self->MyExpect) {
    $self->StartExpect(%args);
  }

  foreach my $script (@ARGV) {
    my $exit = 0;
    while (! $exit) {
      my $res = `$script 2>&1`;
      if ($res =~ /^Can't locate (.+?).pm /sm) {
	my $module = $1;
	if (exists $seen->{$module}) {
	  print "Already seen $module, exiting!\n";
	  $exit = 1;
	} else {
	  $seen->{$module} = 1;
	  $module =~ s|/|::|g;
	  # since radar isn't available necessarily, install by hand
	  print $module."\n";
	  $debianpackage = $module;
	  $debianpackage =~ s/::/-/g;
	  $debianpackage = "lib".lc($debianpackage)."-perl";
	  print $debianpackage."\n";
	  my $res2 = `apt-cache search $debianpackage`;
	  if ($res2 =~ /./) {
	    system "sudo apt-get install $debianpackage";
	  } else {
	    # install via cpan
	    print "CPAN!\n";
	    system "sudo cpan $module";
	  }
	}
      } else {
	print "Nothing left to install, exiting!\n";
	$exit = 1;
      }
    }
  }
}

sub StartExpect {
  my ($self,%args) = @_;
  my $command = $args{Command};
  my @parameters = @{$args{Parameters}};
  $self->MyExpect(Expect->new);
  $self->MyExpect->raw_pty(1);
  $self->MyExpect->spawn($command, @parameters)
    or die "Cannot spawn $command: $!\n";
}

sub StopExpect {
  my ($self,%args) = @_;
  if ($args{HardRestart}) {
    $self->MyExpect->hard_close();
  } else {
    $self->MyExpect->soft_close();
  }
}

sub RestartServer {
  my ($self,%args) = @_;
  $self->StopExpect
    (HardRestart => 1);
  $self->StartExpect;
}

sub ProcessSentence {
  my ($self,%args) = @_;
  # $self->MyExpect->expect(300, [qr/Ready/, sub {print "Initialized.\n"}]);
  # $self->MyExpect->clear_accum();
  my $sentence = $args{Sentence};
  $self->MyExpect->print("$sentence\n");
  $self->MyExpect->expect(300, [qr/./, sub {} ]);
  my $res = $self->MyExpect->match();
  $self->MyExpect->expect(300, [qr/^$/m, sub {} ]);
  $res .= $self->MyExpect->before();
  if (! $res) {
    # timed out, restart server
    $self->RestartServer;
    return {Fail => 1};
  } else {
    $self->MyExpect->clear_accum();
    return {Result => $res};
  }
}

sub GetProgramDependencies {
  my ($self,%args) = @_;
  # we want to analyze every module that this script loads, and see
  # what it's program dependencies are and if they are installed
  foreach my $module ($self->RecursivelyGetModules) {
    $self->GetProgramDependencies
      (File => $file);
  }
  # now that we have all this information, create our list of all
  # stuff to install via apt-get
}

sub GetProgramDependencies {
  my ($self,%args) = @_;
  my $module = $args{Module};
  my $file = $module->File;
  foreach my $line (`grep '\`' $file`) {
    if ($line =~ /\`([^\`]+?)\s/) {
      my $programname = $1;
      if ($programname =~ /^[\w_\-\/]+$/) {
	$self->ProgramDependencies->{$programname} = 1;
      }
    }
  }
  foreach my $line (`grep 'system "' $file`) {
    if ($line =~ /system \"([^\"]+?)\s/) {
      my $programname = $1;
      if ($programname =~ /^[\w_\-\/]+$/) {
	PushOrCreate
	  (
	   $self->ProgramDependencies->{$programname},
	   {
	    Program => $programname,
	    Line => $line,
	    Module => $module,
	    File => $file,
	   },
	  );
      }
    }
  }
}

sub GetPackageForProgram {
  my ($s,%a) = @_;
  local $prog = $a{Program};
  if (0) {
    print $a{Module}->Name."\n";
    print $prog."\n";
    print "\n";
  }
  local $package;
  if (exists $s->Program2DebPackage->{$prog}) {
    $package = $s->Program2DebPackage->{$prog};
  } else {
    my $file = `which $prog`;
    chomp $file;
    if (-f $file) {
      my $res = `dlocate $file`;
      foreach my $line (split /\n/,$res) {
	if ($line =~ /^(.+):\s+$file$/) {
	  $package = $1;
	  last;
	}
      }
    }
    if (! $package) {
      $package = "package-for-$prog";
    }
    while (! $package) {
      print "Module: ".$a{Module}->Name."\n";
      print "Requires program: $prog\n";
      $package = "";
      if (! $s->MyUI) {
	$s->MyUI
	  (PerlLib::UI->new
	   (Menu => [
	       "Main Menu", [
			     "apt-file",
			     sub {$package = $s->GetPackageForProgramAptFile
				    (Program => $prog)},
			     "Manual",
			     sub {$package = QueryUser("What package does $prog belong to?")},
			     "Not packaged yet",
			     sub {print "Not packaged yet\n"},
			     "No package needed",
			     sub {print "No package needed\n"},
			     "Unknown package",
			     sub {print "Unknown package\n"},
			     "Use current package",
			     sub {print "Using current package <$package>\n";
				  $s->MyUI->ExitEventLoop;},
			    ],
	      ],
	    CurrentMenu => "Main Menu",
	    Hooks => {
		      Refresh => sub {print "Current Package: <$package>\n";},
		     },
	   ));
      }
      $s->MyUI->BeginEventLoop;
      print "Using package: <$package>\n";
    }
    $s->Program2DebPackage->{$prog} = $package;
  }
  return $package;
}

sub GetPackageForProgramAptFile {
  my ($s,%a) = @_;
  my $prog = $a{Program};
  if ($prog !~ q|/|) {
    $prog = "bin/$prog";
  }
  print "using $prog\n";
  my $res = `apt-file search $prog`;
  my @matches;
  foreach my $line (split /\n/, $res) {
    if ($line =~ /(.+?): (.+$prog)$/) {
      push @matches, [$1,$2];
    }
  }
  $res = ChooseByProcessor
    (Values => \@matches,
     Processor => sub {$_->[0].": ".$_->[1]});
  print Dumper($res);
  if (@$res) {
    return $res->[0]->[0];
  }
}

1;
