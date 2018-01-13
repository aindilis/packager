#!/usr/bin/perl -w

my $res1 = `cd /opt/alice-1.4/bin && ldd seam`;
print $res1."\n";

foreach my $line (split /\n/, $res1) {
  if ($line !~ /=>/) {
    if ($line =~ /^\s*(\S+)\s+\((.+?)\s*\)$/) {
      print "<$1><$2>\n";
    } else {
      print "WTF1 $line?\n";
    }
  } elsif ($line =~ /^\s*(\S+)\s+=>\s+(.+?)\s+\((.+?)\)\s*$/) {
    print "<$1><$2><$3>\n";
    if (! -f $2) {
      print "OH NOES!\n";
    }
  } else {
    print "WTF2 $line?\n";
  }
}
