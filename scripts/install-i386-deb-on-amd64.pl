#!/usr/bin/perl -w

use Manager::Dialog qw(Approve QueryUser);

use File::Temp qw(tempdir);
use String::ShellQuote;

my $debfile = shift;
my $copy = $debfile;
$copy =~ s/^.*\///;

my $dir = "/var/lib/myfrdcsa/codebases/internal/packager/data/i386"; # tempdir();
mkdir $dir;
system "cp ".shell_quote($debfile)." $dir";
my $dir2 = `pwd`;
chdir $dir;
system "ar -x ".shell_quote($copy);
system "rm control.tar.gz";
system "tar -zxf data.tar.gz";
system "sudo cp -p usr/lib/* /usr/lib32";
system "find .";

# You will have to 
print "sudo ln -s /usr/lib32/libXxf86vm.so.1.0.0 /usr/lib32/libXxf86vm.so.1";
die "Cannot proceed" unless Approve("Have you checked and fix symbolic links in /usr/lib32 for unpacked and copied libraries?");
system "sudo libconfig";

my $file = QueryUser("Where is the executable file?");
system "ldd ".shell_quote($file)." | grep \"not found\"";

print "If there is something missing repeat steps discussed above: download required i386 deb package, unpack, copy, fix symlinks, run ldconfig, run ldd and check the output for skype binary.\n";

system "linux32 ".shell_quote($file);
