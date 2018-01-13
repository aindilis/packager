#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

sub ActionDeploy {
  my (%args) = @_;
  my $name = $args{Name};
  my $version = $args{Version};

  die "Name not alphanum with underlines\n" unless $name =~ /^[0-9a-zA-Z_]+$/;

  my $templatedir = '/var/lib/myfrdcsa/codebases/internal/packager/vagrant/template';
  my $vagrantpackagedir = "/var/lib/myfrdcsa/codebases/internal/packager/vagrant/packages/$name-$version";
  die "Packagedir already exists: <$vagrantpackagedir>\n" if -d $vagrantpackagedir;

  system 'cp -ar '.shell_quote($templatedir).' '.shell_quote($vagrantpackagedir);

  my $c = read_file("$templatedir/Vagrantfile");
  $c =~ s/"vm1.packager.frdcsa.org"/"$name.packager.frdcsa.org"/;

  WriteFile
    (
     File => $vagrantpackagedir."/Vagrantfile",
     Contents => $c,
    );

  # copy the data dir over
  my $sandboxpackagedir = "/var/lib/myfrdcsa/sandbox/$name-$version";
  die "No sandbox package dir: <$sandboxpackagedir>\n" unless -d $sandboxpackagedir;
  system 'cp -ar '.shell_quote($sandboxpackagedir).' '.shell_quote($vagrantpackagedir.'/data');
}

ActionDeploy
  (
   Name => 'relationfactory',
   Version => '20140521',
  );

# now deploy a terminal that changes dir into that vagrant up vagrant
# ssh, and then loads screen, emacs, switches to the directory, and
# let's you begin to manually make the package.  Record the session so
# you can rewind and see how you did things.

cd /var/lib/myfrdcsa/codebases/internal/packager/vagrant/packages/relationfactory-20140521 && uxterm +lc -e 'screen -S relationfactory vagrant ssh -c "screen -S user emacs -nw -e shell"'
