#!/usr/bin/perl -w

# this version only looks at apt-cache, but in theory should utilize
# CSO, right?  also should be promoted into a module

# consider using Text::PhraseDistance, or similar

use Data::Dumper;
use Manager::Dialog qw (SubsetSelect ApproveCommands);

my $contentsfile = $ARGV[0];
my %freq;
my $num = 0;
my @results;

my $freqdbfile = "/tmp/freq.db";

GenerateLanguageModel();
ChoosePackageProvidingRequirement();

print Dumper(\@results);
ApproveCommands
  (Commands => ["sudo apt-get install ".join(" ",@results)],
   Method => "parallel");

sub GenerateLanguageModel {
  if (0) {			#-e "freq.db") {
    (%freq,$num) = eval `cat $freqdbfile`;
    print "NUM:$num\n";
  } else {
    my $results = `apt-cache search .`;
    foreach my $word (split /\W+/, $results) {
      if (defined $freq{$word}) {
	$freq{$word} += 1;
      } else {
	$freq{$word} = 1;
      }
      ++$num;
    }
    my $OUT;
    open(OUT,">$freqdbfile") or die "ouch!";
    print OUT Dumper($num,%freq);
    close(OUT);
  }
}

sub ChoosePackageProvidingRequirement {
  foreach my $line (split /\n/,`cat $contentsfile`) {
    my %score;
    chomp $line;
    my @keywords = split /\W+/, $line;
    foreach my $keyword (@keywords) {
      if (length $keyword > 3) {
	foreach my $result (split /\n/, `apt-cache search $keyword`) {
	  #if ($result =~ s/ - .*//) {
	  if ($result =~ / - .*/) {
	    if ($freq{$keyword}) {
	      $score{$result} += ($num / $freq{$keyword});
	    }
	  }
	}
      }
    }
    my @top = sort {$score{$a} <=> $score{$b}} keys %score;
    #print "\n\n$line\n".Dumper(@keywords).Dumper(reverse map {[$_,$score{$_}]} splice (@top,-10));
    print "\n\n<$line>\n";
    my $set;
    if (@top > 20) {
      $set = [reverse splice (@top,-20)]
    } else {
      $set = [reverse @top];
    }
    foreach my $res (SubsetSelect
      (Set => $set,
       Selection => {})) {
      $res =~ s/ - .*//;
      push @results, $res;
    }
  }
}

# takes entries like this and attempts to match them to library names

#GNU Compiler Chain (gcc), specifically the C++ compiler (g++).
#- MySQL client development library.
#- libxml2 development library.
#- Berkeley DB  development library version 3.x or 4.x.
#- Perl compatible regular expression (libpcre) development library version 3.x.
#- zlib compression/decompression development library.
#- OpenSSL SSL/TLS development library.
#- The en_IE@euro locale.

# long term goals

# goal given  an arbitrary textual description and  a system, identify
# either the  correct package, library  name, or search criteria  in a
# way  that  minimizes  the  time  spent  in  the  package  dependency
# discovery cycle

# given training  material, create a function which  maps entries like
# the ones above to a list of probable names

# check the radar system for packages which

# build language model
