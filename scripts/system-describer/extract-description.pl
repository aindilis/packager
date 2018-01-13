#!/usr/bin/perl -w

use Data::Dumper;
use String::Similarity;

# first case is find all the instances of documentation from control files

my $externaldir = "/var/lib/myfrdcsa/codebases/external";
my $sandboxdir = "/var/lib/myfrdcsa/sandbox";
my $packagedir = "/var/lib/myfrdcsa/packages/binary";
my $systems = {};
foreach my $system (split /\n/, `ls "$externaldir"`) {
  my $cf = "$externaldir/$system/control";
  if (-f $cf) {
    if (-d "$sandboxdir/$system") {
      my $c = `cat "$cf"`;
      $systems->{$system} = $c;
    }
  }
}

foreach my $system (split /\n/, `ls "$packagedir"`) {
  my $cf = "$packagedir/$system/$system/debian/control";
  if (-f $cf) {
    if (-d "$sandboxdir/$system") {
      my $c = `cat "$cf"`;
      $c =~ s/.*Description: (.*)/$1/s;
      $systems->{$system} = $c;
    }
  }
}

# print Dumper($systems);

my $cnt = 0;
my $contents = {};
foreach my $system (reverse keys %$systems) {
  # for each file in the sandbox of this system, look for these
  # contents.  If found, add them to a contents mapping
  print "\n\n############################\n\n";
  print $systems->{$system}."\n";
  print "\n\n############################\n\n";
  my $dir = "$sandboxdir/$system";
  foreach my $f (split /\n/, `find $dir`) {
    MatchesDescription
      (File => $f,
       Description => $systems->{$system},
       System => $system);
  }
  # now sort the best
  my @sorted = sort {$similarity->{$system}->{$b} <=> $similarity->{$system}->{$a} }
    keys %{$similarity->{$system}};
  foreach my $key (splice(@sorted,0,10)) {
    print $similarity->{$system}->{$key}."\t".$key."\n";
  }
  my $OUT;
  open(OUT,">similarity") or die "cannot open similarity\n";
  print OUT Dumper($similarity);
  close(OUT);
}

sub MatchesDescription {
  # look at the type of file it is
  (%args) = @_;
  my $f = $args{File};
  my $d = $args{Description};
  my $system = $args{System};
  my $type = `file "$f"`;
  chomp $type;
  if ($type =~ /^(.*): ([^:]*)$/) {
    $t = $2;
    if ($t =~ /text/) {
      # go ahead and check
      my $c = `cat "$f"`;
      my $s = similarity($d,$c);
      $similarity->{$system}->{$f} = $s;
      # print "$s\t$system\t$f\n";
    }
  }
  # there are two modes, exact and inexact matches
  # an ngram model would be easy
  # a more sophisticated distance might be nice
}

# we can conclude that this method of extracting information does not
# appear to be working, using only the string similarity, this is what
# is now in order - perhaps we have to extract documentation more,
# using conversion

# perhaps we need to do ngrams

# or perhaps we need to just search the internet for answers

# can use seeker functionality to answer specific questions
