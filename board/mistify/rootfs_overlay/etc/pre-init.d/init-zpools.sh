#!/bin/bash

ZPOOL=mistify

zpool import -f $ZPOOL > /dev/null 2>&1

zpool list $ZPOOL > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Mistify zpool is not present"

    if [ -f /tmp/mistify-config ]; then
        . /tmp/mistify-config
        TYPE=$ZFS_POOL
    fi

    DISKLIST=`lsblk --ascii --noheadings --output type,name,size,model --nodeps | grep ^disk`
    DISKDEVS=`echo "$DISKLIST" | awk '{print "/dev/"$2}'`

    ZPOOLCANDIDATES=`echo "$DISKDEVS" | awk '{print $1}'`
    # Don't use the boot drive.
    for D in $ZPOOLCANDIDATES; do
	if sfdisk -q -l $D | grep "\*"; then
	    echo "Excluding boot drive $D."
	    continue
	else
	    DISKS="$DISKS $D"
	fi
    done
    
    ZFS=""
    read -r cmdline < /proc/cmdline
    for param in $cmdline ; do
	case $param in
	    zfs=*)
		ZFS=${param#zfs=}
		;;
	esac
    done
    ANSWER=n
    if [ "$ZFS" = "auto" ]; then
	ANSWER=y
    else
	echo "No $ZPOOL zpool detected."
	echo "enter y and a zpool will be created using all disks."
	echo "enter any other input to drop to a shell to setup manually"
	echo "DISKS:"
	echo "$DISKLIST"
	echo
	echo -n "input: "
	read ANSWER
    fi

    if [ "$ANSWER" == "y" ]; then
	TYPE=raidz
	read -a ARRAY <<< "$DISKS"

	if [ ${#ARRAY[@]} -eq 1 ]; then
	    TYPE=""
	fi

	# Be sure the drives are starting fresh.
	for D in $DISKS; do
	    echo "Cleaning $D..."
	    sgdisk -o $D > /dev/null 2>&1
	done

	udevadm settle

	zpool create -f \
		-o cachefile=none \
		$ZPOOL $TYPE $DISKS

	if [ $? -ne 0 ]; then
	    exit -4
	fi
	udevadm settle
    else
	# TODO: we could allow bootflags that will set it up for us
	# possibly using certain options
	echo "You need to create a zpool named mistify"
	echo "Reboot after setting it up"
	# the init wrapper will exec bash for us
	exit -3
    fi
fi

# Pause until the mistify zpool is imported and mounted
while [ ! -d /$ZPOOL ]
do
	sleep 2
done

# Create base zfs filesystems and set their properies
for D in data private images guests; do
    zfs list $ZPOOL/$D > /dev/null 2>&1 || zfs create $ZPOOL/$D
done

COMPRESSION=$(zfs get compression -Ho value mistify)
if [ "$COMPRESSION" = "off" ]; then
    zfs set compression=lz4 $ZPOOL
fi

QUOTA=$(zfs get quota -Ho value $ZPOOL/private)
if [ "$QUOTA" = "none" ]; then
    zfs set quota=4G $ZPOOL/private
fi
