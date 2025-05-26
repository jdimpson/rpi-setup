#!/bin/sh

IMG="$1";
DSK="$2";

usage() {
	echo "$0 <image> <disk>"
}

if ! which pv; then
	echo pv not found;
	exit 5;
fi

if test -z "$IMG"; then
	#IMG="/home/user1/Documents/custom-2019-07-10-raspbian-buster.img.bz2";
	usage;
	exit 3;
fi

if test -z "$DSK"; then
	#DSK="/dev/mmcblk0";
	usage;
	exit 4;
fi

if ! test -r "$IMG"; then
	echo "Can't read file $IMG";
	exit 1;
fi
if ! test -e "$DSK"; then
	echo "Can't find dks $DSK";
	exit 2;
fi

echo "Copying $IMG to $DSK";

ISZ=`stat --format="%s" "$IMG"`;

if echo "$IMG" | egrep -q '.bz2$'; then
	echo "NOTE: percent complete won't be accurate due to buffering and decompressions";
	cat "$IMG" | pv -p -s "$ISZ" | bunzip2 -c - | sudo dd bs=4M conv=fsync of="$DSK";
else
	if echo "$IMG" | egrep -q '.zip$'; then
		# 1 file, 1954545664 bytes uncompressed, 483552118 bytes compressed:  75.3%
		ISZ=`zipinfo -t "$IMG" | sed -e 's/^..* files*, //' -e 's/ bytes uncompressed, [0-9]* bytes compressed: .*\%//'`;
		echo "ZIP $ISZ";
		unzip -p "$IMG" | pv -p -s "$ISZ" | sudo dd bs=4M conv=fsync of="$DSK";
	else
		if echo "$IMG" | egrep -q '.xz$'; then
			# Strms  Blocks   Compressed Uncompressed  Ratio  Check   Filename
			# totals  1       11      310991552       2017460224      0.154   CRC64   0      1
			ISZ=`xz --robot --list "$IMG" | grep '^totals' | cut -f 5`;
			xz --decompress --stdout "$IMG" | pv -p -s "$ISZ" | sudo dd bs=4M conv=fsync of="$DSK";
		else
			cat "$IMG" | pv -p -s "$ISZ" | sudo dd bs=4M conv=fsync of="$DSK";
		fi
	fi
fi
