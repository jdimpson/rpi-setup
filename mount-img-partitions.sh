#!/bin/sh

IMG=$1
MNT=$2
DEFMNT="."

usage() {
	echo "usage: $0 <img file containing multiple partitions>";
}

if test -z "$IMG"; then
	usage;
	exit 1;
fi
if ! test -r "$IMG"; then
	echo "Image $IMG is not readable";
	usage;
	exit 1;
fi

if test -z "$MNT"; then
	MNT="$DEFMNT";
fi

SECSIZE=`/sbin/fdisk -lu "$IMG" | awk '/Sector size/ {print $4}'`;

if test -z "$SECSIZE"; then
	echo "Error running fdisk -lu to find Sector size";
	usage;
	exit 2;
fi

GO=1;
I=1;
while test $GO -eq 1; do
	ENT=`/sbin/fdisk -lu "$IMG" | grep "$IMG$I"`;
	if test -z "$ENT"; then
		break
	fi
	TMP1=`echo $ENT | awk '{print $2}'`;
	TMP2=`echo $ENT | awk '{print $3}'`;
	if test "$TMP1" = "*"; then
		TMP1=`echo $ENT | awk '{print $3}'`;
		TMP2=`echo $ENT | awk '{print $4}'`;
	fi
	SEC=$TMP1
	OFF=$(($TMP1*$SECSIZE))
	LIM=$(($TMP2*$SECSIZE))

	# find the volume label
	LABEL=`dd bs=$SECSIZE skip=$SEC count=1024 if=$IMG 2>/dev/null | file - `;
	if echo "$LABEL" | grep -q "volume name "; then
		LABEL=`echo "$LABEL" | sed -e 's/.*volume name "//' -e 's/".*//'`;
	else
		if echo "$LABEL" | grep -q "label: \""; then
			LABEL=`echo "$LABEL" | sed -e 's/.*label: "//' -e 's/ *".*//'`;
		else
			LABEL=$I;
		fi
	fi
	
	#echo "partition $I (\"$LABEL\") at sector $SEC, offset $OFF, end $LIM, sector size $SECSIZE"
	echo mkdir -p $MNT/$LABEL
	echo mount $IMG $MNT/$LABEL -o loop,offset=$OFF,sizelimit=$LIM
	I=$(($I + 1))
done
