package Packager;

use Packager::CodeBases;
use Packager::Rename;
use PerlLib::Chase;
use PerlLib::SwissArmyKnife;
use Manager::Dialog qw{Approve ApproveCommands Choose QueryUser };
use BOSS::Config;
use MyFRDCSA;

use Data::Dumper;
use String::ShellQuote;

use strict;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Items Config SandboxDir Location MyCodeBases / ];

	# index		Store codebase into external archives
	# index-multiple	Store codebase into external archives (multiple)
	# extract		Extract indexed codebase to sandbox
	# package		Generate a package for extracted codebase
	# summary		Generate a summary for package
	# status		Generate a summary for codebase
	# edit		
	# remove-package		Remove package for codebase
	# remove-sandbox		Remove sandbox directory for codebase
	# remove-external		Remove external codebase directory for codebase
	# test		Apply tests to package
	# install		Install to current system package
	# upload		Upload to archive current package

sub init {
  my ($self,%args) = (shift,@_);
  my $specification = "
	<Items>...	Items (codebases, packages, archives, ...)

	Extract			Extract indexed codebase to sandbox
	ExtractMultiple		Extract multple indexed codebases to sandbox
	Build			Generate a package for extracted codebase
	Rebuild			Regenerate the package for extracted codebase
	Test			Apply tests to package
	Edit			Make changes to package
	DpkgInstall		Install through dpkg
	Upload			Upload to archive current package
	AptGetInstall		Install through apt-get
	RemovePackage		Remove package for codebase
	RemoveSandbox		Remove sandbox directory for codebase
	RemoveExternal		Remove external codebase directory for codebase

	-d <dir>	Search directory
	-s <dir>	Sandbox directory
	-t <type>	Force type (e.g. data,ecodebase,etc)

	-l				Leave a link to the packaged file in the directory where the archive or program was

	--include-version		The items include name and version, not just name

	--short-desc <desc>		The short description for the control file
	--long-desc <desc>		The long description for the control file

	-y			Run non-interactively, guessing
";
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"packager");
  $self->Items($args{Items} || []);
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if ($conf->{'-s'}) {
    $self->SandboxDir($conf->{'-s'});
  } else {
    $self->SandboxDir(Dir("sandbox"));
  }
  if ($conf->{'-d'}) {
    $self->Location($conf->{'-d'});
  } else {
    $self->Location(Dir("external codebases"));
  }
}

sub AddItems {
  my ($self,%args) = (shift,@_);
  push @{$self->Items}, @{$args{Items}};
}

sub Execute {
  my ($self,%args) = (shift,@_);
  my $codebase;
  my $conf = $self->Config->CLIConfig;
  $self->MyCodeBases
    ($args{MyCodeBases} ||
     Packager::CodeBases->new
     (
      Location => $self->Location,
      SandboxDir => $self->SandboxDir,
     ));
  die "No items\n" unless exists $conf->{'<Items>'};
  print "FIXME: Run this first before packaging a system from any of its dirs: ./softwareindexer  -p\n";
  while (@{$conf->{'<Items>'}}) {
    my $item = shift @{$conf->{'<Items>'}};
    my $version;
    if (exists $conf->{'--include-version'}) {
      $version = shift @{$conf->{'<Items>'}};
    }
    # lets determine what to do with item
    if (-f $item) {
      # my $mimetype = `extract -p mimetype "$item"`;
      # if ($mimetype =~ /application\/x-debian-package/) { # if its a
      # # debian package, put it in with the binaries and possibly
      # # upload it to our server.
      # } else {
      # # if its an archive - then index it
      #       }
      if (Approve("Index <$item>")) {
	$codebase = $self->FindOrCreateCodeBase($item);
      }
    } elsif (-d $item) {
      if (Approve("Archive, then index directory <$item>")) {
	# first go ahead and tar it up, then package the codebase
	$item =~ s/\/$//;
	ApproveCommands
	  (
	   Commands => [
			"tar -czf ".shell_quote($item.".tgz")." ".shell_quote($item),
		       ],
	   Method => "parallel",
	  );
	my $dir1 = dirname(chase($item));
	$dir1 =~ s/\/\.$//sg;
	my $dir2 = chase('/var/lib/myfrdcsa/repositories/external/git');
	$dir2 =~ s/\/\.$//sg;
	# print "<<<$dir1>>><<<$dir2>>>\n";
	unless ($dir1 eq $dir2) {
	  ApproveCommands
	    (
	     Commands => [
			  "mv ".shell_quote($item)." /tmp",
			 ],
	     Method => "parallel",
	    );
	}
	if (-f $item.".tgz") {
	  $codebase = $self->FindOrCreateCodeBase($item.".tgz");
	}
      }
    } else {
      $codebase = $self->ChooseCodeBase
	(
	 Item => $item,
	);
    }
    if ($codebase) {
      my %selectreleaseargs;
      if (defined $version) {
	$selectreleaseargs{Version} = $version;
      }
      my $release = $codebase->SelectRelease(%selectreleaseargs);
      if ($release) {
	$codebase->Releases->{$release}->SelectAction
	  (
	   Noninteractively => (exists $conf->{'-y'}),
	  );
      }
    }
  }

}

sub FindOrCreateCodeBase {
  my ($self,@files) = (shift,@_);
  # check the file format
  my ($dir,$command);
  my $list = {};
  foreach my $file (@files) {
    $list->{$file} = 1;
  }
  my $list2 = Packager::Rename::Rename($list);
  foreach my $key (keys %$list2) {
    my $old = $key;
    my $new = $list2->{$key};
    unless ($self->Config->CLIConfig->{'-y'}) {
      while (!Approve("Use < $new > to store < $old >? ")) {
	$new = QueryUser("Please enter correct name, or type exit to skip.\n");
      }
    }
    if ($old =~ /\.deb$/) {
      $dir = MyFRDCSA::Dir("binary packages");
    } else {
      $dir = MyFRDCSA::Dir("external codebases");
    }
    if (-o $old) {
      $command = "mv";
    } else {
      $command = "cp";
    }
    my $commands = [
		    "mkdir $dir/$new",
		    "$command \"$old\" $dir/$new",
		   ];
    my $conf = $self->Config->CLIConfig;
    if (exists $conf->{'-l'}) {
      my $basename = basename($old);
      my $dirname = dirname($old);
      push @$commands, "ln -s $dir/$new/$basename $dirname";
    }
    ApproveCommands
      (Commands => $commands,
       Method => "parallel");
  }
}

sub ChooseCodeBase {
  my ($self,%args) = @_;
  return $self->MyCodeBases->SearchCodeBases
    (
     Regex => $args{Item},
    );
}

1;
