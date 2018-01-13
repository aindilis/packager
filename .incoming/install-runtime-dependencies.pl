#!/usr/bin/perl -w

use Data::Dumper;

# script to iterate over all the solutions

# storable data structure
# find or create persistance system that is easier

my $dependencies = {};
my $command = shift;

if ($command) {
  my $loop = 1;
  while ($loop) {
    system "rm /tmp/res";
    my $s1 = `$command 2> /tmp/res`;
    my $s2 = `cat /tmp/res`;
    if ($s2 =~ /^Can\'t locate (.*?)\.pm/m) {
      my $package = $1;
      my @entries = split /\//,$package;
      my $first = $entries[0];
      my $res;
      while (@entries and ! $res) {
	my $package = join("::",@entries);
	print $package."\n";
	$res = Install
	  (Package => $package,
	   Type => "Perl Module");
	my $it = pop @entries;
      }
      if (! $res) {
	$res = Install(Package => $first);
      }
      die "can't do this" unless $res;
    } else {
      $loop = 0;
    }
  }
} else {
  print "Usage: ./install-runtime-dependencies.pl <command>\n";
}

sub Install {
  my %args = @_;
  my $package = $args{Package};
  my $errorlog = "/tmp/errorlog";

  if ($args{Type} eq "Perl Module") {
    $package =~ s/::/-/g;
    $package = lc("lib".$package."-perl");
  } else {
    $package = lc($package);
  }

  system "rm $errorlog" if -f $errorlog;
  print "Attempting to install package: $package\n";

  system "sudo apt-get install $package 2> $errorlog";
  my $res2 = `cat $errorlog`;
  if ($res2 =~ /Couldn\'t find package/) {
    return 0;
  } else {
    $dependencies->{$package} = 1;
    return 1;
  }
}

print Dumper($dependencies);
