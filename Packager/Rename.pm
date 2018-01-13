package Packager::Rename;

use File::stat;
#use FileMetadata::Miner::Stat;

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw (Rename Normalize Root);

sub Date {
  my $filename = shift;
#  my $miner = FileMetadata::Miner::Stat->new(time => '%Y%m%d');
#  my $meta = {};
#  return $meta->{'FileMetadata::Miner::Stat::time'}
#    if $miner->mine ($filename, $meta);
  chomp ($date = `date "+%Y%m%d"`);
  return $date;
}

sub Rename {
  my $list = shift;
  foreach $filename (keys %$list) {
    print "$filename\n";
    my $target = Normalize(Name(Root($filename)));
    if ($target !~ /-.*\d/) {
      # append a date to the end
      $target .= "-".Date($filename);
    }
    $list->{$filename} = $target;
  }
  return $list;
}

sub Root {
  $_ = shift;
  s/.*\///;
  return $_;
}

sub Normalize {
  $_ = shift;

  return unless $_;

  # pre-encoding mannerisms
  #s/\+\s?key//;

  s/([0-9]+)[-_]([0-9]+)/$1.$2/;
  s/([0-9]+)[-_]([0-9]+)/$1.$2/;

  # encoding
  s/\_+/-/g;
  tr/[A-Z]/[a-z]/;		# downcase
  s/[^A-Za-z0-9-\.\s]//g;	# strip

  # -es
  s/[\s-]+/-/g;			# add -es

  # repair -es
  s/-\./\./g;
  s/\.+/\./g;

  # try to find version and strip everything after it
  s/(.*\w+)[-_]?([0-9]+\.[0-9]+(\.[0-9]+)).*/$1-$2/;
  return $_;
}

sub Name {
  $_ = shift;
  # is it not a program?
  if (/.(ogg|cd[0-9]+.*|wav|doc|txt|avi|mpg|wmv|mpeg|pdf|mp3)(\.[0-9]+)?$/i) {
    return "ERROR";
  }

  # is it a deb?
  if (/\.deb$/) {
    # just strip the deb convention
    s/\.deb$//;
    return $_;
  }

  # is it a regular file?
  while (/\.(zip|gz|bz2|tgz|exe|sit|bin|tar|rar|jar|ace|iso|Z)(\d+)?$/i) {
    s/\.(\w+\d*)$//;
  }

  return $_;
}

1;
