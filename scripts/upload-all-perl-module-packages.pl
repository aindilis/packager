#!/usr/bin/perl -w

# run this periodically, but check first that they are not already
# there, I guess this does that

use Manager::Dialog qw(ApproveCommands);

my $debauxroot = "/var/tmp/debaux-root";

my $packages;
foreach my $item (split /\n/, `zgrep '^Package:' /var/www/debian/unstable/Packages.gz`) {
  $item =~ s/^Package: //;
  $packages->{$item} = 1;
}

my @commands;
foreach my $dir (split /\n/, `ls $debauxroot`) {
  # obtain the changes file
  my $changesfile = `ls $debauxroot/$dir/*.changes`;
  chomp $changesfile;
  if ($changesfile =~ /^.+\/(.+?)_(.+).changes$/) {
    my $package = "lib$1";
    if (! exists $packages->{$package}) {
      my $c = "sudo dput -f -c ~/.dput.cf -u local $changesfile";
      print $c."\n";
      push @commands, $c;
    } else {
      print "HAVE $package\n";
    }
  }
}

ApproveCommands
  (Commands => \@commands,
   Method => "parallel");
