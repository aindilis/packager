#!/bin/csh -f

#######################################################################
##                                                                   ##
## Paths relevant to Alembic Workbench corpus development tool, and  ##
## its associated utilities.  See the file README for details on     ##
## this tool, copyright specifics, and how to install the system.    ##
## Source this file prior to executing the Alembic Workbench.        ##
##                                                                   ##
#######################################################################

     #########################################################
     #                                                       #
     #                 Alembic Workbench                     #
     #     Copyright (c) 1996-1998, The MITRE Corporation    #
     #   See COPYRIGHT.tcl for details on license agreement  #
     #        Contact: Dr. David Day, day@mitre.org,         #
     #                  (781) 271-2854                       #
     #                                                       #
     #########################################################


#######################################################
## Change = installation-directory = below to be the ##
## path created by the installer specifically for    ##
## the Alembic Workbench.  Change = version = below  ##
## to point to be the <n.m> pattern indicating the   ##
## version of the Workbench being installed.         ##
#######################################################

setenv AWB              /var/lib/awb
setenv PREDAWB          /var/lib/myfrdcsa/codebases/internal/packager/IE/awb
setenv AWB_REL_DIR      $AWB/awb-4.40
setenv AWB_GUI_DIR      $AWB_REL_DIR/gui
setenv AWB_SCRIPTS_DIR  $AWB_REL_DIR/tools/scripts
setenv AWB_LITE         0

#######################################################
## Preprocess location, if it has been installed.    ##
#######################################################

if ($?ALEM) then
    ## don't do anything
else
    setenv ALEM          $AWB/alembic
endif

setenv ALEM_PP_DIR       $AWB/preprocess
setenv ALEM_PP_SCRIPTS   $AWB/preprocess/bin/scripts

#######################################################
## Read/Write data & declaration variables           ##
#######################################################

setenv TAGSETDEF        $PREDAWB/tagsetdefs/packager.tsd
setenv TAGSETDEF_DIR    $PREDAWB/tagsetdefs
setenv AWB_DTD          $PREDAWB/dtds/packager.h.text

#######################################################
## OS dependent environment variables                ##
#######################################################

#######################################################
##                                                   ##
## NOTE to installer:  The present version of Alembic##
## Workbench has been built and tested using Tcl 7.4 ##
## and Tk 4.0.  These versions of Tcl/Tk have been   ##
## delivered along with the Workbench, and by default##
## are used in running the Workbench.  If you wish   ##
## to integrate the Workbench with an installed ver- ##
## sion of Tcl/Tk that is compatible, *and* you have ##
## installed a version of the Workbench that includes##
## the .tcl source code (and not a "p-compiled"      ##
## version in which only .ptcl files are available   ##
## in the gui subdirectory) you may do so by setting ##
## the following environment variables appropriately:##
##                                                   ##
##     AWB_TCL_DIR  Should point to directory in     ##
##                  which the tclsh and wish         ##
##                  binaries can be found.           ##
##     TK_LIBRARY   Should point to appropriate      ##
##     TCL_LIBRARY  libraries for Tk and Tcl.        ##
##                                                   ##
## If the versions are compatible and the Workbench  ##
## runs without any problems, you could save some    ##
## space by deleting the subdirectories below.       ##
## (But don't don't delete them until confirming     ##
## that the default Tcl/Tk installation is indeed    ##
## compatible with Alembic Workbench.)               ##
##                                                   ##
##     $AWB_REL_DIR/TclTk-4.1.3 and                  ##
##     $AWB_REL_DIR/TclTk-5.4                        ##
##                                                   ##
#######################################################

if (`uname -s` == SunOS) then
    if ((`uname -r` == 4.1.3) || (`uname -r` == 4.1.4) || (`uname -r` == 4.1.3_U1)) then
	## echo "Performing install for Sun OS 4.1.3 ... "
	setenv AWB_OS                  "sunos"
	setenv AWB_TCL_DIR             $AWB_REL_DIR/TclTk/sunos
	setenv AWB_WISH_DIR            $AWB_REL_DIR/TclTk/sunos
	setenv WISHNAME                wish80
	setenv TCLNAME                 tclsh80
	setenv TK_LIBRARY              $AWB_WISH_DIR/tklib8.0
	setenv TCL_LIBRARY             $AWB_TCL_DIR/tcllib8.0
	setenv AWB_BIN_DIR             $AWB_REL_DIR/tools/bin/sunos
	setenv ALEM_PP_BIN             $AWB/preprocess/bin/sunos
	setenv AWB_LISP_IMAGE          $AWB_REL_DIR/image/sunos/bin/alcl-rt
	## echo "   ... using $AWB_TCL_DIR/$TCLNAME ..."
    else
	## echo "Performing install for Solaris (2.4+, SunOS 5.4+)"
	setenv AWB_OS                  "solaris"
	setenv AWB_TCL_DIR             $AWB_REL_DIR/TclTk/solaris
	setenv AWB_WISH_DIR            $AWB_REL_DIR/TclTk/solaris
	setenv WISHNAME                wish81
	setenv TCLNAME                 tclsh81
	setenv TK_LIBRARY              $AWB_WISH_DIR/tklib8.1
	setenv TCL_LIBRARY             $AWB_TCL_DIR/tcllib8.1
	setenv AWB_BIN_DIR             $AWB_REL_DIR/tools/bin/solaris
	setenv ALEM_PP_BIN             $AWB/preprocess/bin/solaris
	setenv AWB_LISP_IMAGE          $AWB_REL_DIR/image/solaris/alembic-applic/alembic-applic
	## echo "   ... using $AWB_TCL_DIR/$TCLNAME"
    endif
else if (`uname -s` == Linux) then
    ## echo "Performing install for Linux ..."
    setenv AWB_OS                  "linux"
    setenv AWB_TCL_DIR             $AWB_REL_DIR/TclTk/linux
    setenv AWB_WISH_DIR            $AWB_REL_DIR/TclTk/linux
    setenv WISHNAME                wish81
    setenv TCLNAME                 tclsh81
    setenv TK_LIBRARY              $AWB_WISH_DIR/tklib8.1
    setenv TCL_LIBRARY             $AWB_TCL_DIR/tcllib8.1
    setenv AWB_BIN_DIR             $AWB_REL_DIR/tools/bin/linux
    setenv ALEM_PP_BIN             $AWB/preprocess/bin/linux
    setenv AWB_LISP_IMAGE          $AWB_REL_DIR/image/linux/alembic-applic/alembic-applic
    ## echo "   ... using $AWB_TCL_DIR/$TCLNAME"
endif

##########################################################
## Defining SPECPATH for use by C-based spec processing ##
##########################################################

setenv SPECPATH $ALEM_PP_DIR/specs

#######################################################
## Updating path to include awb and tools            ##
#######################################################

set path = ( $AWB_SCRIPTS_DIR  \
	     $AWB_BIN_DIR      \
             $path             \
 	     $ALEM_PP_SCRIPTS  \
 	     $ALEM_PP_BIN )
            
## Previous version:
## set path = ( $AWB_GUI_DIR     \
## 	     $AWB_SCRIPTS_DIR \
## 	     $AWB_BIN_DIR     \
## 	     $AWB_TCL_DIR     \
## 	     $AWB_WISH_DIR    \
##           $path            \
## 	     $ALEM_PP_SCRIPTS \
## 	     $ALEM_PP_BIN )
##             

#######################################################
##       Add fonts for foreign languages             ##
##                                                   ##
## The code below provides a model of how to add     ##
## font paths to your X-windows environment for      ##
## handling various foreign character fonts. You may ##
## need to specify different paths for fonts not     ##
## included with the full Workbench distribution.    ##
#######################################################

##if ($?DISPLAY) then
##     xset +fp $AWB/unicode
##     xset fp rehash
##endif


#######################################################
## Development directories for use within MITRE      ##
#######################################################

setenv AWBCVS     /afs/rcf/project/AlembicWorkbench

