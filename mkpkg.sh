#!/bin/sh
# Create makesbld package

# if VERSION file not there, then quit

[ ! -r VERSION ] && exit 1

PKGNAME=makesbld
VERSION=`cat VERSION`
PKGDIR=/tmp
BUILDDIR=${PKGDIR}/${PKGNAME}
REV=1

# copy files over to temp
[ -d $BUILDDIR ] && rm -fr $BUILDDIR

mkdir -p $BUILDDIR
cp -va install etc usr $BUILDDIR

# use sed to install verion in needed files

cd $BUILDDIR
for file in "install/slack-desc" "usr/bin/makesbld.sh" "usr/bin/makesbld-d.sh"
do
	sed -i -e "s^%%ver%%^$VERSION^" $file
done 

# delete any backup files 
find . -type f -name '*~' -print0 | xargs -0re rm

# rename doc dir
mv -v usr/doc/${PKGNAME} usr/doc/${PKGNAME}-${VERSION}

# gzip everything in man and doc
gzip -v9 usr/doc/*/*
gzip -v9 usr/man/*/*

# make package

/sbin/makepkg -c n -l n ${PKGDIR}/${PKGNAME}-${VERSION}-noarch-${REV}.txz 

echo "Package $PKGNAME-$VERSION has been stored in $PKGDIR."

