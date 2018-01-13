#!/usr/bin/perl -w

# iterate over the sandbox items and extract the description
# request for package

use Data::Dumper;
use Manager::Dialog qw(Continue);

my $sandboxdir = "/var/lib/myfrdcsa/sandbox";
my $template = "/var/lib/myfrdcsa/codebases/releases/boss-0.1/boss-0.1/templates/external-codebase/frdcsa";
foreach my $dir (split /\n/, `ls $sandboxdir`) {
  if (-d "$sandboxdir/$dir") {
    if (! -d "$sandboxdir/$dir/$dir/frdcsa") {
      # try the home directory for information
      system "/usr/bin/emacsclient.emacs-snapshot -e '(dired \"$sandboxdir/$dir/$dir\")'";

      # is there a common file for this that we can edit and save as its description
      my $r1 = "$sandboxdir/$dir/.radar";
      my $r2 = "$sandboxdir/$dir/.radar2";
      if (-f $r1) {
	my $c = `cat $r1`;
	my $x = eval $c;
	print Dumper($x);
      } elsif (-f $r2) {
	my $c = `cat $r2`;
	my $x = eval $c;
	print Dumper($x);
      }

      # otherwise simply look for the item
      my $name = $dir;
      $name =~ s/-.*//;
      system "/usr/bin/emacsclient.emacs-snapshot -e '(w3m-browse-url \"http://www.google.com/search?q=$name\")'";

      # create the directory
      if (Approve("Create FRDCSA.xml for $dir?")) {
	system "cp -ar \"$template\" \"$sandboxdir/$dir/$dir\"";
	# open it up
	system "/usr/bin/emacsclient.emacs-snapshot $sandboxdir/$dir/$dir/frdcsa/FRDCSA.xml";
      }

      Continue(Result => sub {exit(0)});
    }
  } else {
    # make sure that the .radar and .radar2 information gets put into the
    # website as a link for each project
  }
}
