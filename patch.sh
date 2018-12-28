#!/bin/sh

pkg install -y cdrtools ca_root_nss rsync

if [ ! -e FreeBSD-12.0-RELEASE-amd64-disc1.iso ]
then
 fetch https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/12.0/FreeBSD-12.0-RELEASE-amd64-disc1.iso.xz
 xz -d ./FreeBSD-12.0-RELEASE-amd64-disc1.iso.xz
fi

if [ -e ./FreeBSD-12.0-RELEASE-bhyve64-autoinst.iso ]
then
 rm ./FreeBSD-12.0-RELEASE-bhyve64-autoinst.iso
fi

PATCHED_ISO_DIR=`mktemp -d`
ORIG_ISO_DIR=`mktemp -d`

mount -t cd9660 /dev/`mdconfig -f FreeBSD-12.0-RELEASE-amd64-disc1.iso` $ORIG_ISO_DIR
rsync -aq $ORIG_ISO_DIR/ $PATCHED_ISO_DIR/

# make modifications
cp ./installerconfig $PATCHED_ISO_DIR/etc/installerconfig
cp ./rc.local $PATCHED_ISO_DIR/etc/rc.local

# create the new ISO.   VOLD_ID is important..
VOL_ID=$(isoinfo -d -i FreeBSD-12.0-RELEASE-amd64-disc1.iso | grep "Volume id" | awk '{print $3}')
mkisofs -J -R -no-emul-boot -V "$VOL_ID" -b boot/cdboot -o FreeBSD-12.0-RELEASE-bhyve64-autoinst.iso $PATCHED_ISO_DIR

umount $ORIG_ISO_DIR
rm -rf $ORIG_ISO_DIR
rm -rf $PATCHED_ISO_DIR
