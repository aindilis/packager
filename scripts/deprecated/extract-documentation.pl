#!/usr/bin/perl -w

foreach my $f1 (split /\n/,`find /var/lib/myfrdcsa/codebases/external/ | rl`) {
  if ($f1 =~ /\.tgz$/) {
    print "$f1\n";
    foreach my $f2 (split /\n/,`tar tzf $f1`) {
      if ($f2 =~ /\.(txt|man|doc|pdf|ps)$/i) {
	print "<$f1><$f2>\n";
      }
    }
  }
}
