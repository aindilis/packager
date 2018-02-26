# packager
Semi-automatically package sources for Debian

<system>
  <title>Packager</title>
  <short-description>
    Semi-automatically package sources
  </short-description>
  <medium-description>
    An  architecture for automatically  packaging codebases  for Linux
    packaging  systems, like  Debian's deb  format, RedHat's  rpm, and
    Slackware's tgz.  There are a  number of strategies that we use to
    enable Packager to package codebases that have been discovered and
    retrieved  by  RADAR.  Up  until  now  we  have simply  hand-coded
    algorithms in OO Perl.  But obviously, once we find more organized
    methods,  these  will  gradually  replace  the  current  throwaway
    scripts.   For  example,  we  have  considered  is  writing  NPDDL
    planning domains.  A key feature is that Packager is able to learn
    from the user  in order to increase the class  of codebases it can
    handle.   And,  just recently  we  have  considered that  existing
    packages, along  with their  original codebase sources,  provide a
    wealth  of information  that could  be  used as  input to  machine
    learning systems.   Package maintainence is also  within the scope
    of the Packager project.
  </medium-description>
  <long-description>
<para>
    RADAR/Packager/Architect  are  the core  applications  of the  CSA
    component of  the FRDCSA project.  CSA stands  for Cluster, Study,
    and  Apply.   Therefore  RADAR  provies  the  Cluster  capability,
    Packager the Study capability, and Architect the Apply capability.
</para>
<para>
  Here is  a typical use of  Packager.  Note that  the transcript will
  not  show   the  editting  of  the   debian/control,  Makefile,  and
  debian/dirs file.

<pre>
~ $ packager lapis
Select CodeBase
&amp;Chose:lapis>
&amp;Chose:1.2>
0) Stash
1) Extract
2) Build
3) Rebuild
4) Test
5) Edit
6) DpkgInstall
7) Upload
8) AptGetInstall
9) RemovePackage
10) RemoveSandbox
11) RemoveExternal
8
Already extracted
cd /var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2 &amp;&amp; dh_make
Execute this command?: y

Type of package: single binary, multiple binary, library, or kernel module?
 [s/m/l/k] s

Maintainer name : Andrew J. Dougherty
Email-Address   : ajd@frdcsa.org 
Date            : Tue, 21 Jun 2005 00:22:47 -0400
Package Name    : lapis
Version         : 1.2
Type of Package : Single
Hit &amp;enter> to confirm: y
Currently there is no top level Makefile. This may require additional tuning.
Done. Please edit the files in the debian/ subdirectory now. You should also
check that the lapis Makefiles install into $DESTDIR and not in / .
Please select files for /usr/bin
  0) Finished
> 0
Displaying licenses:
This software was written by Eric Brill. This software is being provided to you. You agree that you have read. Will comply with these terms and conditions: Permission to [use. This software and its documentation for any purpose and without fee or royalty] is hereby granted. THIS SOFTWARE IS PROVIDED "AS IS". MAKES NO REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS.
V 1.1 2003/02/22 18:24:19 rcm Exp $ Jacl 1.1.1 and Tcl Blend 1.1.1 binaries are released with the following copyrights Copyright (c) 1997-1999 The Regents of the University of California. Permission is hereby granted. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS. Jacl1.0 and Tcl Blend 1.0 binaries were release by Sun with the following license terms. THROUGH ITS SUN MICROSYSTEMS LABORATORIES DIVISION ("SUN") WILL LICENSE THIS SOFTWARE AND THE ACCOMPANYING DOCUMENTATION TO YOU (a "Licensee") ONLY ON YOUR ACCEPTANCE OF ALL THE TERMS SET FORTH BELOW. The Software is copyrighted by Sun and other third parties and Licensee shall retain and reproduce all copyright and other notices presently on the Software. Sun is the sole owner of all rights in and to the Software other than the limited rights granted to Licensee herein. Licensee will own its Modifications. Licensee will. THE SOFTWARE IS BEING PROVIDED TO LICENSEE "AS IS" AND ALL EXPRESS OR IMPLIED CONDITIONS AND WARRANTIES.
- This software was written by Eric Brill. This software is being provided to you. You agree that you have read. Will comply with these terms and conditions: Permission to [use. This software and its documentation for any purpose and without fee or royalty] is hereby granted. THIS SOFTWARE IS PROVIDED "AS IS". MAKES NO REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS.
V 1.1 2000/08/25 01:28:50 rcm Exp $ Jacl 1.1.1 and Tcl Blend 1.1.1 binaries are released with the following copyrights Copyright (c) 1997-1999 The Regents of the University of California. Permission is hereby granted. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS. Jacl1.0 and Tcl Blend 1.0 binaries were release by Sun with the following license terms. THROUGH ITS SUN MICROSYSTEMS LABORATORIES DIVISION ("SUN") WILL LICENSE THIS SOFTWARE AND THE ACCOMPANYING DOCUMENTATION TO YOU (a "Licensee") ONLY ON YOUR ACCEPTANCE OF ALL THE TERMS SET FORTH BELOW. The Software is copyrighted by Sun and other third parties and Licensee shall retain and reproduce all copyright and other notices presently on the Software. Sun is the sole owner of all rights in and to the Software other than the limited rights granted to Licensee herein. Licensee will own its Modifications. Licensee will. THE SOFTWARE IS BEING PROVIDED TO LICENSEE "AS IS" AND ALL EXPRESS OR IMPLIED CONDITIONS AND WARRANTIES.
This package was debianized by Andrew J.
Displaying documentation:
0) &amp;Cancel>
1) &amp;Other>
2) This program was written by Eric Brill (brill@goldilocks.lcs.mit.edu) Feel free to contact me with any questions.
3) My email address will be brill@blaze.cs.jhu.edu) Feel free to contact me with any questions.
4) My email address will be brill@blaze.cs.jhu.edu) Feel free to contact me with any questions.
5) My email address will be brill@blaze.cs.jhu.edu) Feel free to contact me with any questions.
6) This program was written by Eric Brill (brill@goldilocks.lcs.mit.edu) (After July 1 1994.
7) This program was written at the Department of Computer and Information Science.
8) LAPIS is a lightweight structured text editing system. These instructions assume that you have Java 1.4 or later installed on your computer.
9) 
8
0) &amp;Cancel>
1) &amp;Other>
2) This program was written by Eric Brill (brill@goldilocks.lcs.mit.edu) Feel free to contact me with any questions. My email address will be brill@blaze.cs.jhu.edu) =============================================================================== THIS SOFTWARE IS PROVIDED "AS IS". MAKES NO REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS. See the papers listed at the end of this file. =================================================================== Tagging is done in two stages. Every word is assigned its most likely tag in isolation. A list of transformations is provided for determining the most likely tag for words not in the lexicon. Unknown words are first assumed to be nouns (proper nouns if capitalized). Adjacent word cooccurrence are used to change the guess of most likely tag. Contextual transformations are used to improve accuracy. =================================================================== To compile the programs.
3) My email address will be brill@blaze.cs.jhu.edu) Feel free to contact me with any questions. . . . =============================================================== THIS SOFTWARE IS PROVIDED "AS IS". MAKES NO REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS. My email address will be brill@blaze.cs.jhu.edu). =============================================================== About the README files (all of which can be found in the Docs/ directory): If you don't care how it works. Just want to use it as-is. See: aaai94-tagger.ps ================================================================ IMPORTANT: If you have retrieved this program via anonymous ftp. Please send me mail letting me know that you are using the tagger so I can keep you up to date on bug fixes. Etc. =============================================================== For a detailed description of the tagger (beyond what is contained in the README files).
4) My email address will be brill@blaze.cs.jhu.edu) Feel free to contact me with any questions. . . . ======================================================================== THIS SOFTWARE IS PROVIDED "AS IS". MAKES NO REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS. There are two stages in training: (1) Rules are learned to predict the most likely tag for unknown words. It is probably a past tense verb). If the outcome of applying these rules is that a word should be tagged with a particular tag. This holds for all occurrences of the word in the corpus. (2) Rules are learned to use contextual cues to improve tagging accuracy. (Example: change the tag of a word from verb to noun if the previous word is tagged as a determiner). So: John (I think) said: "Who are you?". He then gave me $10. would become: John ( I think ) said : " Who are you ? " He then gave me $ 10 .
5) My email address will be brill@blaze.cs.jhu.edu) Feel free to contact me with any questions. . . . =============================================================== THIS SOFTWARE IS PROVIDED "AS IS". MAKES NO REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS. Type (in the tagger base directory): make or first edit the Makefile to suit your needs. =============================================================== (If you have altered the file structure of the tagger after untarring the programs. Then you will have to adjust the instructions accordingly). Type: tagger LEXICON YOUR-CORPUS BIGRAMS LEXICALRULEFULE CONTEXTUALRULEFILE where YOUR-CORPUS is the file name of the corpus you wish to have tagged. The other files are all provided with the tagger. Options (which are typed after the file names) are: -h :: help -w wordlist :: provide an extra set of words beyond those in LEXICON.
6) This program was written by Eric Brill (brill@goldilocks.lcs.mit.edu) (After July 1 1994. My email address will be brill@blaze.cs.jhu.edu) Feel free to contact me with any questions. . . . =============================================================================== THIS SOFTWARE IS PROVIDED "AS IS". MAKES NO REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS. TRADEMARKS OR OTHER RIGHTS. ============================================================================= Please Read The COPYRIGHT file included with the tagger. ============================================================================= Code for training and tagging in n-best mode is provided with this release. This code is still under development. Is provided in prerelease form. In case anybody may have use for it. We will clean up this code. Text is passed through the start state tagger.
7) This program was written at the Department of Computer and Information Science. You might have to edit the make file for your machine. The executables will by default be placed in the "Bin" directory.
8) LAPIS is a lightweight structured text editing system. These instructions assume that you have Java 1.4 or later installed on your computer. Which is the only installation required. So all you have to do is run LAPIS. - The distribution is precompiled. The source code for LAPIS is included with the distribution in the file src.zip. LAPIS is written in Java. The generated source files and CUP runtime classes are included in the source distribution. LAPIS is free software. Redistribution is allowed under the terms of the GNU General Public License.
9) 
8
Waiting for Emacs...Done
Waiting for Emacs...Done
Waiting for Emacs...Done
Have you made all your edits?: y
dpkg-buildpackage -rfakeroot -uc -us
Execute this command?: y
dpkg-buildpackage: source package is lapis
dpkg-buildpackage: source version is 1.2-1
dpkg-buildpackage: source maintainer is Andrew J. Dougherty &amp;ajd@frdcsa.org>
dpkg-buildpackage: host architecture is i386
 fakeroot debian/rules clean
dh_testdir
dh_testroot
rm -f build-stamp configure-stamp
# Add here commands to clean up after the build process.
/usr/bin/make clean
make[1]: Entering directory `/var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2'
(find . | grep '~$' | xargs rm) || true
make[1]: Leaving directory `/var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2'
dh_clean 
 dpkg-source -b lapis-1.2
dpkg-source: building lapis in lapis_1.2.orig.tar.gz
dpkg-source: building lapis in lapis_1.2-1.diff.gz
dpkg-source: warning: file debian/dirs has no final newline (either original or modified version)
dpkg-source: building lapis in lapis_1.2-1.dsc
 debian/rules build
dh_testdir
# Add here commands to configure the package.
touch configure-stamp
dh_testdir
# Add here commands to compile the package.
/usr/bin/make
make[1]: Entering directory `/var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2'
make[1]: Nothing to be done for `configure'.
make[1]: Leaving directory `/var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2'
#/usr/bin/docbook-to-man debian/lapis.sgml > lapis.1
touch build-stamp
 fakeroot debian/rules binary
dh_testdir
dh_testroot
dh_clean -k 
dh_installdirs
# Add here commands to install the package into debian/lapis.
/usr/bin/make install DESTDIR=/var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2/debian/lapis
make[1]: Entering directory `/var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2'
# cp -ar /var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2/debian/lapis/etc
# cp -ar /var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2/debian/lapis/etc/cron.d
cp -ar bin/lapis /var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2/debian/lapis/usr/bin
cp -ar ChangeLog README index.html quickstart.html /var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2/debian/lapis/usr/share/doc/lapis
cp -ar lib legal parsers /var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2/debian/lapis/usr/share/lapis
# cp -ar /var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2/debian/lapis/var/lib/lapis
make[1]: Leaving directory `/var/lib/myfrdcsa/sandbox/lapis-1.2/lapis-1.2'
dh_testdir
dh_testroot
dh_installchangelogs ChangeLog
dh_installdocs
dh_installexamples
dh_installman
dh_link
dh_strip
dh_compress
dh_fixperms
dh_installdeb
dh_shlibdeps
dh_gencontrol
dpkg-gencontrol: warning: unknown substitution variable ${misc:Depends}
dh_md5sums
dh_builddeb
dpkg-deb: building package `lapis' in `../lapis_1.2-1_i386.deb'.
 dpkg-genchanges
dpkg-genchanges: including full source code in upload
dpkg-buildpackage: full upload (original source is included)
lintian -vi /var/lib/myfrdcsa/sandbox/lapis-1.2/lapis_1.2-1_i386.changes
Execute this command?: n
ln -s /var/lib/myfrdcsa/sandbox/lapis-1.2 /var/lib/myfrdcsa/packages/binary
Execute this command?: y
dput -f -c ~/.dput.cf -u local /var/lib/myfrdcsa/sandbox/lapis-1.2/lapis_1.2-1_i386.changes
Execute this command?: y
Successfully uploaded packages.
Not running dinstall.
</pre>
</para>
  </long-description>
</system>
