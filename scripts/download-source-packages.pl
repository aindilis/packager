#!/usr/bin/perl -w

# we want to obtain the deb source packages for many packages

my $dir = "/var/lib/myfrdcsa/codebases/internal/packager/data/source-packages";
if (! -d $dir) {
  system "mkdirhier $dir";
}
chdir $dir;

# now start to download all packages

