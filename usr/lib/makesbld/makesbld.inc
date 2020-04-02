# makesbld.inc
# contains reusable code
# Version: %%ver%%
# %%date%%
# Peter Hyman <pete@peterhyman.com>

# Call this to make sure bin and sbin are the correct groups
bin_perms() {
	local DIRECTORY
	for DIRECTORY in bin sbin usr/bin usr/sbin usr/local/bin usr/local/sbin \
		usr/X11R6/bin opt/kde/bin; do
		if [ -d $PKG/$DIRECTORY ]; then
			chown -R root:root $PKG/$DIRECTORY
			chmod -R 755 $PKG/$DIRECTORY
		fi
	done
} 

# check for required packages
# arguments must be quoted and version options not required
# $REQ holds argument
# ex: REQ='pkg1 pkg2 >|>=|=|<=|< ver ...'
# versions must be separated by spaces
# $PC and $PC_OPTIONS may be overridden in conf file
check_req_pkg() {
	# nothing to do if $REQ is 0
	[ ${#REQ} -eq 0  ] && return
        echo "Checking for package(s): $REQ"
        $PC $PC_OPTIONS $REQ
        [ $? -ne 0 ] && die "error: required package(s) not found"
}

# the cleanup function is for removing the SRC and PKG directories
# it can be called from the command line or placed explicitly into
# a slackbuild file
cleanup() {
	[ ${#PKG} -eq 0 ] && die "error: cleanup: no package directory!"
	[ ${#SRC} -eq 0 ] && die "error: cleanup: no source directory!"
	# bye
	rm -fr $PKG $SRC
}

# automatically place common document files into $DOCDIR
# need to be in $SRC to locate files
create_docs () {
	local i
	[ -z "$DOCDIR" ] && die "error: create_docs: DOCDIR not defined"
	mkdir -p ${DOCDIR}
	cd $SRC
	for i in ${DOCFILES}; do
		if [ -d "${i}" ]; then
			# don't copy over doc or docs directory [ case sensitive ]
			if [ "${i:0:3}" != "doc" ]; then
				cp -Rp "${i}" ${DOCDIR}
			fi
		elif [ -e "${i}" ]; then
			if [ ! -L "${i}" ]; then
 				cp -a "${i}" ${DOCDIR}
				cp -LRp "${i}" ${DOCDIR}
			fi
		fi
	done
}

#die function. Call with message to force exit
die() {
	echo "** Abnormal exit **"
	echo "$1"
	exit 1
}

# do functions. Will install given file(s) into standard directories
# pass with SYS in first parameter fo place in /bin instead of /usr/bin
# pass with files/directories in $1
# thanks to Gentoo for idea

dobin() {
	local BINDIR
	[ $# -eq 0 ] && die "error: dobin: not enough arguments"
	if [ "$1" = "SYS" ] ; then
		BINDIR=$PKG/bin
		shift
	else
		BINDIR=$PKG/usr/bin
	fi
	doins $BINDIR $@
}

# adhoc move something to document directory
dodoc() {
	[ $# -eq 0 ] && die "error: dodoc: not enough arguments"
	[ -z "$DOCDIR" ] && die "error: dodoc: DOCDIR not defined"
	doins $DOCDIR $@
}

# install any files to $PKG/etc
# -d DIR as first argument will create subdirectory under etc
# other files will be copied to /etc or /etc/DIR
doetc()
{
	local ETCDIR
	[ $# -eq 0 ] && die "error: doetc: not enough arguments"
	if [ "$1" = "-d" ] ; then
		[ $# -lt 3 ] && die "error: doetc: -d not followed by enough arguments"
		shift
		ETCDIR=$PKG/etc/$1
		shift
	else
		ETCDIR=$PKG/etc
	fi
	doins $ETCDIR $@
}

# install files and mark executable
doexe() {
	local pkglen INSDIR
	[ $# -lt 2 ] && die "error: doexe: not enough arguments"
	doins $@
	pkglen=${#PKG}
	if [ "${1:0:$pkglen}" = "$PKG" ] ; then
		INSDIR=$1
	else
		INSDIR=$PKG/$1
	fi
	chmod -R 0755 $INSDIR
}

# install icons
doicon() {
	local ICONDIR
	[ $# -eq 0 ] && die "error: doicon: not enough arguments"
	ICONDIR=$PKG/usr/share/pixmaps
	doins $ICONDIR $@
}

# insert file(s) to a directory
# arg 1 is directory, arg2-n are files or directories
# $PKG is implied and not required
doins() {
	local DEST pkglen
	[ $# -lt 2 ] && die "error: doins: not enough arguments"
	# see if $PKG was passed
	pkglen=${#PKG}
	[ $pkglen -eq 0 ] && die "error: doins: $PKG not defined???"
	if [ "${1:0:$pkglen}" = "$PKG" ] ; then
		DEST=$1
	else
		DEST=$PKG/$1
	fi
	if [ ! -d $DEST ]; then
		mkdir -p $DEST
	fi
	# skip to files, must shift
	shift
	for i in "$@"; do
		cp -a $i $DEST
	done
}

# adhoc move something to man directory
doman() {
	local MANDIRBASE MANDIR
	[ $# -eq 0 ] && die "error: doman: not enough arguments"
	MANDIRBASE=$PKG/usr/man
	for i in "$@"; do
		# get man page suffix and make dir if required
		MANDIR=man${i: -1}
		doins $MANDIRBASE/$MANDIR $i
	done
}

# install menus
domenu() {
	local APPDIR
	[ $# -eq 0 ] && die "error: domenu: not enough arguments"
	APPDIR=$PKG/usr/share/applications
	doins $APPDIR $@
}

# move rc script to /etc/rc.d
# if first arg is NOEXE then won't be executable
dorc() {
	local RCDIR NOEXE
	[ $# -eq 0 ] && die "error: dorc: not enough arguments"
	if [ "$1" = "NOEXE" ] ; then
		NOEXE=yes
		shift
	else
		NOEXE=
	fi
	RCDIR=$PKG/etc/rc.d
	doins $RCDIR $@
	# make executable!
	if [ -z "$NOEXE" ] ; then
		chmod -R 0755 $RCDIR
	fi
}

# pass "SYS" in first parameter to install to /sbin instead of /usr/sbin
dosbin() {
	local SBINDIR
	[ $# -eq 0 ] && die "error: dosbin: not enough arguments"
	if [ "$1" = "SYS" ] ; then
		SBINDIR=$PKG/sbin
		shift
	else
		SBINDIR=$PKG/usr/sbin
	fi
	doins $SBINDIR $@
}

# install files in package share dir
doshare() {
	local SHAREDIR
	[ $# -eq 0 ] && die "error: doshare: not enough arguments"
	SHAREDIR=$PKG/usr/share/$NAME
	doins $SHAREDIR $@
}

# double_check_user - make sure all is root:root
# use in case files are copied from somewhere out of the
# source tree
double_check_user() {
	find $PKG ! -user root -print0 | xargs -0r chown root:root
	find $PKG ! -group root -print0 | xargs -0r chown root:root
}

# etc2new
# rename all files in etc to file.new
etc2new() {
	local i
	# only do if there's an etc dir
	[ ! -d $PKG/etc ] && return
	for i in $(find $PKG/etc -type f)
	do
		# skip if already a new extension
		[ "${i: -4}" = ".new" ] && continue
		mv $i $i.new
	done
}

#   WGET - wget program
#   CWD SlackBuild home dir
#   TAR_NAME - filename to fetch
#   WGET_OPTIONS - standard wget options
#   SRC_LOC - download location
fetch() {
	if [ -a "$CWD/$TAR_NAME" ]; then
		echo "Source present not downloading"
	else
		$WGET $WGET_OPTIONS "$SRC_LOC/$TAR_NAME" || die "error: wget" 
	fi
}

#   CVS - cvs program
#   CVS_PSERVER -- pserver for getting sources
#   CVS_MODULE  -- module to cvs and default directory
#   CVS_OPTIONS -- standard options
fetch_cvs() {
	# call cvs here
	cd $TMP
	$CVS -d$CVS_PSERVER login
	$CVS $CVS_OPTIONS -d$CVS_PSERVER co $CVS_MODULE || die "error: cvs'ing"
}

#   SVN = svn program
#   SVN_OPTIONS = checkout options (notmally just co)
#   SVN_SERVER = path to trunk
#   SVN_MODULE = module to fetch
fetch_svn() {
	# call svn here
	cd $TMP
	$SVN $SVN_OPTIONS $SVN_SERVER/$SVN_MODULE || die "error: svn"
}

#   GIT = git program
#   GIT_COMMAND = clone by default
#   GIT_OPTIONS = options, e.g. -b branch
#   GIT_SERVER = git server location
#   GIT_NAME = git filename
fetch_git() {
	# clone git from TMP directory
	cd $TMP
	$GIT $GIT_COMMAND $GIT_OPTIONS $GIT_SERVER/$GIT_NAME
}

fix_source() {
	chown -R root:root $SRC
	find $SRC -type f -perm /0111 -print0 | xargs -0r chmod -- 755
	find $SRC -type f ! -perm /0111 -print0 | xargs -0r chmod -- 644
}

# check to see if only one function is requested
# right now only allow one arg

# get_args (pass command line arguments)
get_args() {
	if [ $# -eq 1 ]; then
		case "$1" in
		"setup")
			pkg_setup
			;;
		"fetch")
			pkg_setup
			local_fetch
			;;
		"unpack")
			pkg_setup
			local_unpack
			;;
		"fix_source" | "fix")
			local_fix_source
			;;
		"patch")
			patch
			;;
		"check" | "check_req_pkg")
			local_check_req_pkg
			;;
		"compile")
			compile
			;;
		"install")
			install
			;;
		"description" | "desc")
			make_slack_desc	
			;;
		"doinst")
			make_doinst
			;;
		"build" | "build_pkg")
			build_pkg
			;;
		"cleanup")
			cleanup
			;;
		"-help" | "-h" | "--help" | "usage")
			usage
			;;
		*)
			usage
			die "usage: invalid option: $1, specified"
			;;
		esac
		echo -e "\n*** $1 completed ***"
		exit 0
	elif [ $# -gt 1 ] ; then
		usage
		die "command line: error: only one argument allowed: $*"
	else
		return
	fi	
}

# Make some generic funtions for cleaning stipping and permissions

# Call this to gzip documents in the standard doc area
# Call with $1 set to NOR to set no recurse
# $DOCDIR is set in the SlackBuild file.

gzip_docs() {
	gzip_misc $DOCDIR $1
}

# Call this to zip up the info documents
gzip_info() {
	gzip_misc $PKG/usr/info
}

# Call this to zip up the man directories
# redo symlinks after gzipping, if any
# thanks Lasse Collin
gzip_man() {
	local i j
	gzip_misc $PKG/usr/man
	for i in $(find "$PKG/usr/man" -mindepth 2 -type l ! -name '*.gz')
	do
		j=$(readlink "$i")
		rm -f "$i"
		ln -sf "$j.gz" "$i.gz"
	done
}

# Call this function to zip BOTH man and info pages
gzip_man_info() {
	gzip_man
	gzip_info
}

# Call this to gzip documents or other files in $1
# Call with $2 set to NOR to set no recurse
gzip_misc() {
	[ $# -eq 0 ] && die "gzip_misc: must have directory to zip"
	if [ "$2" = "NOR" ]; then
		gzip -9q $1/*
	else
		find $1 -type f -print0 | xargs -0r gzip -9q
	fi
}

# pkg_setup function. Makes TMP and clears PKG and SRC Directories
pkg_setup() {
	rm -rf $PKG $SRC
	for i in $TMP $SRC $PKG
	do
		if [ ! -d $i ]; then
			mkdir -p $i
		fi
	done
}


# spatch function
# determines patch file type and try and patch using -p{0,1,2,3,4,5}
# current dir is patch dir.

spatch() {
	local f p
	[ $# -eq 0 ] && die "spatch: requires one or more filenames"

	# make sure needed programs are available
	PATCH=`which patch 2>/dev/null`
	ZCAT=`which zcat 2>/dev/null`
	BZCAT=`which bzcat 2>/dev/null`
	XZCAT=`which xzcat 2>/dev/null`
	[ -n "$PATCH" ] || die "spatch: patch program not found"
	[ -n "$ZCAT" ]  || die "spatch: zcat program not found"
	[ -n "$BZCAT" ] || die "spatch: bzcat program not found"
	[ -n "$XZCAT" ] || die "spatch: xzcat program not found"

	# $@ contains one or more filenames. Can be gzipped or bzipped or xzzipped or plain
	for f in $@
	do
		# file is readable?
		[ -r $f ] || die "spatch: file $f not found or cannot be read"
		# determine filetype
		if [ "${f: -2}" = "gz" ] ; then
			CAT=$ZCAT
		elif [ "${f: -2}" = "xz" ] ; then
			CAT=$XZCAT
		elif [ "${f: -3}" = "bz2" ] ; then
			CAT=$BZCAT
		else
			CAT=cat
		fi
		# now loop for all patch levels
		echo -n "patching $f....."
		for p in 0 1 2 3 4 5
		do
			$CAT $f | $PATCH -p$p >/dev/null 2>&1
			[ "$?" -eq 0 ] && break
		done
		# oops, had a problem
		if [ ! "$?" -eq 0 ] ; then
			echo "[FAILURE]"
			die "spatch: cannot patch file $f"
		fi
		echo "[OK]"
	done
}

# Call this function to strip everything
strip_all() {
	strip_bin
	strip_lib
	strip_static
}

# Call this in the script to remove debug and junk
strip_bin() {
	find $PKG | xargs file | grep "executable" | grep ELF | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null
}

# Call this in the script to strip libs
strip_lib() {
	find $PKG | xargs file | grep "shared object" | grep ELF | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null
}

# Call this in the script to strip static libs
strip_static() {
	find $PKG | xargs file | grep "current ar archive" | cut -f 1 -d : | xargs strip --strip-debug 2> /dev/null
}

# unpack -- determine filetype and extract 
# call with full path name of file to extract in $1
unpack() {
	if [ "${1: -4}" = ".bz2" ] ; then
		TAR_TYPE=bzip2
	elif [ "${1: -3}" = ".gz" ] ; then
		TAR_TYPE=gzip
	elif [ "${1: -4}" = ".tar" ] ; then
		TAR_TYPE=TAR
	elif [ "${1: -8}" = ".src.rpm" ] ; then
		TAR_TYPE=SRPM
	elif [ "${1: -4}" = ".rpm" ] ; then
		TAR_TYPE=RPM
	elif [ "${1: -4}" = ".zip" ] ; then
		TAR_TYPE=ZIP
	elif [ "${1: -2}" = ".z" ] ; then
		TAR_TYPE=compress
	elif [ "${1: -3}" = ".xz" -o "${1: -4}" = ".txz" ] ; then 
		TAR_TYPE=xz
	elif [ "${1: -3}" = ".lz" ] ; then
		TAR_TYPE=lzip
	elif [ "${1: -5}" = ".lzma" ] ; then
		TAR_TYPE=lzma
	fi
	TEMPNAME=$1
	# set up for RPM
	if [ "$TAR_TYPE" = "RPM" -o "$TAR_TYPE" = "SRPM" ] ; then
		TEMPNAME=$CWD/$(basename $TEMPNAME .rpm).tar.gz
		TAR_TYPE=gzip
		# do in download dir
		( cd $CWD
			[ -e "$TEMPNAME" ] && rm "$TEMPNAME"
			rpm2targz "$1" || die "error: rpm2targz error"
		)
	fi
	if [ "$TAR_TYPE" = "ZIP" ] ; then
		unzip "${TEMPNAME}" || die "error: unzip extract"
	elif [ "$TAR_TYPE" = "TAR" ] ; then
		tar -xvf "${TEMPNAME}" || die "error: tar extract"
	else
		tar --"${TAR_TYPE}" -xvf "${TEMPNAME}" || die "error: tar --$TAR_TYPE extract"
	fi

}

usage() {
	echo "$NAME.SlackBuild usage"
	echo "----------------------------------------------------------------------"
	echo "with none or one of these options"
	echo "  setup           - execute pkg_setup function"
	echo "  fetch           - download source tarball or cvs module"
	echo "  unpack          - unpack tarball"
	echo "  fix[_source]    - fix perms of Source directory"
	echo "  patch           - patch source files"
	echo "  check[_req_pkg] - check required packages and versions exist"
	echo "  compile         - compile source"
	echo "  install         - run make install and prepare sources for package build"
	echo "  desc[ription]   - create slack-desc file and any others needed"
	echo "  doinst          - create doinst.sh file"
	echo "  build[_pkg]     - make package"
	echo -e "\nVariables used:"
	echo      "---------------"
	echo "NAME              - $NAME"
	echo "VERSION           - $VERSION"
	echo "REVISION          - $REVISION"
	echo "REQUIRED PACKAGES - $REQ"
	echo "BUILD             - $BUILD"
	echo "DESCRIPTION       - $DESCRIPTION"
	echo "DOCDIR            - $DOCDIR"
	echo "SHAREDIR          - $SHAREDIR"
	echo "SRC_LOC           - $SRC_LOC"
	echo "SRC_NAME          - $SRC_NAME"
	echo "SRC_EXTRACT_DIR   - $SRC_EXTRACT_DIR"
	echo "TAR_NAME          - $TAR_NAME"
	echo "SRC               - $SRC"
	echo "PKG               - $PKG"
	echo "PKG_DIR           - $PKG_DIR"
	echo "PKG_NAME          - $PKG_NAME"
	echo "TMP               - $TMP"
	if [ -n "$CVS_PSERVER" ] ; then
		echo -e "\nCVS Variables used:"
		echo      "-------------------"
		echo "CVS_PSERVER - $CVS_PSERVER"
		echo "CVS_MODULE  - $CVS_MODULE"
	        echo "CVS         - $CVS | options $CVS_OPTIONS"
	elif [ -n "$SVN_SERVER" ] ; then
		echo -e "\nSVN Variables used:"
		echo      "-------------------"
		echo "SVN_SERVER  - $SVN_SERVER"
		echo "SVN_MODULE  - $SVN_MODULE"
		echo "SVN         - $SVN | options $SVN_OPTIONS" 
	elif [ -n "$GIT_SERVER" ] ; then
		echo -e "\nGIT Variables used:"
		echo      "-------------------"
		echo "GIT_SERVER  - $GIT_SERVER"
		echo "GIT_NAME    - $GIT_NAME"
		echo "GIT         - $GIT | options $GIT_OPTIONS" 
	fi
	echo -e "\nInternal Variables set:"
	echo      "-----------------------"
	echo "CONFIGURE_DEFAULTS - $CONFIGURE_DEFAULTS"
	echo "ARCH               - $ARCH"
	echo "C[XX]FLAGS	 - $CFLAGS | CXX - $CXX | CPP - $CPP"
	echo "LIBDIRSUFFIX	 - $LIBDIRSUFFIX"
	echo "MAKEOPTS           - $MAKEOPTS"
	echo "WGET               - $WGET | options $WGET_OPTIONS"
}

# end SlackBuild.inc
