#!/usr/bin/perl -w

use Data::Dumper;

# program we wish to run

sub TestProgram {
  my %args = @_;
  my $program = $args{Program};

  # do this better using the complex output redirection stuff

  my $stdout = `$program 2> /tmp/res`;
  my $stderr = `cat /tmp/res`;
  print "$stdout\n$stderr\n";
  if (!Approve("Did the program succeed?")) {
    # program failed, extract error messages and look up
  }
}

TestProgram(Program => $ARGV[0]);
