#!/usr/bin/perl -w

# a program to list which distribution/release each package is from, i.e.

# like this:

# ii  python2.4-mini 2.4.3-8        	unstable	A minimal subset of the Python language (ver
# ii  pyzor          0.4.0+cvs20030 	unstable	spam-catcher using a collaborative filtering
# ii  razor          2.810-2        	unstable	spam-catcher using a collaborative filtering
# ii  rcs            5.7-18         	unstable	The GNU Revision Control System
# ii  readline-commo 5.1-7          	unstable	GNU readline and history libraries, common f
# ii  reportbug      3.29.3         	unstable	reports bugs in the Debian distribution
# ii  sasl2-bin      2.1.19.dfsg1-0 	unstable	Programs for manipulating the SASL users dat
# ii  screen         4.0.2-4.1      	stable		a terminal multiplexor with VT100/ANSI termi
# ii  sed            4.1.5-1        	unstable	The GNU sed stream editor
# ii  sharutils      4.2.1-15       	unstable	shar, unshar, uuencode, uudecode
# ii  slang1         1.4.9dbs-8     	unstable	The S-Lang programming library - runtime ver
# ii  slang1a-utf8   1.4.9dbs-8     	stable		The S-Lang programming library with utf8 sup
# ii  snmpd          5.2.3-1        	unstable	NET SNMP (Simple Network Management Protocol
# ii  spamassassin   3.1.4-1        	unstable	Perl-based spam filter using text analysis
# ii  spamc          3.1.4-1        	unstable	Client for SpamAssassin spam filtering daemo
# ii  ssh            4.3p2-3        	unstable	Secure shell client and server (transitional
# ii  ssl-cert       1.0.13         	unstable	Simple debconf wrapper for openssl
# ii  strace         4.5.14-1       	unstable	A system call tracer
# ii  sysklogd       1.4.1-18       	unstable	System Logging Daemon
# ii  sysv-rc        2.86.ds1-15    	unstable	System-V-like runlevel change mechanism
# ii  sysvinit       2.86.ds1-15    	unstable	System-V-like init utilities
# ii  tar            1.15.91-2      	unstable	GNU tar
# ii  tasksel        2.54           	unstable	Tool for selecting tasks for installation on
# ii  tasksel-data   2.54           	testing	 	Official tasks used for installation of Debi
# ii  tcpd           7.6.dbs-11     	testing	 	Wietse Venema's TCP wrapper utilities
# ii  tcsh           6.14.00-7      	testing	 	TENEX C Shell, an enhanced version of Berkel
# ii  telnet         0.17-32        	testing	 	The telnet client
# ii  texinfo        4.8.dfsg.1-2   	testing	 	Documentation system for on-line information
# ii  time           1.7-21         	testing	 	The GNU time program for measuring cpu resou
# ii  traceroute     1.4a12-20      	testing	 	traces the route taken by packets over a TCP
# ii  tzdata         2006k-1        	testing	 	Time Zone and Daylight Saving Time Data
# ii  ucf            2.0014         	testing	 	Update Configuration File: preserves user ch

use Data::Dumper;
use IO::File;
use Parse::Debian::Packages;
use YAML;

my $lists = {};
foreach my $file (split /\n/, `ls /var/lib/apt/lists/*Packages`) {
  my $distribution = "unknown";
  if ($file =~ /_dists_(.*)_Packages/) {
    $distribution = $1;
  }
  if (1) {
    my $fh = IO::File->new($file);
    my $parser = Parse::Debian::Packages->new( $fh );
    while (my %package = $parser->next) {
      $lists->{$package{Package}}->{$package{Version}}->{$distribution} = \%package;
    }
  }
}

# now parse dpkg -l
my $dpkg = {};
foreach my $l (split /\n/, `env COLUMNS=1000 dpkg -l`) {
  if ($l =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(.*)$/) {
    my %package = (
		   Package => $2,
		   Version => $3,
		   Status => $1,
		   Description => $4,
		  );
    $dpkg->{$package{Package}}->{$package{Version}} =\%package;
  }
}

foreach my $package (sort keys %$dpkg) {
  foreach my $version (sort keys %{$dpkg->{$package}}) {
    my $dists = $lists->{$package}->{$version};
    my $e = $dpkg->{$package}->{$version};
    if (keys %$dists) {
      foreach my $key (sort keys %{$lists->{$package}->{$version}}) {
	printf "%-3s %-40s %-20s %-20s %s\n",$e->{Status},$package,$version,$key,$e->{Description};
      }
    } else {
      printf "%-3s %-40s %-20s %-20s %s\n",$e->{Status},$package,$version,"?",$e->{Description};
    }
  }
}
