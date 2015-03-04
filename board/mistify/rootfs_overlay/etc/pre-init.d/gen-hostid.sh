#!/bin/bash
# Get the SMBIOS product_uuid and use it for the basis of hostid and machine-id
# Parts of this script is based on one from Fazle Arefin

uuid=""
# uuid passed in?
read -r cmdline < /proc/cmdline
for param in $cmdline ; do
	case $param in
	    mistify.uuid=*)
		    uuid=${param#mistify.uuid=}
		    ;;
	esac
done

if [ -z "$uuid" ]; then
    uuid=`cat /sys/class/dmi/id/product_uuid`
fi

if [ -z "$uuid" ]; then
    # try to generate same uuid on each boot
    mac=`ip link show | awk '/ether/ {print $2}' | sort | head -n 1 | sed s/://g`
    a=${mac:0:8}
    b=${mac:8:4}
    uuid=`printf '%s-%s-0000-0000-000000000000' $a $b`
fi

if [ -z "$uuid" ]; then
    echo "unable to get a uuid!"
    exit -5
fi

#lowercase the UUID
uuid=${uuid,,}

#remove dashes
machine_id=${uuid//-/}
host_id=${uuid:0:8}

a=${host_id:6:2}
b=${host_id:4:2}
c=${host_id:2:2}
d=${host_id:0:2}

echo -ne \\x$a\\x$b\\x$c\\x$d > /etc/hostid &&
    echo "Setting hostid to $host_id"

echo $machine_id > /etc/machine_id &&
    echo "Setting machine_id to $machine_id"

echo $machine_id > /etc/machine-id &&
    echo "Setting machine-id to $machine_id"

echo $uuid > /etc/mistify-id  &&
    echo "Setting mistify-id to $uuid"

exit 0
