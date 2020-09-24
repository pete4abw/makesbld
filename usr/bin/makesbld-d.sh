#!/bin/sh

# SlackBuild creator for use with dialog
# Peter Hyman <pete@peterhyman.com>

SBVERSION=%%ver%%
COPYRIGHTDATE=%%date%%

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
	elif [ "$1" = "git" -o "$1" = "GIT" ] ; then
		FTYPE=GIT
		SKELNAME=makesbld.git.skel
	else
		die "Invalid Option: $1. Use $0 [cvs|svn|perl|git]"
	fi
elif [ $# -gt 1 ] ; then
	die "Too many arguments: $*. Use $0 [cvs|svn|perl|git]"
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
		--cr-wrap --form "Peter Hyman $COPYRIGHTDATE - Version: $SBVERSION\n\
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
		--cr-wrap --form "Peter Hyman $COPYRIGHTDATE - Version: $SBVERSION\n\
Build Directory: $SBDIR\n\
Complete variables to create your SlackBuild file" 18 60 9 \
	"Program Name:" 1 1 " " 1 15 30 30 \
	"Version:" 2 1 " " 2 15 20 20 \
	"Description:" 3 1 " " 3 15 40 40 \
	"Revision:" 4 1 " " 4 15 6 6 \
	"SVN Server:" 5 1 " " 5 15 40 80 \
	"SVN Module:" 6 1 " " 6 15 40 60 \
	"Requirements:" 7 1 " " 7 15 40 40 \
	"Notes:" 8 1 " " 8 15 40 40 \
	"Creator:" 9 1 "$CREATOR " 9 15 30 20 \
	2> /tmp/makesbld.dialog
elif [ "$FTYPE" = "GIT" ] ; then
	dialog --title "makesbld Creator" \
		--cr-wrap --form "Peter Hyman $COPYRIGHTDATE - Version: $SBVERSION\n\
Build Directory: $SBDIR\n\
Complete variables to create your SlackBuild file" 18 60 10 \
	"Program Name:" 1 1 " " 1 15 30 30 \
	"Version:" 2 1 " " 2 15 20 20 \
	"Description:" 3 1 " " 3 15 40 40 \
	"Revision:" 4 1 " " 4 15 6 6 \
	"GIT Server:" 5 1 " " 5 15 40 80 \
	"GIT Name:" 6 1 " " 6 15 40 60 \
	"GIT Options:" 7 1 " " 7 15 40 40 \
	"Requirements:" 8 1 " " 8 15 40 40 \
	"Notes:" 9 1 " " 9 15 40 40 \
	"Creator:" 10 1 "$CREATOR " 10 15 30 20 \
	2> /tmp/makesbld.dialog
else	
	dialog --title "makesbld Creator" \
		--cr-wrap --form "Peter Hyman $COPYRIGHTDATE - Version: $SBVERSION\n\
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
			elif [ "$FTYPE" = "GIT" ] ; then
				GIT_SERVER=$TMPVAR
			else
				MIRROR=$TMPVAR
			fi
			;;
		6)	if [ "$FTYPE" = "CVS" ] ; then
				CVS_MODULE=$TMPVAR
			elif [ "$FTYPE" = "SVN" ] ; then
				SVN_MODULE=$TMPVAR
			elif [ "$FTYPE" = "GIT" ] ; then
				GIT_NAME=$TMPVAR
			else
				TAR_NAME=$TMPVAR
			fi
			;;
		7) 	if [ "$FTYPE" = "GIT" ] ; then
				GIT_OPTIONS=$TMPVAR
			else
				REQUIREMENTS=$TMPVAR
			fi
			;;
		8)	if [ "$FTYPE" = "GIT" ] ; then
				REQUIREMENTS=$TMPVAR
			else
				NOTES=$TMPVAR
			fi
			;;
		9)	if [ "$FTYPE" = "GIT" ] ; then
				NOTES=$TMPVAR
			else
				CREATOR=$TMPVAR
			fi
			;;
		10)	if [ "$FTYPE" = "GIT" ] ; then
				CREATOR=$TMPVAR
			fi
			;;
	esac
done
IFS=$SAVEIFS

# shortcut
DESTDIR=$SBDIR/$PROGRAM/$VERSION

mkdir -p $DESTDIR || die "error: cannot make directory $DESTDIR"

cp $SKELDIR/$SKELNAME $DESTDIR/$PROGRAM.SlackBuild

# sed SlackBuild file
DATE=`date +%D`
sed 	-e "/^## Build/s%$%$PROGRAM%" \
	-e "/^## Creator:/s%$%$CREATOR%" \
	-e "/^## Created by:/s%$%makesbld Version: $SBVERSION%" \
	-e "/^## Date:/s%$%$DATE%" \
	-e "/^## Requirements:/s%$%$REQUIREMENTS%" \
	-e "/^## Notes:/s%$%$NOTES%" \
	-e "/^NAME=/s%$%$PROGRAM%" \
	-e "/^VERSION=/s%$%\$\{VERSION:-$VERSION\}%" \
	-e "/^REVISION=/s%$%\$\{REVISION:-$REVISION\}%" \
	-e "/^DESCRIPTION=/s%$%\"$DESCRIPTION\"%" \
	-e "/^REQ=/s%$%\'$REQUIREMENTS\'%" \
	-e "/^MYIN=/s%$%\"$MYIN\"%" \
	-e "/^PKG_DIR=/s%$%\$\{PKG_DIR:-\"$PKG_DIR\"\}%" \
	-e "/^ARCH=/s%$%\"$ARCH\"%" \
	-e "/^MAKEOPTS=/s%$%\"$MAKEOPTS\"%" \
	-i $DESTDIR/$PROGRAM.SlackBuild
if [ "$FTYPE" = "CVS" ] ; then
	sed -e 	"/^CVS_PSERVER=/s%$%$CVS_PSERVER%" \
	-e "/^CVS_MODULE=/s%$%$CVS_MODULE%" \
	-i $DESTDIR/$PROGRAM.SlackBuild
elif [ "$FTYPE" = "SVN" ] ; then
	sed -e 	"/^SVN_SERVER=/s%$%$SVN_SERVER%" \
	-e "/^SVN_MODULE=/s%$%$SVN_MODULE%" \
	-i $DESTDIR/$PROGRAM.SlackBuild
elif [ "$FTYPE" = "GIT" ] ; then
	sed -e 	"/^GIT_SERVER=/s%$%$GIT_SERVER%" \
	-e "/^GIT_NAME=/s%$%$GIT_NAME%" \
	-e "/^GIT_OPTIONS=/s%$%\"$GIT_OPTIONS\"%" \
	-i $DESTDIR/$PROGRAM.SlackBuild
else
	sed -e 	"/^SRC_LOC=/s%$%\"$MIRROR\"%" \
	-e "/^TAR_NAME=/s%=.*$%=$TAR_NAME%" \
	-i $DESTDIR/$PROGRAM.SlackBuild
fi

dialog --title "makesbld Creator Completed" \
	--msgbox "A SlackBuild file for $PROGRAM-$VERSION \
has been created in: $DESTDIR. \
Please review it carefully and edit as needed." 8 60
