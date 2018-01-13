#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use PerlLib::Chase;

if (0) {
  foreach my $file (split /\n/, `ls -1`) {
    print "<$file>\n";

    my $qfile = shell_quote($file);
    my $basename = basename($file);
    my $qbasename = shell_quote($basename);

    my @choices = qw(dataset system other);
    my $choice = Choose2
      (
       List => \@choices,
      );
    my @commands;
    if ($choice eq 'dataset') {
      push @commands, 'mv '.$qfile.' /var/lib/myfrdcsa/datasets/';
      push @commands, 'ln -s '.shell_quote("/var/lib/myfrdcsa/datasets/$basename").' .';
    } elsif ($choice eq 'system') {
      push @commands, "packager -l $qfile";
    }
    ApproveCommands
      (
       Method => 'parallel',
       Commands => \@commands,
      );
  }
}

if (0) {
  my @commands2;
  foreach my $file2 (split /\n/, `ls -1`) {
    $chased = chase($file2);
    if ($chased =~ /\/external\//) {
      # print $chased."\n";
      my $basename = basename($chased);
      my $systemname = lc($basename);
      $systemname =~ s/[-_\.].*//;
      push @commands2, "packager $systemname\n";
    }
  }

  ApproveCommands
    (
     Method => 'parallel',
     Commands => \@commands2,
    );
}

# FIXME: afterwords sort into systems external datasets doc etc

# FIXME: then update the collection or capability repo
