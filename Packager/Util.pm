package Packager::Util;

use Data::Dumper;
use Carp::Assert;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (PackageIsInstalledP AssertPackageIsInstalled);

# A disciplined approach to dialog management with the user.

sub PackageIsInstalledP {
  # APPARENTLY THIS ALREADY DOES MOST OF THIS: DPKG::Parse::Status
  my %args = @_;
  my $error;
  # make sure the package has a valid package name
  if ($args{PackageName} !~ //) {
    $error = "Not a valid package name";
  }



  # what is it's status?

  # sample not installed

  # dpkg --status qemu
  # Package `qemu' is not installed and no info is available.
  # Use dpkg --info (= dpkg-deb --info) to examine archive files,
  # and dpkg --contents (= dpkg-deb --contents) to list their contents.

  # sample installed

  # dpkg --status qemu
  # Package: qemu
  # Status: install ok installed
  # Priority: optional
  # Section: misc
  # Installed-Size: 484
  # Maintainer: Debian QEMU Team <pkg-qemu-devel@lists.alioth.debian.org>
  # Architecture: amd64
  # Version: 0.12.3+dfsg-2
  # Depends: qemu-system (>= 0.12.3+dfsg-2), qemu-user (>= 0.12.3+dfsg-2), qemu-utils (>= 0.12.3+dfsg-2)
  # Suggests: qemu-user-static
  # Description: fast processor emulator
  #  QEMU is a fast processor emulator: currently the package supports
  #  ARM, CRIS, i386, M68k (ColdFire), MicroBlaze, MIPS, PowerPC, SH4,
  #  SPARC and x86-64 emulation. By using dynamic translation it achieves
  #  reasonable speed while being easy to port on new host CPUs. QEMU has
  #  two operating modes:
  #  .
  #   * User mode emulation: QEMU can launch Linux processes compiled for
  #     one CPU on another CPU.
  #   * Full system emulation: QEMU emulates a full system, including a
  #     processor and various peripherals. It enables easier testing and
  #     debugging of system code. It can also be used to provide virtual
  #     hosting of several virtual machines on a single server.
  #  .
  #  As QEMU requires no host kernel patches to run, it is very safe and
  #  easy to use.
  #  .
  #  This package is a metapackage depending on all qemu-related packages.
  # Homepage: http://www.qemu.org/
  
}

sub AssertPackageIsInstalled {
  my %args = @_;
  my $res = PackageIsInstalledP(%args);
  # assert();
}

