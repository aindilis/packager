#!/usr/bin/perl -w

use BOSS::Config;
use Manager::Dialog qw(SubsetSelect);

my $specification = "
	-b	do a mini-install batch afterwards
";

my $config = BOSS::Config->new
  (Spec => $specification,
   ConfFile => "");
my $conf = $config->CLIConfig;

my @files = split /\n/, `ls /var/lib/myfrdcsa/packages/debian/unstable/*.changes`;

my @res = SubsetSelect
  (
   Set => \@files,
   Selection => {},
   Processor => sub {s/^.*\///; $_},
   NoAllowWrap => 1,
  );

my $dir = "/var/lib/myfrdcsa/codebases/internal/packager/scripts/approved-release";
foreach my $file (@res) {
  $changesfile = "/var/lib/myfrdcsa/packages/debian/unstable/$file";
  system "dput -f -c $dir/config/dput.cf -u local $changesfile";
}

if ($conf->{'-b'}) {
  system "mini-dinstall -c $dir/config/mini-dinstall.conf --batch";
}
