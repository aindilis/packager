package Packager::Letter;

use strict;

################################################################################
# Introduction

print "Dear ".$PotentialPackage->Authors->Formatted.",<p>

FRDCSA has the pleasure to inform you of our desire to package the
software system ";


################################################################################
# Authorship

if ($PotentialPackage->Authors->Cardinality == 1) {
  print "you have authored ";
} elsif ($PotentialPackage->Authors->Cardinality > 1) {
  print "you have coauthored ";
}

################################################################################
# Explanation of Merits

print "entitled ".$PotentialPackage->Name." for the Debian/GNU Linux
Project.  Packaging software is the last mile of the software delivery
process, and is therefore critical to improving the capabilities of
software systems.<p>\n";


################################################################################
# Licensing

if ($PotentialPackage->License->Type eq "Free") {

  print "You have released your software via the ".
    $PotentialPackage->License->Name."  free license.  Thank you for
    the service you have rendered our community by implementing and
    freely releasing your system.  It may sometimes surprise authors
    that there is considerable interest from among the public in their
    software.  For this reason we ask that if there are any other
    materials, such as documentation, configuration, or other software
    you may wish to license freely please do so, and let us
    know.<p>\n";

} elsif ($PotentialPackage->License->Type eq "Non-Free-Salvageable") {

  print "Your software appears to not be licensed under a free
    license.  If you can, please change this to a free license such as
    the GPL.  Please check our website at ".$website." for information
    about how to relicense.  Also, please let us know so that we can
    begin work on making and distributing packages of your system.<p>\n";

} elsif ($PotentialPackage->License->Type eq "Non-Free-Non-Salvageable") {

  print "Your software appears to not be licensed under a free
    license.  Furthermore, there appears to be significant obstacles
    to relicensing it under a free software license.  So we will not
    be able to make a package from it.<p>\n";

}


################################################################################
# Dependencies

if ($PotentialPackage->Dependencies->Significant) {

  print "Comprehensive research has shown that your system is related
    to the successful functioning of the following systems:<b>\n".
    $PotentialPackage->Dependencies->Formatted;

  if ($PotentialPackage->Dependencies->ExistsNonFreeSalvagable) {

    print "Note however that some of these systems do not have a free
      license.  Please assist in encouraging the authors of the
      systems to consider relicensing their software under a free
      license.<p>\n";

  }
}


################################################################################
# Conclusion

print "Thank you for your time.
Sincerely, The FRDCSA Group<p>\n";

1;
