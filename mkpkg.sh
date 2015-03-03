#!/bin/sh
# Create makesbld package

PKGNAME=makesbld
VERSION=`cat VERSION`
PKGDIR=/tmp
BUILDDIR=${PKGDIR}/${PKGNAME}

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

# make package

/sbin/makepkg -c n -l n ${PKGDIR}/${PKGNAME}-${VERSION}-noarch-1.txz 

echo "Package $PKGNAME-$VERSION has been stored in $PKGDIR."

