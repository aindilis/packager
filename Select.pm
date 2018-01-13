package Packager::Codebase::Select;

use Packager::Rename;
use Manager::Dialog qw{QueryUser Approve Choose ApproveCommands};

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (FindOrCreateCodeBase);

sub FindOrCreateCodeBase {
  my (@files) = (@_);
  # check the file format
  my ($dir,$command);
  my $list = {};
  foreach my $file (@files) {
    $list->{$file} = 1;
  }
  my $list2 = Packager::Rename::Rename($list);
  foreach my $key (keys %$list2) {
    my $old = $key;
    my $new = $list2->{$key};
    while (!Approve("Use < $new > to store < $old >? ")) {
      $new = QueryUser("Please enter correct name, or type exit to skip.\n");
    }
    if ($old =~ /\.deb$/) {
      $dir = MyFRDCSA::Dir("binary packages");
    } else {
      $dir = MyFRDCSA::Dir("external codebases");
    }
    if (-o $old) {
      $command = "mv";
    } else {
      $command = "cp";
    }
    ApproveCommands
      (Commands => ["mkdir $dir/$new",
		    "$command \"$old\" $dir/$new"],
       Method => "parallel");
  }
}

1;
