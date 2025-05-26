#!/bin/sh

IMG="$2";
DSK="$1";

usage() {
		echo "Usage: $0 <device> <image>"
}
if test -z "$IMG"; then
	usage;
	exit 1;
fi

if test -z "$DSK"; then
	usage;
	exit 2;
fi

if ! test -e "$DSK"; then
	echo "Can't find dks $DSK";
	exit 2;
fi

echo "Copying $DSK to $IMG";

OSZ=`lsblk -bdno size -- "$DSK"`;

if echo "$IMG" | egrep -q '.bz2$'; then
	echo "bzipping to $IMG";
	sudo dd bs=4M if="$DSK" | pv -p -s "$OSZ" | bzip2 -9c > "$IMG";
	sync;
	exit 0;
fi
if echo "$IMG" | egrep -q '.xz$'; then
	echo "xzing to $IMG";
	sudo dd bs=4M if="$DSK" | pv -p -s "$OSZ" | xz -9c > "$IMG";
	sync;
	exit 0;
fi
if echo "$IMG" | egrep -q '.zip$'; then
	O=`basename "$IMG" .zip`;
	echo "zipping to $IMG";
	sudo dd bs=4M if="$DSK" | pv -p -s "$OSZ" | zip "$IMG" -;
	echo "fixing name in zip archive, be patient";
	printf "@ -\n@=$O\n" | zipnote -w "$IMG";
	sync;
	exit 0;
fi
sudo dd bs=4M if="$DSK" | pv -p -s "$OSZ" > "$IMG";
sync;
exit 0;
