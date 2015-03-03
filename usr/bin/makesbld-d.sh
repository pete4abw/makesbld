#!/bin/sh

# SlackBuild creator for use with dialog
# Peter Hyman <pete@peterhyman.com>

SBVERSION=%%ver%%

die() {
	echo "$1"
	exit 1
}

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

if [ "$FTYPE" = "CVS" ] ; then
	dialog --title "makesbld Creator" \
		--cr-wrap --form "Peter Hyman 2006-2015 - Version: $SBVERSION\n\
Build Directory: $SBDIR\n\
Complete variables to create your SlackBuild file" 18 60 9 \
	"Program Name:" 1 1 " " 1 15 30 30 \
	"Version:" 2 1 " " 2 15 20 20 \
	"Description:" 3 1 " " 3 15 40 40 \
	"Revision:" 4 1 " " 4 15 6 6 \
	"CVS pserver:" 5 1 " " 5 15 40 80 \
	"CVS Module:" 6 1 " " 6 15 40 60 \
	"Requirements:" 7 1 " " 7 15 40 40 \
	"Notes:" 8 1 " " 8 15 40 40 \
	"Creator:" 9 1 "$CREATOR " 9 15 30 20 \
	2> /tmp/makesbld.dialog
elif [ "$FTYPE" = "SVN" ] ; then
	dialog --title "makesbld Creator" \
		--cr-wrap --form "Peter Hyman 2006-2015 - Version: $SBVERSION\n\
Build Directory: $SBDIR\n\
Complete variables to create your SlackBuild file" 18 60 9 \
	"Program Name:" 1 1 " " 1 15 30 30 \
	"Version:" 2 1 " " 2 15 20 20 \
	"Description:" 3 1 " " 3 15 40 40 \
	"Revision:" 4 1 " " 4 15 6 6 \
	"SVN server:" 5 1 " " 5 15 40 80 \
	"SVN Module:" 6 1 " " 6 15 40 60 \
	"Requirements:" 7 1 " " 7 15 40 40 \
	"Notes:" 8 1 " " 8 15 40 40 \
	"Creator:" 9 1 "$CREATOR " 9 15 30 20 \
	2> /tmp/makesbld.dialog
else	
	dialog --title "makesbld Creator" \
		--cr-wrap --form "Peter Hyman 2006-2015 - Version: $SBVERSION\n\
Build Directory: $SBDIR\n\
Complete variables to create your SlackBuild file" 18 60 9 \
	"Program Name:" 1 1 " " 1 15 30 30 \
	"Version:" 2 1 " " 2 15 20 20 \
	"Description:" 3 1 " " 3 15 40 40 \
	"Revision:" 4 1 " " 4 15 6 6 \
	"Mirror:" 5 1 " " 5 15 40 80 \
	"Tar Name:" 6 1 " " 6 15 40 60 \
	"Requirements:" 7 1 " " 7 15 40 40 \
	"Notes:" 8 1 " " 8 15 40 40 \
	"Creator:" 9 1 "$CREATOR " 9 15 30 20 \
	2> /tmp/makesbld.dialog
fi

[ $? -eq 1 -o $? -eq 255 ] && die "makesbd.sh was cancelled"

dialog --clear

# read in data
i=0
SAVEIFS=$IFS
# make newline field separator
IFS=$'\xA'
for TMPVAR in $(</tmp/makesbld.dialog)
do
	# remove trailing whitespace if any
	TMPVAR="${TMPVAR/% /}"
	let i=$i+1
	case $i in
		1) PROGRAM=$TMPVAR;;
		2) VERSION=$TMPVAR;;
		3) DESCRIPTION=$TMPVAR;;
		4) REVISION=$TMPVAR;;
		5)	if [ "$FTYPE" = "CVS" ] ; then
				CVS_PSERVER=$TMPVAR
			elif [ "$FTYPE" = "SVN" ] ; then
				SVN_SERVER=$TMPVAR
			else
				MIRROR=$TMPVAR
			fi
			;;
		6)	if [ "$FTYPE" = "CVS" ] ; then
				CVS_MODULE=$TMPVAR
			elif [ "$FTYPE" = "SVN" ] ; then
				SVN_MODULE=$TMPVAR
			else
				TAR_NAME=$TMPVAR
			fi
			;;
		7) REQUIREMENTS=$TMPVAR;;
		8) NOTES=$TMPVAR;;
		9) CREATOR=$TMPVAR;;
	esac
done
IFS=$SAVEIFS

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
	sed -e 	"s~^SRC_LOC=~SRC_LOC=\"$MIRROR\"~" \
	-e "s%^TAR_NAME=.*$%TAR_NAME=$TAR_NAME%" \
	-i $DESTDIR/$PROGRAM.SlackBuild
fi

dialog --title "makesbld Creator Completed" \
	--msgbox "A SlackBuild file for $PROGRAM-$VERSION \
has been created in: $DESTDIR. \
Please review it carefully and edit as needed." 8 60
