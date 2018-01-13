#!/usr/bin/perl -w

my $command;
foreach my $file (split /\n/, `find  | grep '\.changes\$'`) {
  $command = "sudo dput -f -c /var/lib/myfrdcsa/codebases/releases/task1-0.2/task1-0.2/conf-files/dput.cf -u local ".$file;
  print $command;
  system $command;
}
