#!/usr/bin/perl -w

# before doing this probably wish to extract summarizations

# list all items in sandbox

use Data::Dumper;
use File::Stat;

my $datafile = "/var/lib/myfrdcsa/codebases/internal/packager/scripts/sandbox-data";
if (! -f $datafile) {
  my $sandboxdir = "/var/lib/myfrdcsa/sandbox";
  my $times = {};
  foreach my $f (split /\n/, `ls "$sandboxdir"`) {
    print $f."\n";
    foreach my $f1 (split /\n/, `find $sandboxdir/$f/$f`) {
      # print "$f1\n";
      $stat = File::Stat->new($f1);
      $times->{$f}->{$stat->ctime}->{$f1} = 1;
    }
    # print Dumper([sort keys %$times]);
    # now determine if this has been changed at all
  }

  my $OUT;
  open(OUT,">$datafile") or die "cannot open datafile\n";
  print OUT Dumper($times);
  close(OUT);
} else {
  # load it and count things
  my $c = `cat "$datafile"`;
  my $times = eval $c;
  my $items;
  foreach my $k (sort keys %$times) {
    $items->{$k} = scalar keys %{$times->{$k}};
  }
  foreach my $k (sort {$items->{$a} <=> $items->{$b}} keys %$items) {
    print "$k\t".$items->{$k}."\n";
  }
}

