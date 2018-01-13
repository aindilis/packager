#!/usr/bin/perl -w

my $jarfile = $ARGV[0];
my $correct = $jarfile;
if ($correct =~ s/[0-9\._]*\.jar$//) {
  $PWD = `pwd`;
  chomp $PWD;
  system "export CLASSPATH=\$CLASSPATH:${PWD}/${jarfile}; java $correct";
}
