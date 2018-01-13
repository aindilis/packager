#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $packagedir = "/var/lib/myfrdcsa/codebases/internal/packager/data/recovered/unstable";

my @changes;
my $command;
my $pass = {};
foreach my $file (split /\n/, `find $packagedir | grep '\.changes\$'`) {
  $file =~ s/^.*\///;
  $file =~ s/_([\d\.iamd_-]+.changes)$//;
  if (! -d ConcatDir("/var/lib/myfrdcsa/codebases/minor",$file) and
      ! -d ConcatDir("/var/lib/myfrdcsa/codebases/internal",$file) and $file !~ /-perl$/i) {
    push @changes, $file;
    $pass->{$file} = 1;
  }
}


my @files = split /\n/, `find /var/lib/myfrdcsa/codebases/internal/packager/data/recovered/unstable/`;

my $names = {};
my $heads = {};
my $heads2names = {};
foreach my $file (@files) {
  foreach my $change (@changes) {
    next unless $file =~ /\.changes$/;
    if ($file =~ /\/unstable\/(.+?)_i386.changes$/) {
      my $tmp = $1;
      $names->{$tmp} = $file;
      my @list = split /_/, $tmp;
      my $head = $list[0];
      $heads->{$head} = $file;
      $heads2names->{$head} = $tmp;
    }
  }
}

my $res = {};
foreach my $file (@files) {
  foreach my $head (keys %$heads) {
    if ($file =~ /\/unstable\/$head/) {
      $seen->{$file} = 1;
      $res->{$head}->{$file} = 1;
    }
  }
}

my @missed;
foreach my $file (@files) {
  if (! $seen->{$file}) {
    push @missed, $file;
  }
}

foreach my $head (keys %$res) {
  if (exists $pass->{$head}) {
    # print Dumper($res->{$head});
    my $dir = "/var/lib/myfrdcsa/packages/binary/".$heads2names->{$head};
    print "mkdir -p $dir"."\n";
    foreach my $file (keys %{$res->{$head}}) {
      print "\tcp $file $dir\n";
    }
  }
  print "\n";
}
