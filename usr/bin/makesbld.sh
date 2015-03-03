#!/bin/sh

# SlackBuild creator
# use cvs, svn, or perl as option
# Peter Hyman <pete@peterhyman.com>

SBVERSION=%%ver%%

die() {
	echo "$1"
	exit 1
}

echo "makesbld Creator: Peter Hyman 2006-2015 - Version: $SBVERSION" 

if [ $# -eq 1 ] ; then
	if [ "$1" = "cvs" -o "$1" = "CVS" ] ; then
		FTYPE=CVS
		SKELNAME=makesbld.cvs.skel
	elif [ "$1" = "svn" -o "$1" = "SVN" ] ; then
		FTYPE=SVN
		SKELNAME=makesbld.svn.skel
	elif [ "$1" = "perl" -o "$1" = "PERL" ] ; then
		FTYPE=PERL
		SKELNAME=makesbld.perl.skel
	else
		die "Invalid Option: makesb.sh [cvs|svn|perl]"
	fi
elif [ $# -gt 1 ] ; then
	die "Too many arguments: mahesb.sh [cvs|svn|perl]"
else	# regular handling
	SKELNAME=makesbld.skel
fi	

pname() {
	read -p "Enter Program Name: " PROGRAM
	PROGRAM="${PROGRAM/% /}"
}

pversion() {
	read -p "Enter Program Version #: " VERSION
	VERSION="${VERSION/% /}"
}

description() {
	read -p "Enter Description: " DESCRIPTION
	DESCRIPTION="${DESCRIPTION/% /}"
}

revision() {
	read -p "Enter Build Revision #: " REVISION
	REVISION="${REVISION/% /}"
}

mirror() {
	read -p "Enter Download Location: " MIRROR
	MIRROR="${MIRROR/% /}"
}

tarname() {
	read -p "Enter Tar Filename to download: " TAR_NAME
	TAR_NAME="${TAR_NAME/% /}"
}

cvspserver() {
	read -p "Enter CVS pserver: " CVS_PSERVER
	CVS_PSERVER="${CVS_PSERVER/% /}"
}

cvsmodule() {
	read -p "Enter CVS Module Name: " CVS_MODULE
	CVS_MODULE="${CVS_MODULE/% /}"
}	

svnserver() {
	read -p "Enter SVN Server: " SVN_SERVER
	SVN_SERVER="${SVN_SERVER/% /}"
}

svnmodule() {
	read -p "Enter SVN Module Name: " SVN_MODULE
	SVN_MODULE="${SVN_MODULE/% /}"
}	

requirements() {
	read -p "Enter Requirements: " REQUIREMENTS
	REQUIREMENTS="${REQUIREMENTS/% /}"
}

notes() {
	read -p "Enter Notes: " NOTES
	NOTES="${NOTES/% /}"
}

creator() {
	read -p "Your Name: " CREATOR
	CREATOR="${CREATOR/% /}"
}	

validate() {
	echo -e "\n\tReview your makesbld settings:\n \
\t---------------------------------\n" 
	if [ "$FTYPE" = "CVS" ] ; then
echo -e "\t1: PROGRAM NAME: $PROGRAM\n \
\t2: VERSION: $VERSION\n \
\t3: DESCRIPTION: $DESCRIPTION\n \
\t4: REVISION: $REVISION\n \
\t5: CVS PSERVER: $CVS_PSERVER\n \
\t6: CVS MODULE: $CVS_MODULE\n \
\t7: REQUIREMENTS: $REQUIREMENTS\n \
\t8: NOTES: $NOTES\n \
\t9: CREATOR: $CREATOR\n \
\tO: OK\n \
\tQ: QUIT\n \
\t----------\n\t"
	elif [ "$FTYPE" = "SVN" ] ; then
echo -e "\t1: PROGRAM NAME: $PROGRAM\n \
\t2: VERSION: $VERSION\n \
\t3: DESCRIPTION: $DESCRIPTION\n \
\t4: REVISION: $REVISION\n \
\t5: SVN SERVER: $SVN_SERVER\n \
\t6: SVN MODULE: $SVN_MODULE\n \
\t7: REQUIREMENTS: $REQUIREMENTS\n \
\t8: NOTES: $NOTES\n \
\t9: CREATOR: $CREATOR\n \
\tO: OK\n \
\tQ: QUIT\n \
\t----------\n\t"
	else
echo -e "\t1: PROGRAM NAME: $PROGRAM\n \
\t2: VERSION: $VERSION\n \
\t3: DESCRIPTION: $DESCRIPTION\n \
\t4: REVISION: $REVISION\n \
\t5: MIRROR: $MIRROR\n \
\t6: TARNAME: $TAR_NAME\n \
\t7: REQUIREMENTS: $REQUIREMENTS\n \
\t8: NOTES: $NOTES\n \
\t9: CREATOR: $CREATOR\n \
\tO: OK\n \
\tQ: QUIT\n \
\t----------\n\t"
	fi
	read -n1 -p "Type Selection: " CHOICE
}

# get program input and create a
# slackbuild file from it in 
# $SBDIR/prog/version

# uses ~/.makesbld if there
# will set SBDIR and maybe CREATOR
if [ -r $HOME/.makesbld/user.cfg ] ; then
	source $HOME/.makesbld/user.cfg
fi

if [ -z "$SBDIR" ] ; then	
	SBDIR=/tmp/makesbld	# SlackBuild default dir
fi

if [ -r $HOME/.makesbld/$SKELNAME ] ; then
	SKELDIR=$HOME/.makesbld
else
	SKELDIR=/usr/share/makesbld	# Defailt Skeleton File dir
fi

[ -r "$SKELDIR/$SKELNAME" ] || die "error: $SKELNAME file not found! $SKELDIR/$SKELNAME"

pname
pversion
description
revision
if [ "$FTYPE" = "CVS" ] ; then
	cvspserver
	cvsmodule
elif [ "$FTYPE" = "SVN" ] ; then
	svnserver
	svnmodule
else	
	mirror
	tarname
fi
requirements
notes
[ -z "$CREATOR" ] && creator

while [ 0 ]; do
	validate
	echo
	case "$CHOICE" in
	"1" ) pname;;
	"2" ) pversion;;
	"3" ) description;;
	"4" ) revision;;
	"5" ) 	if [ "$FTYPE" = "CVS" ] ; then 
			cvspserver
		elif [ "$FTYPE" = "SVN" ] ; then
			svnserver
		else
			mirror
		fi
		;;
	"6" ) 	if [ "$FTYPE" = "CVS" ] ; then
			cvsmodule
		elif [ "$FTYPE" = "SVN" ] ; then
			svnmodule
		else
			tarname	
		fi
		;;
	"7" ) requirements;;
	"8" ) notes;;
	"9" ) creator;;
	"o"|"O" ) break;;
	"q"|"Q" ) die "Quit Selected";;
	* ) echo ": Invalid option:"; continue;;
	esac
done

# shortcut
DESTDIR=$SBDIR/$PROGRAM/$VERSION

mkdir -p $DESTDIR || die "error: cannot make directory $DESTDIR"

cp $SKELDIR/$SKELNAME $DESTDIR/$PROGRAM.SlackBuild

# sed SlackBuild file
DATE=`date +%D`
sed -e 	"/^## Build/s%$%$PROGRAM%" \
	-e "s%^## Creator:%## Creator: $CREATOR%" \
	-e "s%^## Created by:%## Created by: makesbld Version: $SBVERSION%" \
	-e "s%^## Date:%## Date: $DATE%" \
	-e "s%^## Requirements:%## Requirements: $REQUIREMENTS%" \
	-e "s%^## Notes:%## Notes: $NOTES%" \
	-e "s%^NAME=%NAME=$PROGRAM%" \
	-e "s%^VERSION=%VERSION=$VERSION%" \
	-e "s%^REVISION=%REVISION=$REVISION%" \
	-e "s%^DESCRIPTION=%DESCRIPTION=\"$DESCRIPTION\"%" \
	-e "s%^MYIN=%MYIN=\"$MYIN\"%" \
	-e "s%^PKG_DIR=%PKG_DIR=\"$PKG_DIR\"%" \
	-e "s%^ARCH=%ARCH=\"$ARCH\"%" \
	-i $DESTDIR/$PROGRAM.SlackBuild
if [ "$FTYPE" = "CVS" ] ; then
	sed -e 	"s%^CVS_PSERVER=%CVS_PSERVER=$CVS_PSERVER%" \
	-e "s%^CVS_MODULE=%CVS_MODULE=$CVS_MODULE%" \
	-i $DESTDIR/$PROGRAM.SlackBuild
elif [ "$FTYPE" = "SVN" ] ; then
	sed -e 	"s%^SVN_SERVER=%SVN_SERVER=$SVN_SERVER%" \
	-e "s%^SVN_MODULE=%SVN_MODULE=$SVN_MODULE%" \
	-i $DESTDIR/$PROGRAM.SlackBuild
else
	sed -e 	"s%^SRC_LOC=%SRC_LOC=$MIRROR%" \
	-e "s%^TAR_NAME=.*$%TAR_NAME=$TAR_NAME%" \
	-i $DESTDIR/$PROGRAM.SlackBuild
fi
echo
echo "$PROGRAM.SlackBuild has been created in $DESTDIR"
echo "Please review the file carefully before use and edit as needed."
