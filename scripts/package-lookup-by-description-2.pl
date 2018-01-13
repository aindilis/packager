#!/usr/bin/perl -w

# incorporate CSO/Datamart/RADAR/radar-web-search,etc.

# this version only looks at apt-cache, but in theory should utilize
# CSO, right?  also should be promoted into a module

# consider using Text::PhraseDistance, or similar

use BOSS::Config;
use Data::Dumper;
use Manager::Dialog qw (SubsetSelect ApproveCommands);


$specification = q(
	-s <search>...	Process searches
	-f <file>...	Process files
  );

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/internal/packager";

my $contentsfile = $ARGV[0];
my %freq;
my $num = 0;
my @results;

my $freqdbfile = "/tmp/freq.db";

GenerateLanguageModel();

foreach my $search (@{$conf->{'-s'}}) {
  GetPackage
    (
     Requirement => $search,
    );
}
foreach my $file (@{$conf->{'-f'}}) {
  ProcessFile
    (
     File => $file,
    );
}

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

sub ProcessFile {
  my %arsg = @_;
  my $file = $args{File};
  foreach my $line (split /\n/,`cat $file`) {
    my %score;
    chomp $line;
    GetPackage(Requirement => $line);
  }
}

sub GetPackage {
  my %args = @_;
  my $line = $args{Requirement};
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
  my @packages;
  foreach my $res (SubsetSelect
		   (Set => $set,
		    Selection => {})) {
    $res =~ s/ - .*//;
    push @packages, $res;
  }
  if (scalar @packages) {
    push @results, @packages;
  } else {
    # have to check radar now

  }
}

# takes entries like this and attempts to match them to library names

#- GNU Compiler Chain (gcc), specifically the C++ compiler (g++).
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
