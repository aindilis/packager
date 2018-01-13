#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

# /var/lib/myfrdcsa/packages/debian/mini-dinstall/incoming

my $packagedir = "/var/lib/myfrdcsa/codebases/internal/packager/data/recovered/unstable";

my @changes;
my $command;
foreach my $file (split /\n/, `find $packagedir | grep '\.changes\$'`) {
  push @changes, $file;
}

$command = "sudo dput -f -c /var/lib/myfrdcsa/codebases/internal/packager/dput/dput.cf -u services ".join(" ",map {shell_quote($_)} @changes);
print $command."\n";
system $command;
