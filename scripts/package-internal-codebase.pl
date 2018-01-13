#!/usr/bin/perl -w

# this has probably been superceded by Task1, probably need to copy it
# over there and clean up


use Data::Dumper;

my $entries = {};
foreach my $codebase (split /\n/,`ls /var/lib/myfrdcsa/codebases/internal/`) {
  print "<$codebase>\n";
  foreach my $file (split /\n/, `ls /var/lib/myfrdcsa/codebases/releases/$codebase*`) {
    print "\t<$file>\n";
  }
}
print Dumper($entries);




# for each one to work properly there are certain things that need to
# be done

# refactoring, they need to be refactored adequately

# make sure to test that it is doing the right thing, write test cases
# for it

# right now, do an analysis of what should be packaged

# can reorganize my entries

# various concerns

# perl modules
# executable programs go into /usr/bin
# scripts go into proper place
# documentation

# databases created if necessary
# data is handled correctly, if necessary a data package is built

# one way I can do this is by specifying a type of make file that
# specifies what is to be kept and what not, like "dirs"

# correct dependent packages (perhaps analysis of the code for that)

# ensure no private data is being released, thus run it through
# classify

# handle things like cron scripts, etc.

# move them into a directory and be sure to process them

my @dirs = [
	 "usr/bin",
	 # "usr/share/$name/doc",
	 # "$perldir",
	];

my @makefilerules = [
# 		  # copy all executables in the homedir to /usr/bin
# 		  "cp $(DESTDIR)/usr/bin",
# 		  # if it exists
# 		  "cp -ar doc $(DESTDIR)/usr/share/doc/$name",
# 		  "cp scripts/* $(DESTDIR)/usr/bin",
# 		  "cp -ar $perlfiles $(DESTDIR)/$perldir",
# 		  # if it exists
# 		  "cp -ar data $(DESTDIR)/$perldir",
# 		  # copy any emacs file to the appropriate place
# 		  # cp any etc,var files to an appropriate place
		 ];
