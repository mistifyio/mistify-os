#!/bin/bash

#+
# This script configures the network interfaces and bridges for testing
# Mistify-OS within a qemu/kvm virtual machine. It creates a bridge named
# <BRIDGE> and a tap interface named <TAP> which is then added to the bridge.
# The bridge IP address is set to the address <IP> and masked to
# 255.255.255.0.
#
# Because Mistify-OS relies upon dhcp a dhcp server is started which is
# configured to listen on the 10.0.2.0 subnet.
#
# NOTE: It is assumed this script is invoked from the same directory in which
# the testmistify script resides.
#-

source scripts/mistify-functions.sh

tapdefault=tap0
bridgedefault=mosbr0
ipdefault=10.0.2.2
maskbitsdefault=24

usage () {
    warning This script must be executed as root and can break an existing
    warning configuration. Use with caution.
    warning This script supports options for the interface names and IP
    warning configuration. If these options are used instead of the defaults
    warning be sure to use the same values again or confusing and non-functional
    warning network configurations can be the result.

    cat << EOF
Usage: $0 [options]
    Use this script to configure the local network for testing Mistify-OS within
    a virtual machine.

    The script first checks to see if the required bridge and tap network
    interface already exist. If so then nothing is changed.

    NOTE: This script is intended to be called once but if called again
    will check the configuration and repair missing parts if necessary.

    Options:
    --tap <TAP>
        The name of the tap interface to use.
        Default = $tapdefault
    --bridge <BRIDGE>
        The name of the bridge to create.
        Default = $bridgedefault
    --ip <IP>
        The IP address to assign to the bridge.
        Default = $ipdefault.
    --maskbits <BITS>
        The number of bits for the network mask.
        Default = $maskbits
    --verbose
        Enble verbose output from this script.
	-h|--help)
    --help
        Show this help information.
EOF
}

function check_installed() {
    p=`which $1`
    code=$?
    if [ $code -gt 0 ]; then
	error The utility $1 is not installed.
    else
	message Using $p.
    fi
    return $code
}

#+
# Handle the command line options.
#-
a=`getopt -l "\
tap:,\
bridge:,\
ip:,\
maskbits:,\
verbose,\
help" \
   -o "h" -- "$@"`

if [ $? -gt 0 ]; then
    usage
    exit 1
fi

eval set -- $a

while [ $# -ge 1 ]; do
    case "$1" in
	--)
	    shift
	    break
	    ;;
	--tap)
	    tap=$2
	    shift
	    ;;
	--bridge)
	    bridge=$2
	    shift
	    ;;
	--ip)
	    ip=$2
	    shift
	    ;;
	--maskbits)
	    ip=$2
	    shift
	    ;;
	--verbose)
	    verbose=y
	    ;;
	--help)
	    usage
	    exit 0
	    ;;
	# using getopt should avoid needing this catchall but just in case...
	*)
	    error "Invalid option: $1"
	    usage
	    exit 1
	    ;;
    esac
    shift
done

if [ -z "$tap" ]; then
    tap=$tapdefault
fi
verbose TAP device is: $tap

if [ -z "$bridge" ]; then
    bridge=$bridgedefault
fi
verbose Bridge device is: $bridge

if [ -z "$ip" ]; then
    ip=$ipdefault
fi
verbose Bridge IP address is: $ip

if [ -z "$maskbits" ]; then
    maskbits=$maskbitsdefault
fi
verbose Bridge device mask bits are: $maskbits

message Verifying tools.
for t in tunctl brctl ip; do
    check_installed $t
    if [ $? -ge 0 ]; then
      e=$?
    fi
done

if [ $e -gt 0 ]; then
  exit 1
fi

# Must be root from this point on.

if [ `id -u` -ne 0 ]; then
  error This script must be executed as root.
  usage
  exit 1
fi

message Checking if $bridge exists.
brctl show $bridge | grep $bridge
if [ $? -gt 0 ]; then
    brctl addbr $bridge
    if [ $? -gt 0 ]; then
	error Could not create bridge $bridge.
	exit 1
    else
	message Created bridge $bridge.
    fi
else
    message The bridge $bridge already exists.
fi

message Checking bridge IP address.
ip addr show dev $bridge | grep $ip
if [ $? -gt 0 ]; then
    message Setting bridge $bridge IP address to $ip.
    ip addr change $ip/$maskbits dev $bridge
else
    message The bridge IP address was already set to $ip.
fi

message Checking if interface $tap exists.
ip addr show dev $tap | grep " $tap:"
if [ $? -gt 0 ]; then
    message Creating device $tap.
    tunctl -t $tap
else
    message The tunnel device $tap already exists.
fi

message Checking if interface $tap is part of bridge $bridge.
brctl show $bridge | grep $tap
if [ $? -gt 0 ]; then
    message Adding device $tap to bridge $bridge.
    brctl addif $bridge $tap
else
    message The device $tap is already part of bridge $bridge.
fi

message Enabling bridge $bridge.
ip link show $bridge | grep ",UP"
if [ $? -gt 0 ]; then
    message Enabling the bridge device $bridge.
    ip link set dev $bridge up
    if [ $? -gt 0 ]; then
	error "Could not enable bridge $bridge."
    fi
else
    message The bridge state is already UP.
fi

