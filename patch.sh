#!/bin/sh

# builds an auto-installing FreeBSD iso

hash mkisofs rsync || pkg install -y cdrtools ca_root_nss rsync

rnd() {
  dd if=/dev/random bs=16 count=1 status=none | md5
}

[ -e FreeBSD-12.0-RELEASE-amd64-disc1.iso ] || {
 fetch https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/12.0/FreeBSD-12.0-RELEASE-amd64-disc1.iso.xz
 xz -d ./FreeBSD-12.0-RELEASE-amd64-disc1.iso.xz
}

[ -e ./FreeBSD-12.0-RELEASE-bhyve64-autoinst.iso ] && {
 rm ./FreeBSD-12.0-RELEASE-bhyve64-autoinst.iso
}

PATCHED_ISO_DIR="./$(rnd)"
ORIG_ISO_DIR="./$(rnd)"

mkdir "$PATCHED_ISO_DIR"
mkdir "$ORIG_ISO_DIR"

mount -t cd9660 /dev/"$(mdconfig -f FreeBSD-12.0-RELEASE-amd64-disc1.iso)" "$ORIG_ISO_DIR"
rsync -aq "$ORIG_ISO_DIR"/ "$PATCHED_ISO_DIR"/

# make modifications
cp ./installerconfig "$PATCHED_ISO_DIR"/etc/installerconfig
# a modified rc.local was used in the past to work with the default bhyve terminal
# cp ./rc.local "$PATCHED_ISO_DIR"/etc/rc.local

# create the new ISO.   VOLD_ID is important..
VOL_ID=$(isoinfo -d -i FreeBSD-12.0-RELEASE-amd64-disc1.iso | grep "Volume id" | awk '{print $3}')
mkisofs -J -R -no-emul-boot -V "$VOL_ID" -b boot/cdboot -o FreeBSD-12.0-RELEASE-bhyve64-autoinst.iso "$PATCHED_ISO_DIR"

umount "$ORIG_ISO_DIR"
rm -rf "$ORIG_ISO_DIR"
rm -rf "$PATCHED_ISO_DIR"
