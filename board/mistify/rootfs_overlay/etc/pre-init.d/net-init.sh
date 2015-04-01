#!/bin/bash

MISTIFY_IFSTATE=/tmp/.ifstate
MISTIFY_CONFIG=/tmp/mistify-config
PROC_CMDLINE=/proc/cmdline
ETHER_DEVS=(`ls /sys/class/net | egrep -v '^lo$'`)

MISTIFY_KOPT_IP=""
MISTIFY_KOPT_GW=""
MISTIFY_KOPT_IFACE=""

# Parse the kernel boot arguments and look for any mistify.* arguments and
# pick out their values.
function parse_boot_args() {

    for kopt in `cat $PROC_CMDLINE`; do
        k=`echo $kopt | awk -F= '{print $1}'`
        v=`echo $kopt | awk -F= '{print $2}'`

        if [ "$k" == "mistify.debug/test/not-for-prod.ip" ]; then
            MISTIFY_KOPT_IP="$v"
        fi
        if [ "$k" == "mistify.debug/test/not-for-prod.gw" ]; then
            MISTIFY_KOPT_GW="$v"
        fi
        if [ "$k" == "mistify.debug/test/not-for-prod.iface" ]; then
            MISTIFY_KOPT_IFACE="$v"
        fi
    done
}

# Act on any IP address being passed to us via kernel boot arguments.
# By default, configure the first enummerated interface on the system with it.
function configure_net_manual() {
    if [ -n "$MISTIFY_KOPT_IFACE" ]; then
        local iface="$MISTIFY_KOPT_IFACE"
    else
        local iface="${ETHER_DEVS[0]}"
    fi

    echo "Manually configuring $iface with $MISTIFY_KOPT_IP..."
    /sbin/ip link set $iface up
    /sbin/ip addr add $MISTIFY_KOPT_IP dev $iface
    echo "IFTYPE=MANUAL" >> $MISTIFY_IFSTATE
    echo "IFACE=$iface" >> $MISTIFY_IFSTATE
    echo "IP=$MISTIFY_KOPT_IP" >> $MISTIFY_IFSTATE

    if [ -n "$MISTIFY_KOPT_GW" ]; then
        echo "Manually adding $MISTIFY_KOPT_GW as default route"
        /sbin/ip route add default via $MISTIFY_KOPT_GW
        echo "GW=$MISTIFY_KOPT_GW" >> $MISTIFY_IFSTATE
    fi
}

# Cycle through all known ethernet interfaces until we find one which
# responds to DHCP requests.
function configure_net_dhcp() {
    for iface in "$ETHER_DEVS"; do
        echo "Probing $iface for DHCP"
        /sbin/dhclient -1 -v $iface

        if [ $? -eq 0 ]; then
            echo "IFTYPE=DHCP" >> $MISTIFY_IFSTATE
            echo "IFACE=$iface" >> $MISTIFY_IFSTATE

            local dhc_ip=`/sbin/ip addr show $iface | awk '/inet / {print $2}'`
            echo "IP=$dhc_ip" >> $MISTIFY_IFSTATE

            local gw=`/sbin/ip route | awk '/default via/ {print $3}'`
            echo "GW=$gw" >> $MISTIFY_IFSTATE

            return 0
        fi
    done
}

# Unconfigure and otherwise clean up any interfaces we may have configured
function unconfigure_net_iface() {
    if [ -f $MISTIFY_IFSTATE ]; then
        . $MISTIFY_IFSTATE
    else
        return 1
    fi

    if [ "$IFTYPE" == "DHCP" ]; then
        echo "Releasing DHCP lease on $IFACE..."
        /sbin/dhclient -r -v $IFACE
        /sbin/ip addr del $IP dev $IFACE
        /sbin/ip link set $IFACE down
    fi
}

function get_mistify_config() {
    if [ -f $MISTIFY_IFSTATE ]; then
        . $MISTIFY_IFSTATE
    else
        return 1
    fi

    curl http://192.168.100.100:8888/configs/$IP > $MISTIFY_CONFIG

    if [ $? -ne 0 ]; then
        echo "FATAL: Could not get Mistify configuration for $IP!"
        return 1
    fi
}

## Network initialization main. Under 'start' we either manually configure a IP address
## on the first interface if we are given one in the kernel boot arguments.
## Otherwise we probe each interface for a DHCP response until we fine one that does.
if [[ ${BASH_SOURCE[0]} == $0 ]]; then
    # being executed, not sourced
    case "$1" in
        'start')
            # Initialize our own interface state file
            cp /dev/null $MISTIFY_IFSTATE

            parse_boot_args

            if [ -n "$MISTIFY_KOPT_IP" ]; then
                configure_net_manual
            else
                configure_net_dhcp
                get_mistify_config
            fi
            ;;
        'stop')
            unconfigure_net_iface
            ;;
        *)
            echo "Usage: $0 {start|stop}"
            ;;
    esac
fi
