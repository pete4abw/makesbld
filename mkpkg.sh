#!/bin/sh
# Create makesbld package

# if VERSION file not there, then quit

[ ! -r VERSION ] && exit 1

PKGNAME=makesbld
VERSION=`cat VERSION|grep VERSION|cut -d= -f2`
COPYRIGHTDATE=`cat VERSION|grep COPYRIGHTDATE|cut -d= -f2`
PKGDIR=/tmp
BUILDDIR=${PKGDIR}/${PKGNAME}
REV=1

# copy files over to temp
[ -d $BUILDDIR ] && rm -fr $BUILDDIR

mkdir -p $BUILDDIR
cp -va install etc usr $BUILDDIR

# use sed to install version in needed files

cd $BUILDDIR
for file in "install/slack-desc" "usr/bin/makesbld-d.sh" "usr/man/man1/makesbld.1" \
	"usr/man/man5/makesbld.inc.5" "usr/man/man5/makesbld.conf.5" \
	"usr/lib/makesbld/makesbld.inc" "etc/makesbld/makesbld.conf"
do
	sed -i -e "s^%%ver%%^$VERSION^" \
	       -e "s^%%date%%^$COPYRIGHTDATE^"	$file
done 

for file in mirrors.conf makesbld.conf
do
	(cd etc/makesbld; mv $file $file.new)
done


# delete any backup files 
find . -type f -name '*~' -print0 | xargs -0r rm

# rename doc dir
mv -v usr/doc/${PKGNAME} usr/doc/${PKGNAME}-${VERSION}

# gzip everything in man and doc
gzip -v9 usr/doc/*/*
gzip -v9 usr/man/*/*

# make package

/sbin/makepkg -c n -l n ${PKGDIR}/${PKGNAME}-${VERSION}-noarch-${REV}.txz 

echo "Package $PKGNAME-$VERSION has been stored in $PKGDIR."

