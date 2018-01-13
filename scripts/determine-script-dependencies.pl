#!/usr/bin/perl -w

# given a script,  compute what perl modules need  to be installed for
# it to work

# Module::Dependency doesn't seem to handle nonlocal modules

# use Module::Dependency::Indexer;
# use Module::Dependency::Grapher;

# Module::Dependency::Indexer::setIndex( '/var/tmp/dependency/unified.dat' );
# Module::Dependency::Indexer::makeIndex( @INC, @ARGV );

# Module::Dependency::Grapher::setIndex( '/var/tmp/dependence/unified.dat' );
# Module::Dependency::Grapher::makeImage( 'both', ['Foo::Bar', 'Foo::Baz'], '/tmp/dependency.png', {Format => 'png'} );
# Module::Dependency::Grapher::makePs( 'both', ['Foo::Bar', 'Foo::Baz'], '/tmp/dependency.eps' );
# Module::Dependency::Grapher::makeText( 'both', ['Foo::Bar', 'Foo::Baz'], '/tmp/dependency.txt', {NoLegend => 1} );
# Module::Dependency::Grapher::makeHtml( 'both', ['Foo::Bar', 'Foo::Baz'], '/tmp/dependency.ssi', {NoLegend => 1} );

use Manager::Dialog qw (SubsetSelect);

use Data::Dumper;
use IPC::Open3;
use FileHandle;
use FindBin;
use Manager::Dialog qw (ApproveCommands);
use BOSS::Config;

my $specification = "
	-i		Install modules
";

my $config = BOSS::Config->new
  (Spec => $specification,
   ConfFile => "");
my $conf = $config->CLIConfig;

my %modules;
foreach my $file (@ARGV) {
  my $contents = `cat $file`;
  $contents =~ s/#.*$//mg;
  my @m1 = $contents =~ /^use\s+([A-Za-z:]+)[; ]/smg;
  foreach my $m2 (@m1) {
    $modules{$m2} = 1;
  }
}

if (exists $conf->{'-i'}) {
  InstallModules(keys %modules);
} else {
  foreach my $key (sort keys %modules) {
    print $key."\n";
  }
}

sub InstallModules {
  my @cs;
  foreach my $mod (@_) {
    if (! has_module($mod)) {
      my $c1 = "sudo radar install $mod";
      push @cs, $c1;
    }
  }
  my @c2 = SubsetSelect(Set => \@cs,
			Selection => {});
  ApproveCommands(Commands => \@c2,
		  Method => "parallel");
}

sub has_module {
  my $module_name = shift;
  # stole has_module function from MEAD Install.pl script

  my $writer = new FileHandle;
  my $reader = new FileHandle;
  my $error = new FileHandle;

  my $command = "perl -e \"use lib 'lib', 'lib/arch'; use $module_name;\"";

  open3($writer, $reader, $error, $command);

  my $error_msg = <$error>;

  return defined $error_msg ? (length($error_msg) == 0) : 1;
}
