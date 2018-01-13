(check out docker hub for automatically making docker files of
 software: https://hub.docker.com/)

(https://wiki.debian.org/UsingQuilt)
(add the ability to edit the rules file in addition or perhaps in preference to the Makefile)
(dpkg-source --commit)

(andrewdo@ai:/var/lib/myfrdcsa/sandbox/xsb-20140305/xsb-20140305$ quilt new myDiff.patch
Patch myDiff.patch is now on top
andrewdo@ai:/var/lib/myfrdcsa/sandbox/xsb-20140305/xsb-20140305$ quilt add build/configure
File build/configure added to patch myDiff.patch
andrewdo@ai:/var/lib/myfrdcsa/sandbox/xsb-20140305/xsb-20140305$ quilt refresh
Refreshed patch myDiff.patch
andrewdo@ai:/var/lib/myfrdcsa/sandbox/xsb-20140305/xsb-20140305$ quilt pop -a)

(Make it so that packager displays more info about the build
 process, to guide people who are new to packaging.  For instance,
 it should say that descriptions should be lowercase for the most
 part, etc.)

(Have it react to things like this, instead of blindly trying to continue to package:
 dpkg-buildpackage: error: dpkg-source -b xsb-340 gave error exit status 2)

(Have it have an explicit rebuild sequence to help the user get
 on top of the package build progress)

(integrate pbuilder, etc)

(fix i386 assumption in lintian check)
