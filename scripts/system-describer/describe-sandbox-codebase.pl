#!/usr/bin/perl -w

use System::MEAD;

use Data::Dumper;

my $mead = System::MEAD->new;

foreach my $file (split /\n/, `ls /var/lib/myfrdcsa/sandbox/*/*/README`) {
  my $c = `cat "$file"`;
  print Dumper
    ($mead->Summarize(Text => $c));
}
