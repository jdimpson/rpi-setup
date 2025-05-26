#!/bin/sh

BLOCK="$1";
if test -z "$BLOCK"; then
	#BLOCK="/dev/sdb";
	echo "Need to know what block device to mount";
	echo "Usage: $0 </dev/blockdevice>";
	exit 1;
fi

if echo "$BLOCK" | grep -q loop; then
	BOOTP="${BLOCK}p1";
	ROOTP="${BLOCK}p2";
else
	BOOTP="${BLOCK}1";
	ROOTP="${BLOCK}2";
fi

if test -e "$BLOCK" && test -e "$BOOTP" && test -e "$ROOTP"; then
	if grep -q "$BLOCK" /proc/mounts; then
		echo "I wanted to use $BLOCK but it's already mounted.";
		exit 2;
	else
		echo "Using $BLOCK";
	fi
else
	echo "I wanted to use $BLOCK but it doesn't seem like it's formatted as an RPi image.";
	exit 3;
fi

mkdir rootfs;
sudo mount "$ROOTP" rootfs;
cd rootfs;

TBIT=
TTYPE=$(file -L ./bin/sh) 
if echo "$TTYPE" | grep -q '32-bit'; then
	TBIT=32;
else
	if echo "$TTYPE" | grep -q '64-bit'; then
		TBIT=64;
	fi
fi
if test -z "$TBIT"; then
	echo "Couldn't figure out 32- or 64-bit arch";
	sudo umount rootfs;
	exit 4;
fi
echo "Emulating $TBIT-bit pi";

QEMU=
HQEMU=
if test "$TBIT" = "32"; then
	QEMU1="qemu-arm-static";
	QEMU2="qemu-static-arm";
fi
if test "$TBIT" = "64"; then
	QEMU1="qemu-aarch64-static";
	QEMU2="qemu-static-aarch64";
fi

if which "$QEMU1" > /dev/null; then
	QEMU="$QEMU1";
	HQEMU=$(which "$QEMU1");
else
	if which "$QEMU2" > /dev/null; then
		QEMU="$QEMU2";
		HQEMU=$(which "$QEMU2");
	else
		echo "$QEMU1 or $QEMU2 needs to be installed";
		sudo umount rootfs;
		exit 5;
	fi
fi
echo "Using $HQEMU";

if test -e boot/firmware; then
	BOOT="boot/firmware";
else
	BOOT="boot";
fi
echo "Mounting to $BOOT";

cleanup() {
	echo "Cleaning up";
	sudo umount sys;
	sudo umount proc;
	sudo umount dev/pts;
	sudo umount dev;
	sudo umount "$BOOT";
	cd .. ;
	sudo umount rootfs
	rmdir rootfs;
}
trap cleanup 1 2 3 15 EXIT;

set -e;
sudo mount "${BOOTP}" "$BOOT";
sudo mount --bind /dev dev;
sudo mount --bind /dev/pts dev/pts;
sudo mount --bind /proc proc;
sudo mount --bind /sys sys;

sudo cp "$HQEMU" .;
sudo chroot . "./$QEMU" /bin/bash;
sudo rm "$QEMU";

exit 0;
